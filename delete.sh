#!/bin/bash
#remove the pcron service
sudo systemctl stop pcron
sudo systemctl disable pcron
sudo rm /etc/systemd/system/pcron.service
sudo rm -rf /etc/pcron/
sudo rm -rf /var/lib/pcron/
sudo rm -rf /var/log/pcron
sudo rm /usr/bin/pcrontab
sudo systemctl daemon-reload