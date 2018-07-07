#!/bin/bash

#
# Install Docker on WSL (Windows10 1803)
#

sudo apt update
sudo apt upgrade -y
sudo apt install -y docker.io
sudo apt install -y zfsutils-linux  cgroup-bin cgroup-lite cgroup-tools cgroupfs-mount libcgroup1

sudo usermod -aG docker $USER

sudo cgroupfs-mount
sudo service docker start

exit 0

