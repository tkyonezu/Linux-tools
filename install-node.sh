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

## NODEJS_VERSION="12.15.0"
## NODEJS_VERSION="11.x"
## NODEJS_VERSION="10.x"
## NODEJS_VERSION="8.x"

#
# Install Node.js
#
# cf. https://github.com/nodesource/distributions#debinstall
#
logmsg ">>> Install Node.js ${NODEJS_VERSION}"

curl -sL https://deb.nodesource.com/setup_${NODEJS_VERSION} | bash -

apt install -y nodejs

node --version

exit 0
