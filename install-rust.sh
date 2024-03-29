#!/bin/bash

#-----------------------------------------------------------------------
# Linux (Linux/x86_64, Darwin/x86_64, Linux/armv7l)
#
# install-rust.sh - Install Rust, cargo edit, and cargo make
#
# usage: install-rust.sh
#
# Copyright (c) 2020, 2021 Takeshi Yonezu
# All Rights Reserved.
#-----------------------------------------------------------------------

logmsg() {
  echo ">>> $1"
}

function error {
  echo ">>> ERROR: $1"
  exit 1
}

if [ $(id -u) -eq 0 ]; then
  error "You should'nt run as ROOT"
  exit 1
fi

DIST=$(cat /etc/os-release | grep ^ID= | sed 's/^ID=//')

#
# Install Rust
#

logmsg "Start Install Rust"

if [[ "${DIST}" = \"almalinux\" || "${DIST}" = \"rocky\" ]]; then
  if ! rustc --version >/dev/null 2>&1; then
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    source ${HOME}/.profile
    cargo --version
  fi

  if [ ! -x ${HOME}/.cargo/bin/cargo-add ]; then
    cargo install cargo-edit
  fi

  if ! cargo make --version >/dev/null 2>&1; then
    cd ${HOME}
    mkdir -p github.com/sagiegurari

    cd github.com/sagiegurari
    git clone https://github.com/sagiegurari/cargo-make.git

    cd cargo-make
    cargo install --force cargo-make
  fi

  exit 0
fi

if ! rustc --version >/dev/null 2>&1; then
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y

  source $HOME/.profile
fi

if ! cargo-add --version >/dev/null 2>&1; then
  sudo apt install -y libssl-dev pkg-config

  cargo install cargo-edit
fi

if ! cargo make --version >/dev/null 2>&1; then
  cd $HOME
  mkdir -p github.com/sagiegurari
  cd github.com/sagiegurari

  if [ ! -d cargo-make ]; then
    git clone https://github.com/sagiegurari/cargo-make.git

    cd cargo-make
    cargo install --force cargo-make
  fi
fi

logmsg "End of Install Rust"

exit 0
