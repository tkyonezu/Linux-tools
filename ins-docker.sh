#!/bin/bash

if [[ "$(uname -s)" = "Linux" && "$(uname -m)" = "x86_64" ]]; then
  echo "=== Linux ==="
  PLATFORM="amd64"
elif [[ "$(uname -s)" = "Darwin" ]]; then
  echo "=== MacOS ==="
  PLATFORM="Mac"
  echo "Get Docker for Mac(stable) from https://download.docker.com/mac/stable/Docker.dmg"
  echo "and Install it."
  exit 0
elif [[ "$(uname -s)" = "Linux" && "$(uname -m)" = "armv7l" ]]; then
  echo "=== Raspberry Pi ==="
  PLATFORM="armhf"
else
  echo "This platform does'nt support yet."
  exit 1
fi

apt remove -y docker docker-engine docker-ce

apt update

if [[ "$PLATFORM" = "armhf" ]]; then
  apt install -y apt-transport-https \
    ca-certificates \
    curl \
    gnupg2 \
    software-properties-common

  curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add -

  apt-key fingerprint 0EBFCD88

  echo "deb [arch=armhf] https://apt.dockerproject.org/repo \
    raspbian-$(lsb_release -cs) main" | \
    tee /etc/apt/sources.list.d/docker.list

    apt update

    apt install -y docker-engine

## # Official docker version "Get Docker for Ubuntu"
## # https://docs.docker.com/engine/installation/linux/ubuntu/
##
## echo "deb [arch=armhf] https://download.docker.com/linux/debian \
##   $(lsb_release -cs) stable" | \
##   tee /etc/apt/sources.list.d/docker.list
## 
## apt update
## 
## apt install -y docker-ce
else
  apt install -y apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common

  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -

  apt-key fingerprint 0EBFCD88

  add-apt-repository \
    "deb https://apt.dockerproject.org/repo/ ubuntu-$(lsb_release -cs) main"

  apt update

  apt install -y docker-engine

## # Official docker version "Get Docker for Ubuntu"
## # https://docs.docker.com/engine/installation/linux/ubuntu/
## 
## add-apt-repository \
##   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
##   $(lsb_release -cs) stable"
## 
## apt update
## 
## apt install -y docker-ce
fi

## # To install fixed version for Production
## # https://docs.docker.com/engine/installation/linux/ubuntu/
## apt-cache madison docker-ce
## apt install -y docker-ce=<VERSION>

exit 0
