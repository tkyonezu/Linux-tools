
#!/bin/bash

function apt_update {
  HOST=$1

  echo ">>> Update (${HOST})"

  RET=$(ssh ${HOST} env LANG=C sudo apt update 2>/dev/null | tail -1)

  if [ "${RET}" != "All packages are up to date." ]; then
    echo "# apt upgrade -y"
    ssh ${HOST} sudo apt upgrade -y
    echo "# apt autoremove"
    ssh ${HOST} sudo apt autoremove
  fi

  echo ">>> Update complete (${HOST})."
}

# change localhost to real hostname
apt_update localhost

exit 0
