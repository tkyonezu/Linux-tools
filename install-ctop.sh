#!/bin/bash

# Install ctop
# https://github.com/bcicen/ctop/releases

CTOP_VERSION=0.7.5

HARDWARE=$(uname -m)
SYSTEM=$(uname -s)

if [ "${SYSTEM}" = "Linux" ]; then
  if [ "${HARDWARE}" = "armv7l" ]; then
    SYSTEM="linux"
    HARDWARE="arm"
  elif [ "${HARDWARE}" = "aarch64" ]; then
    SYSTEM="linux"
    HARDWARE="arm64"
  elif [ "${HARDWARE}" = "x86_64" ]; then
    SYSTEM="linux"
    HARDWARE="amd64"
  else
    echo "This platform does'nt suppot yet!!"
    exit 1
  fi
elif [ "${SYSTEM}" = "Darwin" ]; then
  if [ "${HARDWARE}" = "x86_64" ]; then
    SYSTEM="darwin"
    HARDWARE="amd64"
  else
    echo "This platform does'nt suppot yet!!"
    exit 1
  fi
else
  echo "This platform does'nt suppot yet!!"
  exit 1
fi

curl -L https://github.com/bcicen/ctop/releases/download/v${CTOP_VERSION}/ctop-${CTOP_VERSION}-${SYSTEM}-${HARDWARE} -o /usr/local/bin/ctop

chmod +x /usr/local/bin/ctop

exit 0
