#!/bin/bash

#-----------------------------------------------------------------------
# Raspberry Pi 3
#
# install-docker.sh - Install Docker-Engine
#
# usage: install-docker.sh
#
# Copyright (c) 2017 Takeshi Yonezu
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

sudo apt install -y ca-certificates curl gnupg lsb-release

## curl -fsSL https://download.docker.com/linux/${DIST}/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/${DIST}/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

## cat <<EOF | sudo tee /etc/apt/sources.list.d/docker.list >/dev/null
## deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/${DIST} $(lsb_release -cs) stable
## EOF

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/${DIST} \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

exit 0
