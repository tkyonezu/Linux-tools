#!/bin/bash

#-----------------------------------------------------------------------
# Raspberry Pi
#
# install-docker.sh - Install Docker-Engine
#
# usage: install-docker.sh
#
# Copyright (c) 2017-2022 Takeshi Yonezu
# All Rights Reserved.
#-----------------------------------------------------------------------

logmsg() {
  echo ">>> $1"
}

#
# Install Docker
#
logmsg "Install Docker"

OS=$(uname -s)
ARCH=$(uname -m)

case ${OS} in
  Linux)  OS=linux;;
  Darwin) echo "${OS}/${ARCH} can use Docker for Mac."; exit 1;;
  *) echo "${OS}-${ARCH} does'nt supported yet."; exit 1;;
esac

DIST=$(cat /etc/os-release | grep ^ID= | sed 's/^ID=//')

case ${ARCH} in
  x86_64) ARCH=amd64;;
  armv7l) ARCH=armhf;;
  aarch64) ARCH=arm64;;
  *) echo "${OS}-${ARCH} does'nt supported yet."; exit 1;;
esac

if [[ "${DIST}" = \"almalinux\" || "${DIST}" = \"rocky\" ]]; then
  sudo dnf install -y yum-utils
  sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

  echo ">>> Correct Fingerprint: 060A 61C5 1B55 8A7F 742B 77AA C52F EB6B 621E 9F35"
  sudo dnf install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

  sudo systemctl start docker
  sudo systemctl enable docker

  sudo usermod -aG docker ${USER}

  exit 0
fi

sudo apt install -y ca-certificates curl gnupg

if [ -f /usr/share/keyrings/docker-archive-keyring.gpg ]; then
  sudo rm /usr/share/keyrings/docker-archive-keyring.gpg
fi

# Remove old version of gpg file
if [ -f /etc/apt/keyrings/docker.gpg ]; then
  sudo rm /etc/apt/keyrings/docker.gpg
fi

if [ ! -f /etc/apt/keyrings/docker.asc ]; then
  sudo install -m 0755 -d /etc/apt/keyrings
  sudo curl -fsSL https://download.docker.com/linux/${DIST}/gpg -o /etc/apt/keyrings/docker.asc
  sudo chmod a+r /etc/apt/keyrings/docker.asc
fi

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/${DIST} \
  "$(. /etc/os-release && echo "${VERSION_CODENAME}")" stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list >/dev/null

sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

if ! cat /etc/group | grep ^docker | grep ${USER} >/dev/null; then
  sudo usermod -aG docker ${USER}
fi

## if [ -f /etc/docker/daemon.json ]; then
##   sudo cat <<EOF  >daemon.json
## {
##   "features": { "buildkit": true }
## }
## EOF
## fi

exit 0
