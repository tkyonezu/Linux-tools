#!/bin/bash

# Install Official Docker version
#
# Get Docker for Ubuntu
# https://docs.docker.com/engine/installation/linux/ubuntu/
#
# Get Docker for Debian
# Jessie 8.0 (LTD)/Raspbian jessie
# https://docs.docker.com/engine/installation/linux/debian/
#
# To install fixed version for Production
# https://docs.docker.com/engine/installation/linux/ubuntu/
#
#   apt-cache madison docker-ce
#   apt install -y docker-ce=<VERSION>

## DOCKER_REPO="dockerproject.org"	# dockerproject.org or docker.com
## DOCKER_PKG="docker-engine"		# docker-engine or docker-ce
DOCKER_REPO="docker.com"		# dockerproject.org or docker.com
DOCKER_PKG="docker-ce"			# docker-engine or docker-ce

if [[ "$(uname -s)" = "Linux" && "$(uname -m)" = "x86_64" ]]; then
  echo "=== Linux ==="
  ARCH="amd64"
elif [[ "$(uname -s)" = "Darwin" ]]; then
  echo "=== MacOS ==="
  ARCH="amd64"
  echo "Get Docker for Mac(stable) from https://download.docker.com/mac/stable/Docker.dmg"
  echo "and Install it."
  exit 0
elif [[ "$(uname -s)" = "Linux" && "$(uname -m)" = "armv7l" ]]; then
  echo "=== Raspberry Pi ==="
  ARCH="armhf"
else
  echo "This platform does'nt support yet."
  exit 1
fi

OS_NAME=$(cat /etc/os-release | grep ^NAME | cut -d'"' -f2 | sed 's/ .*//')

if [ "${OS_NAME}" = "CentOS" ]; then
  yum install -y yum-utils device-mapper-persistent-data lvm2

  yum-config-manager --add-repo \
    https://download.docker.com/linux/centos/docker-ce.repo

  yum install -y docker-ce

  systemctl start docker
  systemctl enable docker
else
  apt remove -y docker docker-engine docker-ce
  
  apt update
  
  apt install -y apt-transport-https ca-certificates \
    curl gnupg2 software-properties-common
  
  if [[ ${DOCKER_REPO} = "dockerproject.org" ]]; then
    curl -fsSL https://apt.dockerproject.org/gpg | apt-key add -
  
    if [[ "${ARCH}" = "amd64" ]]; then
      echo "deb [arch=${ARCH}] https://apt.dockerproject.org/repo \
        ubuntu-$(lsb_release -cs) main" | \
        tee /etc/apt/sources.list.d/docker.list
    else
      echo "deb [arch=${ARCH}] https://apt.dockerproject.org/repo \
        raspbian-$(lsb_release -cs) main" | \
        tee /etc/apt/sources.list.d/docker.list
    fi
  else
    if [[ "${ARCH}" = "amd64" ]]; then
      curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -

      echo "deb [arch=${ARCH}] https://download.docker.com/linux/ubuntu \
        $(lsb_release -cs) stable" | \
        tee /etc/apt/sources.list.d/docker.list
    else
      curl -fsSL https://download.docker.com/linux/raspbian/gpg | apt-key add -

      echo "deb [arch=${ARCH}] https://download.docker.com/linux/raspbian \
        $(lsb_release -cs) stable" | \
        tee /etc/apt/sources.list.d/docker.list
    fi
  
  fi
  
  apt update
  
  apt install -y ${DOCKER_PKG}
fi

exit 0
