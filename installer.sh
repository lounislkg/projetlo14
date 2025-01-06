#!/bin/bash


#check if the script has root permissions
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root" 1>&2
    exit 1
fi

#chek if the directory /etc/pcron/ exists
if [ ! -d "/etc/pcron" ]; then
    mkdir "/etc/pcron"
    chmod 771 "/etc/pcron"
fi

#create the directory /var/lib/pcron/
if [ ! -d "/var/lib/pcron" ]; then
    mkdir "/var/lib/pcron"
    chmod 775 "/var/lib/pcron"
fi

#create the directory /etc/pcron/modules
if [ ! -d "/var/lib/pcron/modules" ]; then
    mkdir "/var/lib/pcron/modules"
    chmod 775 "/var/lib/pcron/modules"
fi


#check if the files /etc/pcron.allow and /etc/pcron.deny exist
if [ ! -f "/etc/pcron/pcron.allow" ]; then
    touch "/etc/pcron.allow"
    chmod 774 "/etc/pcron.allow"
    echo "root" > "/etc/pcron.allow"
fi 

if [ ! -f "/etc/pcron.deny" ]; then
    touch "/etc/pcron.deny"
    chmod 774 "/etc/pcron.deny"
fi

#check if the file /var/log/pcron exists
if [ ! -f "/var/log/pcron" ]; then
    touch "/var/log/pcron"
    chmod 770 "/var/log/pcron"
fi


#ajouter les scripts de pcron
cp ./pcrontab /var/lib/pcron/
chmod 775 /var/lib/pcron/pcrontab
chown root:root /var/lib/pcron/pcrontab

#ajouter le script task_exec.sh
cp ./task_exec.sh /var/lib/pcron
chown root:root /var/lib/pcron/task_exec.sh
chmod 771 /var/lib/pcron/task_exec.sh
 
for file in ./modules/*; do
    cp $file /var/lib/pcron/modules/
    file_basename=$(basename $file)
    chown root:root /var/lib/pcron/modules/$file_basename
    chmod 775 /var/lib/pcron/modules/$file_basename
done


#ajouter un service pour pcron
cp ./pcron.service /etc/systemd/system/pcron.service

#créer un lien de pcron dans /usr/bin
ln -s /var/lib/pcron/pcrontab /usr/bin/pcrontab


systemctl daemon-reload
systemctl enable pcron
systemctl start pcron
echo "Installation complete"
exit 0