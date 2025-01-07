#!/bin/bash


# Check if the script has root permissions
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root" 1>&2
    exit 1
fi

# Chek if the directory /etc/pcron/ exists
if [ ! -d "/etc/pcron" ]; then
    mkdir "/etc/pcron"
    chmod 1777 "/etc/pcron"
fi

# Create the directory /var/lib/pcron/
if [ ! -d "/var/lib/pcron" ]; then
    mkdir "/var/lib/pcron"
    chmod 751 "/var/lib/pcron"
fi

# Create the directory /etc/pcron/modules
if [ ! -d "/var/lib/pcron/modules" ]; then
    mkdir "/var/lib/pcron/modules"
    chmod 751 "/var/lib/pcron/modules"
fi


# Check if the files /etc/pcron.allow and /etc/pcron.deny exist
if [ ! -f "/etc/pcron/pcron.allow" ]; then
    touch "/etc/pcron.allow"
    chmod 755 "/etc/pcron.allow"
    echo "root" > "/etc/pcron.allow"
fi 

if [ ! -f "/etc/pcron.deny" ]; then
    touch "/etc/pcron.deny"
    chmod 755 "/etc/pcron.deny"
fi

# Check if the file /var/log/pcron exists
if [ ! -f "/var/log/pcron" ]; then
    touch "/var/log/pcron"
    chmod 750 "/var/log/pcron"
fi


#ajouter les scripts de pcron
cp ./pcrontab /var/lib/pcron/
chown root:root /var/lib/pcron/pcrontab
chmod 755 /var/lib/pcron/pcrontab


#ajouter le script task_exec.sh
cp ./task_exec.sh /var/lib/pcron
chown root:root /var/lib/pcron/task_exec.sh
chmod 770 /var/lib/pcron/task_exec.sh

#ajouter les modules
#ajouter permission.sh
cp ./modules/permission.sh /var/lib/pcron/modules/
chown root:root /var/lib/pcron/modules/permission.sh
chmod 755 /var/lib/pcron/modules/permission.sh

#ajouter parser.sh
cp ./modules/parser.sh /var/lib/pcron/modules/
chown root:root /var/lib/pcron/modules/parser.sh
chmod 750 /var/lib/pcron/modules/parser.sh

#ajouter un service pour pcron
cp ./pcron.service /etc/systemd/system/pcron.service

#créer un lien de pcron dans /usr/bin
ln -s /var/lib/pcron/pcrontab /usr/bin/pcrontab

systemctl daemon-reload
systemctl enable pcron
systemctl start pcron
echo "Installation complete"
exit 0