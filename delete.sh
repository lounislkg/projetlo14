#!/bin/bash
#remove the pcron service

# Check if the script has root permissions
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root" 1>&2
    exit 1
fi

sudo systemctl stop pcron
sudo systemctl disable pcron
sudo rm /etc/systemd/system/pcron.service
sudo rm -rf /etc/pcron/
sudo rm pcron.allow pcron.deny
sudo rm -rf /var/lib/pcron/
sudo rm -rf /var/log/pcron
sudo rm /usr/bin/pcrontab
sudo systemctl daemon-reload