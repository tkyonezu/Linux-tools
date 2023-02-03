#!/bin/bash

# Compose V2
# https://docs.docker.com/compose/cli-command/
#
# Where to get Docker COmpose - README.md
# https://github.com/docker/compose#where-to-get-docker-compose
#
# Install Docker Compose
# https://docs.docker.com/compose/install/#install-compose

echo "This method does'nt support now!!"
echo "Please use 'docker-compose-plugin' as is."

exit 0

RELEASE_URL=https://github.com/docker/compose/releases/download

VERSION=v2.15.1
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
    x86_64)  ARC=x86_64;;  # Mac OS Intel and Linux 64bit
    arm64)   ARC=aarch64;;  # Mac OS Apple M1
    aarch64) ARC=aarch64;;  # Raspberry Pi OS 64bit and Ubuntu 64bit
    armv7l)  ARC=armv7;;  # Raspberry Pi OS 32bit 
    *) echo "$(uname -s)/$(uname -m) does'nt supported."; exit 1;;
  esac

  ## DEST_DIR=/usr/libexec/docker/cli-plugins
  DEST_DIR=/usr/local/lib/docker/cli-plugins

  if [ ! -d ${DEST_DIR} ]; then
    sudo mkdir -p ${DEST_DIR}
  fi

  sudo curl -L ${RELEASE_URL}/${VERSION}/docker-compose-${SYS}-${ARC} \
    -o ${DEST_DIR}/docker-compose

  sudo chmod +x ${DEST_DIR}/docker-compose

  if [ -x /usr/local/bin/docker-compose ]; then
    if [ ! -L /usr/local/bin/docker-compose ]; then
      if [ ! -x /usr/local/bin/docker-compose-v1 ]; then
        sudo mv /usr/local/bin/docker-compose /usr/local/bin/docker-compose-v1
      fi
    fi
  fi

  sudo ln -sf ${DEST_DIR}/docker-compose /usr/local/bin/docker-compose

  echo "$ docker compose version"
  docker compose version

  echo "$ docker-compose version"
  docker-compose version
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

  DEST_DIR=/usr/local/bin

  sudo curl -L ${RELEASE_URL}/${VERSION}/docker-compose-${SYS}-${ARC} \
    -o ${DEST_DIR}/docker-compose

  sudo chmod +x ${DEST_DIR}/docker-compose

  ${DEST_DIR}/docker-compose version
fi

exit 0
