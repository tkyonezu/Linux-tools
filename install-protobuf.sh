#!/bin/bash

#-----------------------------------------------------------------------
# Linux (Linux/x86_64, Darwin/x86_64, Linux/armv7l)
#
# install-protobuf.sh - Install Protobuf
#
# usage: install-protobuf.sh
#
# Copyright (c) 2021 Takeshi Yonezu
# All Rights Reserved.
#-----------------------------------------------------------------------

logmsg() {
  echo ">>> $1"
}

#
# Install Protobuf
#
VERSION=v3.13.0
COMMIT_ID=fde7cf7358ec7cd69e8db9be4f1fa6a5c431386a

logmsg "Install Protobuf ${VERSION}"

git clone https://github.com/google/protobuf /tmp/protobuf
cd /tmp/protobuf
git checkout ${COMMIT_ID}

cmake -DCMAKE_BUILD=Release \
    -Dprotobuf_BUILD_TESTS=OFF \
    -Dprotobuf_BUILD_SHARED_LIBS=ON \
    -H/tmp/protobuf/cmake \
    -B/tmp/protobuf/.build

sudo cmake --build /tmp/protobuf/.build --target install -- -j4

rm -fr /tmp/protobuf
