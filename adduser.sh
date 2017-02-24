#!/bin/bash

if [ $(id -u) -ne 0 ]; then
  echo "*ERROR* $0 must run 'root' user."
  exit 1
fi

echo "Create git user account ..>"

groupadd -g 1001 git
useradd -g git -u 1001 -c "git Administrator" -m -d /var/git git
passwd -l git

chown git:git /var/git
chmod 2775 /var/git

apt -y install git

echo "=== Firsttime you should exec below configuration ==="
echo "$ git config --global user.name \"John Doe\""
echo "$ git config --global user.email johndoe@example.com"
echo "$ git config --global core.editor vi"

exit 0
