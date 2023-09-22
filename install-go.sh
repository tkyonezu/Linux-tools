#!/bin/bash

#-----------------------------------------------------------------------
# Linux (Linux/x86_64, Darwin/x86_64, Linux/armv7l)
#
# install-go.sh - Install Go
#
# usage: install-go.sh
#
# Copyright (c) 2017, 2018 Takeshi Yonezu
# All Rights Reserved.
#-----------------------------------------------------------------------

logmsg() {
  echo ">>> $1"
}

#
# Install Go
#
VERSION=1.21.1
## VERSION=1.20.7
## VERSION=1.19.6
## VERSION=1.18.9
## VERSION=1.17.13
## VERSION=1.16.15
## VERSION=1.15.15
OS=$(uname -s)
ARCH=$(uname -m)

logmsg "Install Go ${VERSION}"

case ${OS} in
  Linux)  OS=linux;;
  Darwin) OS=darwin;;
  *) echo "${OS}-${ARCH} does'nt supported yet."; exit 1;;
esac

# arm64 is also supported and binaries are distributed from Go version 1.8.5
case ${ARCH} in
  x86_64)  ARCH=amd64;;
  aarch64) ARCH=arm64;;
  armv7l)  ARCH=armv6l;;
  arm64)   ARCH=arm64;;		# For Mac Apple M1 version
  *) echo "${OS}-${ARCH} does'nt supported yet."; exit 1;;
esac

cd /var/tmp

wget -N https://go.dev/dl/go${VERSION}.${OS}-${ARCH}.tar.gz

sudo rm -fr /usr/local/go
sudo tar -C /usr/local -xzf go${VERSION}.${OS}-${ARCH}.tar.gz

rm go${VERSION}.${OS}-${ARCH}.tar.gz

if ! grep -q GOPATH ~/.bashrc; then
  cat >>~/.bashrc <<EOF
export GOPATH=\${HOME}/go
export PATH=\${HOME}/go/bin:/usr/local/go/bin:\${PATH}
EOF
fi

/usr/local/go/bin/go version

exit 0
