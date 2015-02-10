#!/bin/bash
sudo apt-get remove --purge -y bcmwl-kernel-source &&
sudo apt-get install -y linux-firmware-nonfree &&
sudo modprobe b43 &&
sudo su -c "echo 'b43' >> /etc/modules"
