#!/bin/bash

#-----------------------------------------------------------------------
# centos-setup.sh - CentOS 7 First setup script
#
# usage: centos-setup.sh <hostname> [<user> [<uid>]]
#
# Copyright (c) 2018 Takeshi Yonezu
# All Rights Reserved.
#-----------------------------------------------------------------------

SWAP_SIZE_G=4				# 4GB
SWAP_SIZE_M=$((${SWAP_SIZE_G * 1024))

COMPOSE_VERSION=1.22.0

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

# Install docker-ce
logmsg "Install docker-ce"

yum install -y yum-utils device-mapper-persistent-data lvm2

yum-config-manager --add-repo \
    https://download.docker.com/linux/centos/docker-ce.repo

yum install -y docker-ce

systemctl start docker
systemctl enable docker

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

# vim color off
if [ ! -f ~/.vimrc ]; then
  cat <<EOF >~/.vimrc
syntax off
set nohlsearch
EOF
fi

# Update CentOS
logmsg "Update CentOS system"
yum -y update

logmsg "Reboot system."

exit 0
