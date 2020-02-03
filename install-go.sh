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
VERSION=1.13.7
OS=$(uname -s)
ARCH=$(uname -m)

logmsg "Install Go ${VERSION}"

case ${OS} in
  Linux)  OS=linux;;
  Darwin) OS=darwin;;
  *) echo "${OS}-${ARCH} does'nt supported yet."; exit 1;;
esac

case ${ARCH} in
  x86_64) ARCH=amd64;;
  armv7l) ARCH=armv6l;;
  aarch64) echo ">> install by sudo apt install golang"; exit 1;;
  *) echo "${OS}-${ARCH} does'nt supported yet."; exit 1;;
esac

cd /var/tmp

wget -N https://storage.googleapis.com/golang/go$VERSION.$OS-$ARCH.tar.gz

tar -C /usr/local -xzf go$VERSION.$OS-$ARCH.tar.gz

rm go$VERSION.$OS-$ARCH.tar.gz

cat >>~/.bashrc <<EOF
export GOPATH=\${HOME}/go
export PATH=/usr/local/go/bin:\$PATH
EOF

exit 0
