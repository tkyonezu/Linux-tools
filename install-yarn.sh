#!/bin/bash

#-----------------------------------------------------------------------
# Linux (Linux/x86_64, Darwin/x86_64, Linux/armv7l)
#
# install-yarn.sh - Install Yarn
#
# usage: install-yarn.sh
#
# Copyright (c) 2018 Takeshi Yonezu
# All Rights Reserved.
#-----------------------------------------------------------------------

logmsg() {
  echo ">>> $1"
}

#
# Install Yarn
#
logmsg "Install yarn"

curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -

echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list

sudo apt update
sudo apt install -y yarn

exit 0
