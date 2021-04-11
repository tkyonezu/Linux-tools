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
VERSION=1.16.3
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

go version

exit 0
