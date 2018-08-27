#!/bin/bash

function apt_update {
  HOST=$1

  if [ "${HOST}" != "localhost" ]; then
    RHOST="ssh ${HOST}"
  fi

  echo ">>> Update (${HOST})"

  RET=$(${RHOST} sudo apt update 2>/dev/null | tail -1)

  if [[ "${RET}" != "All packages are up to date." &&
        "${RET}" != "パッケージはすべて最新です。" ]]; then
    echo "# apt upgrade -y"
    ${RHOST} sudo apt upgrade -y
    echo "# apt autoremove"
    ${RHOST} sudo apt autoremove
  fi

  echo ">>> Update complete (${HOST})."
}

# change localhost to real hostname
apt_update localhost

exit 0
