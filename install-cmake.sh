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
VERSION=3.14.0

logmsg "Install CMake ${VERSION}"

sudo apt install -y automake build-essential ca-certificates ccache curl git

git clone https://gitlab.kitware.com/cmake/cmake.git /tmp/cmake
cd /tmp/cmake
git checkout bf02d625325535f485512eba307cff54c08bb257
./bootstrap --system-curl --parallel=4 --enable-ccache
make -j4
sudo make install
cd
rm -fr /tmp/cmake

exit 0
