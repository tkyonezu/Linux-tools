#!/bin/bash

#-----------------------------------------------------------------------
# ubuntu-setup.sh - Ubuntu First setup script
#
# usage: ubuntu-setup.sh <hostname> [<user> [<uid>]]
#
# Copyright (c) 2018 Takeshi Yonezu
# All Rights Reserved.
#-----------------------------------------------------------------------

SWAP_SIZE_G=4				# 4GB
SWAP_SIZE_M=$((${SWAP_SIZE_G * 1024))

COMPOSE_VERSION=1.21.2

function install-docker-compose {
  curl -L https://github.com/docker/compose/releases/download/${COMPOSE_VERSION}/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
  chmod +x /usr/local/bin/docker-compose
}

msgno=0

function logmsg {
  ((msgno+=1))

  echo ">>> $1"
}

function error {
  echo ">>> ERROR: $1"
  exit 1
}

if [ $(id -u) -ne 0 ]; then
  error "You should run as ROOT"
fi

if [ $# -lt 1 ]; then
  error "Usage: $0 <hostname> [<user> [<uid>]]"
fi

NEW_HOST=$1

if [ $# -eq 1 ]; then
  NEW_USER=ubuntu
else
  NEW_USER=$2
fi

if [ $# -gt 2 ]; then
  NEW_UID=$3
else
  NEW_UID=0
fi

logmsg "Install packages"
apt install -y curl git make htop

# Install docker-ce
logmsg "Install docker-ce"
apt install -y apt-transport-https ca-certificates curl \
  software-properties-common

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

cat <<EOF >/etc/apt/sources.list.d/docker.list
deb [arch=amd64] https://download.docker.com/linux/ubuntu xenial stable
EOF

apt update
apt install -y docker-ce

# Install docker-compose
logmsg "Install docker-compose"
if [ -x /usr/local/bin/docker-compose ]; then
  if [ "$(docker-compose --version | awk '{ print $3 }' | sed 's/,$//')" != "${COMPOSE_VERSION}" ]; then
    install-docker-compose
  fi
else
  install-docker-compose
fi

# Setup hostname
logmsg "Setup hostname (${NEW_HOST})"
if [ "$(hostname)" != "${NEW_HOST}" ]; then
  echo ${NEW_HOST} >/etc/hostname
fi

# Change timezone
logmsg "Change timezone (Asia/Tokyo)"
timedatectl set-timezone Asia/Tokyo

# Setup user
logmsg "Setup user (${NEW_USER})"
if [ "${NEW_USER}" = "ubuntu" ]; then
  logmsg "ubuntu user don't do anything."
else
  if ! grep -q "^${NEW_USER}" /etc/passwd; then
    if [ ${NEW_UID} -ne 0 ]; then
      groupadd -g ${NEW_UID} ${NEW_USER}
      if [ $? -ne 0 ]; then
        error "groupadd (${NEW_UID}) for ${NEW_USER}"
      fi
      useradd -g ${NEW_UID} -u ${NEW_UID} -ms /bin/bash ${NEW_USER}
      if [ $? -ne 0 ]; then
        error "useradd (${NEW_UID}) for ${NEW_USER}"
      fi
    else
      useradd -ms /bin/bash ${NEW_USER}
      if [ $? -ne 0 ]; then
        error "useradd for (${NEW_USER})"
      fi
    fi
  fi

  NEW_UID=$(id -u ${NEW_USER})
  NEW_GID=$(id -g ${NEW_USER})

  if [ ! -f /etc/sudoers.d/010_${NEW_USER}-nopasswd ]; then
    echo "${NEW_USER} ALL=(ALL) NOPASSWD: ALL" >/etc/sudoers.d/010_${NEW_USER}-nopasswd
    chmod 440 /etc/sudoers.d/010_${NEW_USER}-nopasswd
  fi

  cd $(grep ^${NEW_USER} /etc/passwd | cut -d':' -f6)
  if [ ! -d .ssh ]; then
    mkdir -p .ssh
    chown ${NEW_UID}:${NEW_GID} .ssh
    chmod 700 .ssh
  fi
  if [ ! -f .ssh/authorized_keys ]; then
    > .ssh/authorized_keys
    chown ${NEW_UID}:${NEW_GID} .ssh/authorized_keys
    chmod 600 .ssh/authorized_keys
  fi

  if ! id ${NEW_USER} | grep -q docker; then
    usermod -aG docker ${NEW_USER}
  fi
fi

# Disable Guest session
logmsg "Disable Guest session"
if [ -d /etc/lightdm ]; then
  if [ ! -d /etc/lightdm/lightdm.conf.d ]; then
    mkdir -p /etc/lightdm/lightdm.conf.d
  fi

  if [ ! -f /etc/lightdm/lightdm.conf.d/50-no-guest.conf ]; then
    cat <<EOF >/etc/lightdm/lightdm.conf.d/50-no-guest.conf
[SeatDefaults]
allow-guest=false
EOF
  fi
fi

# Add swapfile
logmsg "Add swapfile"
if [ $(swapon -s | wc -l) -eq 0 ]; then
  logmsg "Create ${SWAP_SIZE_G}GB of swapfile and add it to /etc/fstab"
  dd if=/dev/zero of=/swapfile bs=1M count=${SWAP_SIZE_M}
  chmod 600 /swapfile

  mkswap /swapfile
  swapon /swapfile

  logmsg "Add the following entry to /etc/fstab"
  echo "/swapfile                                 none            swap    sw              0       0" | tee -a /etc/fstab
fi

# Update ubuntu
logmsg "Update ubuntu system"
apt update
apt upgrade -y

apt autoremove -y

logmsg " Reboot system."

exit 0
