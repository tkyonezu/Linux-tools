#!/bin/bash

#
# Copyright 2018 Takeshi Yonezu. All Rights Reserved.
#
# SPDX-License-Identifier: Apache-2.0
#

if [ $(id -u) -ne 0 ]; then
  echo "ERROR: You should run as ROOT"
  exit 1
fi

if [ $(which python3.5 | wc -l) -eq 0 ]; then
  apt install -y python3.5
fi

if [ "$(python --version 2>&1 | awk '{ print $2 }' | cut -d'.' -f1,2)" != "3.5" ]; then
  update-alternatives --install /usr/bin/python python /usr/bin/python3.5 1
fi

if [ $(which pip | wc -l) -eq 0 ]; then
  curl -kL https://bootstrap.pypa.io/get-pip.py | python3
else
  if [ "$(pip --version | awk '{ print $6 }' | sed 's/)$//')" != "${PYTHON_VER}" ]; then
    curl -kL https://bootstrap.pypa.io/get-pip.py | python3
  fi
fi

echo "$ python --version"
python --version

echo "$ pip --version"
pip --version

exit 0
