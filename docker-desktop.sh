#!/bin/bash

#-----------------------------------------------------------------------
# Raspberry Pi
#
# docker-desktop.sh - Install Docker Desktop
#
# usage: docker-desktop.sh
#
# Copyright (c) 2023 Takeshi Yonezu
# All Rights Reserved.
#-----------------------------------------------------------------------

logmsg() {
  echo ">>> $1"
}

#
# Install Docker Desktop
#
logmsg "Install Docker Desktop"

VERSION="4.20.1"

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

if [ -f /usr/share/keyrings/docker-archive-keyring.gpg ]; then
  sudo rm /usr/share/keyrings/docker-archive-keyring.gpg
fi

if [ ! -f /etc/apt/keyrings/docker.gpg ]; then
  sudo mkdir -p /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/${DIST}/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
fi

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/${DIST} \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list >/dev/null

sudo apt update

cd /var/tmp

wget https://desktop.docker.com/linux/main/${ARCH}/docker-desktop-${VERSION}-${ARCH}.deb

sudo apt install -y ./docker-desktop-${VERSION}-${ARCH}.deb

rm ./docker-desktop-${VERSION}-${ARCH}.deb

systemctl --user start docker-desktop
systemctl --user enable docker-desktop

docker --version

docker compose version

exit 0
