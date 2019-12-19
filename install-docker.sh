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

case ${ARCH} in
  x86_64) ARCH=amd64; DIST=ubuntu;;
  armv7l) ARCH=armhf; DIST=raspbian;;
# armv7l) ARCH=armhf; DIST=debian;;
  aarch64) ARCH=arm64; DIST=ubuntu;;
  *) echo "${OS}-${ARCH} does'nt supported yet."; exit 1;;
esac

apt install -y apt-transport-https ca-certificates curl \
  software-properties-common

curl -fsSL https://download.docker.com/linux/${DIST}/gpg | sudo apt-key add -

apt-key fingerprint 0EBFCD88

# The Ubuntu 19.10 (eoan) version of docker-ce has not been released yet,
# so use the disco version instead.
if [ "$(lsb_release -cs)" = "eoan" ]; then
  cat <<EOF >/etc/apt/sources.list.d/docker.list
deb [arch=${ARCH}] https://download.docker.com/linux/${DIST} disco stable
EOF
else
  cat <<EOF >/etc/apt/sources.list.d/docker.list
deb [arch=${ARCH}] https://download.docker.com/linux/${DIST} $(lsb_release -cs) stable
EOF
fi

apt update

apt install -y docker-ce docker-ce-cli containerd.io

exit 0
