#!/bin/bash

#-----------------------------------------------------------------------
# oci-desktop.sh - Oracle Cloud Infrastructure's Ubuntu Desktop setup script
#
# usage: oci-desktop.sh
#
# Copyright (c) 2021 Takeshi Yonezu
# All Rights Reserved.
#-----------------------------------------------------------------------

msgno=0

function logmsg {
  ((msgno+=1))

  echo ">>> $1"
}

function error {
  echo ">>> ERROR: $1"
  exit 1
}

if [ $(id -u) -ne 0 ]; then
  error "You should run as ROOT"
  exit 1
fi

function make_colormng() {
  if [ ! -f /etc/polkit-1/localauthority.conf.d/02-allow-colord.conf ]; then
    cat >/etc/polkit-1/localauthority.conf.d/02-allow-colord.conf <<EOF
polkit.addRule(function(action, subject) {
 if ((action.id == "org.freedesktop.color-manager.create-device" ||
 action.id == "org.freedesktop.color-manager.create-profile" ||
 action.id == "org.freedesktop.color-manager.delete-device" ||
 action.id == "org.freedesktop.color-manager.delete-profile" ||
 action.id == "org.freedesktop.color-manager.modify-device" ||
 action.id == "org.freedesktop.color-manager.modify-profile") &&
 subject.isInGroup("{users}")) {
 return polkit.Result.YES;
 }
});
EOF
  fi
}

#
# Main
#
logmsg "Start oci-desktop."

#
# Install ubuntu desktop
#
logmsg "Install ubuntu-desktop."

apt update

apt install -y ubuntu-desktop

apt install -y xrdp

apt autoremove
apt autoclean

make_colormng

logmsg "End of oci-desktop."

exit 0
