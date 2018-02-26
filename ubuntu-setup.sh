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
  error "You should be run as ROOT"
fi

if [ $# -lt 2 ]; then
  error "Usage: $0 <hostname> <user>"
fi

logmsg "1 Install packages"
apt install -y git		# For VirtualBox image
apt install -y make htop

# Install docker-ce
logmsg "2. Install docker-ce"
apt instal -y apt-transport-https ca-certificates curl \
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

# Add swapfile
logmsg "4. Add swapfile"
dd if=/dev/zero of=/swapfile bs=1M count=4096
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile

# Set hostname
logmsg "5. Set hostname ($1)"
echo $1 >/etc/hostname

# Change timezone
logmsg "6. Change timezone (Asia/Tokyo)"
timedatectl set-timezone Asia/Tokyo

# Update ubuntu
logmsg "7. Update ubuntu system"
apt update
apt upgrade -y

logmsg "8. Reboot system."

exit 0
