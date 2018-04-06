#!/bin/bash

#-----------------------------------------------------------------------
# Linux (Linux/x86_64, Darwin/x86_64, Linux/armv7l)
#
# install-node.sh - Install Node.js
#
# usage: install-node.sh
#
# Copyright (c) 2018 Takeshi Yonezu
# All Rights Reserved.
#-----------------------------------------------------------------------

logmsg() {
  echo ">>> $1"
}

#
# Install Node.js
#

curl -sL https://deb.nodesource.com/setup_8.x | bash -

apt install -y node.js

exit 0
