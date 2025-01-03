#check if the script has root permissions
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root" 1>&2
    exit 1
fi

#chek if the directory /etc/pcron/ exists
if [ ! -d "/etc/pcron" ]; then
    mkdir "/etc/pcron"
    chmod 770 "/etc/pcron"
fi

#create the directory /usr/bin/pcron/
if [ ! -d "/use/bin/pcron" ]; then
    mkdir "/usr/bin/pcron"
    chmod 770 "/usr/bin/pcron"
fi

#create the directory /usr/bin/pcron/modules
if [ ! -d "/use/bin/pcron/modules" ]; then
    mkdir "/usr/bin/pcron/modules"
    chmod 770 "/usr/bin/pcron/modules"
fi

#check if the files /etc/pcron.allow and /etc/pcron.deny exist
if [ ! -f "/etc/pcron/pcron.allow" ]; then
    touch "/etc/pcron/pcron.allow"
    chmod 770 "/etc/pcron/pcron.allow"
    echo "root" > "/etc/pcron/pcron.allow"
fi 

if [ ! -f "/etc/pcron/pcron.deny" ]; then
    touch "/etc/pcron/pcron.deny"
    chmod 770 "/etc/pcron/pcron.deny"
fi

#check if the file /var/log/pcron exists
if [ ! -f "/var/log/pcron" ]; then
    touch "/var/log/pcron"
    chmod 770 "/var/log/pcron"
fi


#ajouter les scripts de pcron
cp ./pcrontab /usr/bin/pcron

#ajouter le script task_exec.sh
cp ./task_exec.sh /usr/bin/pcron
chown root:root /usr/bin/pcron/task_exec.sh
chmod 700 /usr/bin/pcron/task_exec.sh
 
for file in ./modules/*; do
    # echo $file
    cp $file /usr/bin/pcron/modules/
    chown root:root /usr/bin/pcron/modules/$file
    chmod 700 /usr/bin/pcron/modules/$file
done


#ajouter un service pour pcron
cp ./pcron.service /etc/systemd/system/pcron.service

systemctl daemon-reload
systemctl enable pcron
systemctl start pcron
echo "Installation complete"
exit 0