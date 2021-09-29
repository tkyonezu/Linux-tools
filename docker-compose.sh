#!/bin/bash

# Install Docker Compose
# https://docs.docker.com/compose/install/#install-compose

RELEASE_URL=https://github.com/docker/compose/releases/download
DEST_DIR=/usr/local/bin

VERSION=v2.0.0
## VERSION=1.29.2

if [ $# -ge 1 ]; then
  VERSION=$1
fi

if [ "$(echo ${VERSION} | cut -c1,2)" = "v2" ]; then
  case $(uname -s) in
    Darwin)  SYS=darwin;; # Mac OS Intel and Apple M1
    Linux)   SYS=linux;;  # Linux 64bit include Raspberry Pi OS
    *) echo "$(uname -s)/$(uname -m) does'nt supported."; exit 1;;
  esac

  case $(uname -m) in
    x86_64)  ARC=amd64;;  # Mac OS Intel and Linux 64bit
    arm64)   ARC=arm64;;  # Mac OS Apple M1
    aarch64) ARC=arm64;;  # Raspberry Pi OS 64bit and Ubuntu 64bit
    armv7l)  ARC=armv7;;  # Raspberry Pi OS 32bit 
    *) echo "$(uname -s)/$(uname -m) does'nt supported."; exit 1;;
  esac

  mkdir -p ${HOME}/.docker/cli-plugins

  curl -L ${RELEASE_URL}/${VERSION}/docker-compose-${SYS}-${ARC} \
    -o ${HOME}/.docker/cli-plugins/docker-compose

  chmod +x ${HOME}/.docker/cli-plugins/docker-compose

  docker compose version
else
  case $(uname -s) in
    Darwin)  SYS=Darwin;;
    Linux)   SYS=linux;;
    *) echo "$(uname -s)/$(uname -m) does'nt supported."; exit 1;;
  esac

  case $(uname -m) in
    x86_64)  ARC=x86_64;;
    *) echo "$(uname -s)/$(uname -m) does'nt supported."; exit 1;;
  esac

  sudo curl -L ${RELEASE_URL}/${VERSION}/docker-compose-${SYS}-${ARC} \
    -o ${DEST_DIR}/docker-compose

  sudo chmod +x ${DEST_DIR}/docker-compose

  ${DEST_DIR}/docker-compose version
fi

exit 0
