#!/bin/bash

# Compose V2
# https://docs.docker.com/compose/cli-command/
#
# Where to get Docker COmpose - README.md
# https://github.com/docker/compose#where-to-get-docker-compose
#
# Install Docker Compose
# https://docs.docker.com/compose/install/#install-compose

RELEASE_URL=https://github.com/docker/compose/releases/download

VERSION=v2.37.2

if [ $# -ge 1 ]; then
  VERSION=$1
fi

case $(uname -s) in
  Darwin)  SYS=darwin;; # Mac OS Intel and Apple M1
  Linux)   SYS=linux;;  # Linux 64bit include Raspberry Pi OS
  *) echo "$(uname -s)/$(uname -m) does'nt supported."; exit 1;;
esac

case $(uname -m) in
  x86_64)  ARC=x86_64;;  # Mac OS Intel and Linux 64bit
  arm64)   ARC=aarch64;;  # Mac OS Apple M1
  aarch64) ARC=aarch64;;  # Raspberry Pi OS 64bit and Ubuntu 64bit
  armv7l)  ARC=armv7;;  # Raspberry Pi OS 32bit 
  *) echo "$(uname -s)/$(uname -m) does'nt supported."; exit 1;;
esac

DEST_DIR=/usr/libexec/docker/cli-plugins
## DEST_DIR=/usr/local/lib/docker/cli-plugins

if [ ! -d ${DEST_DIR} ]; then
  sudo mkdir -p ${DEST_DIR}
fi

sudo curl -L ${RELEASE_URL}/${VERSION}/docker-compose-${SYS}-${ARC} \
  -o ${DEST_DIR}/docker-compose

sudo chmod +x ${DEST_DIR}/docker-compose

echo "$ docker compose version"
docker compose version

exit 0
