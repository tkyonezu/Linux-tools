#!/bin/bash

#-----------------------------------------------------------------------
# Linux (Linux/x86_64, Darwin/x86_64, Linux/armv7l)
#
# install-java.sh - Install Java-JDK
#
# usage: install-java.sh
#
# Copyright (c) 2022 Takeshi Yonezu
# All Rights Reserved.
#-----------------------------------------------------------------------

logmsg() {
  echo ">>> $1"
}

JAVA_VERSION=17

#
# Install Java-jdk
#
logmsg "Install Java ${JAVA_VERSION}"

sudo apt update
sudo apt install -y openjdk-${JAVA_VERSION}-jdk

if [ ! -f /etc/profile.d/java.sh ]; then
  cat <<EOF | sudo tee /etc/profile.d/java.sh
export JAVA_HOME=\$(dirname \$(dirname \$(readlink \$(readlink \$(which java)))))
export PATH=\$PATH:\$JAVA_HOME/bin
EOF
fi

exit 0
