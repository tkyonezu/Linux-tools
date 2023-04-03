#!/bin/bash

sudo apt update
sudo apt install -y fcitx-mozc

im-config -n fcitx

sudo apt install -y fonts-noto-cjk

echo ">>> Automatic Reboot ..."
sudo reboot
