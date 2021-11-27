#!/bin/bash

#-----------------------------------------------------------------------
# Linux (Linux/x86_64, Darwin/x86_64, Linux/armv7l)
#
# install-cmake.sh - Install cmake
#
# usage: install-cmake.sh
#
# Copyright (c) 2021 Takeshi Yonezu
# All Rights Reserved.
#-----------------------------------------------------------------------

logmsg() {
  echo ">>> $1"
}

#
# Install CMake
#
CMAKE_VERSION=3.22.0
## CMAKE_VERSION=3.14.0

logmsg "Install CMake ${VERSION}"

sudo apt install -y automake build-essential ca-certificates ccache \
  libssl-dev curl libcurl4-openssl-dev git

git clone https://github.com/Kitware/CMake.git -b v${CMAKE_VERSION} /tmp/cmake
cd /tmp/cmake
./bootstrap --system-curl --parallel=$(nproc) --enable-ccache
make -j$(nproc)
sudo make install
cd
rm -fr /tmp/cmake

exit 0
