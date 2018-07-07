#!/bin/bash

#
# Install Docker on WSL (Windows10 1803)
#

sudo apt update
sudo apt upgrade
sudo apt install docker.io
sudo apt install zfsutils-linux  cgroup-bin cgroup-lite cgroup-tools cgroupfs-mount libcgroup1
sudo cgroupfs-mount
sudo usermod -aG docker $USER
sudo service docker start

exit 0

