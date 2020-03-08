#!/bin/bash

#-----------------------------------------------------------------------
# Linux (Linux/x86_64, Darwin/x86_64, Linux/armv7l)
#
# install-rust.sh - Install Rust
#
# usage: install-go.sh
#
# Copyright (c) 2020 Takeshi Yonezu
# All Rights Reserved.
#-----------------------------------------------------------------------

logmsg() {
  echo ">>> $1"
}

#
# Install Rust
#

logmsg "Install Rust"

curl https://sh.rustup.rs -sSf | sh

exit 0
