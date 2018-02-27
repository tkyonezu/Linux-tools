#!/bin/bash

#-----------------------------------------------------------------------
# ubuntu-setup.sh - Ubuntu First setup script
#
# usage: ubuntu-setup.sh <hostname> <user>
#
# Copyright (c) 2018 Takeshi Yonezu
# All Rights Reserved.
#-----------------------------------------------------------------------

COMPOSE_VERSION=1.19.0

logmsg() {
  echo ">>> $1"
}

error() {
  echo "ERROR: $1"
  exit 1
}

if [ $(id -u) -ne 0 ]; then
  error "You should run as ROOT"
fi

if [ $# -lt 2 ]; then
  error "Usage: $0 <hostname> <user>"
fi

NEW_HOST=$1
NEW_USER=$2		# New user name

logmsg "1 Install packages"
apt install -y curl git make htop

# Install docker-ce
logmsg "2. Install docker-ce"
apt install -y apt-transport-https ca-certificates curl \
  software-properties-common

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

cat <<EOF >/etc/apt/sources.list.d/docker.list
deb [arch=amd64] https://download.docker.com/linux/ubuntu xenial stable
EOF

apt update
apt install -y docker-ce

# Install docker-compose
logmsg "3. Install docker-compose"
curl -L https://github.com/docker/compose/releases/download/${COMPOSE_VERSION}/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

## # Add swapfile
## logmsg "4. Add swapfile"
## dd if=/dev/zero of=/swapfile bs=1M count=4096
## chmod 600 /swapfile
## mkswap /swapfile
## swapon /swapfile

# Set hostname
logmsg "5. Set hostname (${NEW_HOST})"
echo ${NEW_HOST} >/etc/hostname

# Change timezone
logmsg "6. Change timezone (Asia/Tokyo)"
timedatectl set-timezone Asia/Tokyo

# Setup user
logmsg "7. Setup user (${NEW_USER})"
if [ "${NEW_USER}" = "ubuntu" ]; then
  logmsg "ubuntu user don't do anything."
else
  if ! grep -q "^${NEW_USER}" /etc/passwd; then
    useradd -ms /bin/bash ${NEW_USER}
    NEW_UID=$(id -u ${NEW_USER})
    NEW_GID=$(id -g ${NEW_USER})
  fi

  if [ ! -f /etc/sudoers.d/010_${NEW_USER}-nopasswd ]; then
    echo "${NEW_USER} ALL=(ALL) NOPASSWD: ALL" >/etc/sudoers.d/010_${NEW_USER}-nopasswd
    chmod 440 /etc/sudoers.d/010_${NEW_USER}-nopasswd
  fi

  cd ~${NEW_USER}
  mkdir -p .ssh
  chown ${NEW_UID}:${NEW_GID} .ssh
  chmod 700 .ssh
  > .ssh/authorized_keys
  chown ${NEW_UID}:${NEW_GID} .ssh/authorized_keys
  chmod 600 .ssh/authorized_keys
fi

# Update ubuntu
logmsg "8. Update ubuntu system"
apt update
apt upgrade -y

logmsg "9. Reboot system."

exit 0
