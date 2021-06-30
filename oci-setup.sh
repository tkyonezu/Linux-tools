#!/bin/bash

#-----------------------------------------------------------------------
# oci-setup.sh - Oracle Cloud Infrastructure's Ubuntu First setup script
#
# usage: oci-setup.sh <hostname> [<user> [<uid>]]
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

if [ $# -lt 1 ]; then
  error "Usage: $0 <hostname> [<user> [<uid>]]"
fi

NEW_HOST=$1

if [ $# -eq 1 ]; then
  NEW_USER=ubuntu
else
  NEW_USER=$2
fi

NEW_HOME=/home/${NEW_USER}

if [ $# -gt 2 ]; then
  NEW_UID=$3
else
  NEW_UID=0
fi

SWAP_SIZE_G=4				# 4GB
SWAP_SIZE_M=$((${SWAP_SIZE_G} * 1024))

COMPOSE_VERSION=1.29.2

function install-docker-compose {
  curl -L https://github.com/docker/compose/releases/download/${COMPOSE_VERSION}/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
  chmod +x /usr/local/bin/docker-compose
}

function make_aliases() {
  if [ ! -f $HOME/.bash_aliases ]; then
    cat >$HOME/.bash_aliases <<EOF
alias ls='/bin/ls -CF --color=never'

alias da='echo "# docker ps -a"; docker ps -a'
alias di='echo "# docker images | more"; docker images | more'
alias dr='echo "# docker rm \$(docker ps -a -q)"; docker rm \$(docker ps -a -q)'
alias ds='echo "# docker stop \$(docker ps -q)"; docker stop \$(docker ps -q)'
alias dv='echo "# docker volume ls"; docker volume ls; if [ \$(docker volume ls | wc -l) -gt 1 ]; then echo "# docker volume prune -f"; docker volume prune -f; echo "# docker volume ls"; docker volume ls; fi'
EOF
  fi

  if [ -d ${NEW_HOME}  -a ! -f ${NEW_HOME}/.bash_aliases ]; then
    cp ${HOME}/.bash_aliases ${NEW_HOME}

    chown ${NEW_UID}:${NEW_GID} ${NEW_HOME}/.bash_aliases
  fi
}

function make_gitconfig() {
  if [ ! -f ${NEW_HOME}/.gitconfig ]; then
    cat >${NEW_HOME}/.gitconfig <<EOF
[user]
        email = user@mail
        name = User Name
[core]
        editor = vi
[push]
        default = simple
EOF

    chown ${NEW_UID}:${NEW_GID} ${NEW_HOME}/.gitconfig
  fi
}

function make_netrc() {
  if [ ! -f ${NEW_HOME}/.netrc ]; then
    cat >${NEW_HOME}/.netrc <<EOF
machine github.com
login user
password password
EOF

    chown ${NEW_UID}:${NEW_GID} ${NEW_HOME}/.netrc
    chmod 400 ${NEW_HOME}/.netrc
  fi
}

function make_vimrc() {
  if [ ! -f ${NEW_HOME}/.vimrc ]; then
    echo "syntax off" >${NEW_HOME}/.vimrc

    chown ${NEW_UID}:${NEW_GID} ${NEW_HOME}/.vimrc
  fi
}

#
# Main
#
logmsg "Start oci-setup."

#
# Update ubuntu
#
if [ ! -f $HOME/.bash_aliases ]; then
  logmsg "First time Update ubuntu system."

  make_aliases

  apt update
  apt upgrade -y

  apt autoremove -y; sudo apt autoclean

  logmsg "Press <ENTER> to Rebooting  system."

  read junk
  reboot
fi

#
# Install packages
#
logmsg "Install packages."

apt install -y automake build-essential ca-certificates ccache \
  libssl-dev pkg-config curl git make htop vim

#
# Install docker-ce
#
logmsg "Install docker-ce."

apt install -y apt-transport-https ca-certificates curl gnupg lsb-release

if [ ! -f /usr/share/keyrings/docker-archive-keyring.gpg ]; then
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
fi

if [ ! -f /etc/apt/sources.list.d/docker.list ]; then
  if [ "$(uname -m)" = "x86_64" ]; then
    echo \
      "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
    $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
  elif [ "$(uname -m)" = "aarch64" ]; then
    echo \
      "deb [arch=arm64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
    $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
  elif [ "$(uname -m)" = "armv7l" ]; then
    echo \
      "deb [arch=armhf signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
    $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
  else
    echo ">>> Docker doesn't support ($(uname -s)/$(uname -m))."
    exit 1
  fi
fi

apt update
apt install -y docker-ce docker-ce-cli containerd.io

usermod -aG docker ${NEW_USER}

#
# Install docker-compose
#
if [ "$(uname -m)" = "x86_64" ]; then
  logmsg "Install docker-compose."

  if [ -x /usr/local/bin/docker-compose ]; then
    if [ "$(docker-compose --version | awk '{ print $3 }' | sed 's/,$//')" != "${COMPOSE_VERSION}" ]; then
      install-docker-compose
    fi
  else
    install-docker-compose
  fi
fi

#
# Setup hostname
#
logmsg "Setup hostname (${NEW_HOST})."

if [ "$(hostname)" != "${NEW_HOST}" ]; then
  hostnamectl set-hostname ${NEW_HOST}
fi

#
# Setup timezone
#
logmsg "Setup timezone (Asia/Tokyo)."

TZ="$(timedatectl | grep "Time zone:" | sed -e 's/^.*Time zone: //' -e 's/ .*$//')"

if [ "${TZ}" != "Asia/Tokyo" ]; then
  timedatectl set-timezone Asia/Tokyo
fi

#
# Setup locale
#
logmsg "Setup locale."

LANG="$(localectl | grep "System Locale:" | sed -e 's/^.*System Locale: LANG=//' -e 's/ .*$//')"

if [ "${LANG}" != "ja_JP.UTF-8" ]; then

  apt install -y language-pack-ja

  localectl set-locale LANG=ja_JP.UTF-8
  localectl set-x11-keymap jp jp106
fi

#
# Setup user
#
logmsg "Setup user (${NEW_USER})."

if id ${NEW_USER} >/dev/null; then
    NEW_UID=$(id -u ${NEW_USER})
    NEW_GID=$(id -g ${NEW_USER})
else
  if [ "${NEW_USER}" = "ubuntu" ]; then
    logmsg "ubuntu user don't do anything."
  else
    if ! grep -q "^${NEW_USER}" /etc/passwd; then
      if [ ${NEW_UID} -ne 0 ]; then
        groupadd -g ${NEW_UID} ${NEW_USER}
        if [ $? -ne 0 ]; then
          error "groupadd (${NEW_UID}) for ${NEW_USER}"
        fi
        useradd -g ${NEW_UID} -u ${NEW_UID} -ms /bin/bash ${NEW_USER}
        if [ $? -ne 0 ]; then
          error "useradd (${NEW_UID}) for ${NEW_USER}"
        fi
      else
        useradd -ms /bin/bash ${NEW_USER}
        if [ $? -ne 0 ]; then
          error "useradd for (${NEW_USER})"
        fi
      fi
    fi

    NEW_UID=$(id -u ${NEW_USER})
    NEW_GID=$(id -g ${NEW_USER})

    if [ ! -f /etc/sudoers.d/010_${NEW_USER}-nopasswd ]; then
      echo "${NEW_USER} ALL=(ALL) NOPASSWD: ALL" >/etc/sudoers.d/010_${NEW_USER}-nopasswd
      chmod 440 /etc/sudoers.d/010_${NEW_USER}-nopasswd
    fi

  apt install -y ssh

    cd $(grep ^${NEW_USER} /etc/passwd | cut -d':' -f6)
    if [ ! -d .ssh ]; then
      mkdir -p .ssh
      chown ${NEW_UID}:${NEW_GID} .ssh
      chmod 700 .ssh
    fi
    if [ ! -f .ssh/authorized_keys ]; then
      > .ssh/authorized_keys
      chown ${NEW_UID}:${NEW_GID} .ssh/authorized_keys
      chmod 600 .ssh/authorized_keys
    fi
  fi
fi

#
# Make configuration files
#
logmsg "Make configuration files."

make_aliases
make_gitconfig
make_netrc
make_vimrc

# Set default umask
if ! grep -q "^umask 022" ${NEW_HOME}/.profile 2>/dev/null; then
  sed -i '/^#umask/aumask 022' ${NEW_HOME}/.profile
fi

#
# Disable Guest session
#
logmsg "Disable Guest session."

if [ -d /etc/lightdm ]; then
  if [ ! -d /etc/lightdm/lightdm.conf.d ]; then
    mkdir -p /etc/lightdm/lightdm.conf.d
  fi

  if [ ! -f /etc/lightdm/lightdm.conf.d/50-no-guest.conf ]; then
    cat <<EOF >/etc/lightdm/lightdm.conf.d/50-no-guest.conf
[SeatDefaults]
allow-guest=false
EOF
  fi
fi

#
# Add swapfile
#
logmsg "Add swapfile"
if [ $(swapon -s | wc -l) -eq 0 ]; then
  logmsg "Create ${SWAP_SIZE_G}GB of swapfile and add it to /etc/fstab"
  dd if=/dev/zero of=/var/swapfile bs=1M count=${SWAP_SIZE_M}
  chmod 600 /var/swapfile

  mkswap /var/swapfile
  swapon /var/swapfile

  logmsg "Add the following entry to /etc/fstab"
  echo "/var/swapfile                                 none            swap    sw              0       0" | tee -a /etc/fstab
  echo "/var/swapfile   swap            swap    defaults        0 0" | tee -a /etc/fstab
fi

#
# End of oci-setup
#
logmsg "End of oci-setup."

exit 0
