#!/bin/bash

sudo raspi-config nonint do_change_locale      ja_JP.UTF-8
sudo raspi-config nonint do_change_timezone    Asia/Tokyo
sudo raspi-config nonint do_configure_keyboard jp
sudo raspi-config nonint do_wifi_country       JP

sudo reboot
