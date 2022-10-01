#!/bin/bash

#-----------------------------------------------------------------------
# Raspberry Pi
#
# install-btop.sh - Install btop
#
# usage: install-btop.sh
#
# Copyright (c) 2022 Takeshi Yonezu
# All Rights Reserved.
#-----------------------------------------------------------------------

VERSION=v1.2.9

OS=$(uname -s)
ARCH=$(uname -m)

TMPDIR=/var/tmp/btop$$

logmsg() {
  echo ">>> $1"
}

#
# Install btop
#
logmsg "Install btop"

mkdir ${TMPDIR}
cd ${TMPDIR}

curl -fsSL https://github.com/aristocratos/btop/releases/download/${VERSION}/btop-${ARCH}-${OS}-musl.tbz | tar -jxvf -

./install.sh

cd ..
rm -fr ${TMPDIR}

exit 0
