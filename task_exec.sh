#!/bin/bash

source /var/lib/pcron/modules/parser.sh

#verifier que le fichier de log existe
if [ ! -f /var/log/pcron ]; then
    touch /var/log/pcron
    #limit access to root
    chmod 770 /var/log/pcron
fi

#fonction pour récuperer les fichiers dans /etc/pcron
function get_files {
    files=()
    
    for file in /etc/pcron/pcrontab*; do
        if [[ ! " ${files[@]} " =~ " ${file} " ]]; then
            files+=("$file")
        fi
    done
    echo "Files: ${files[@]}"
}

get_files

#loop to check the time and execute the task contained in the file
while true; do
    current_time=$(date "+%M %H %d %m %w")
    for file in "${files[@]}"; do
        if [ -f "$file" ]; then
            IFS=$'\n'
            for line in $(cat $file); do
                #parse every line and return the command to execute
                parser "$line"
                if [ "$is_task_to_execute" = true ]; then
                    echo "This task : $task_to_execute was executed at $(date) by $(basename $file)" >> /var/log/pcron
                    #switch uid to the owner of the file
                    owner=$(stat -c %U $file)
                    res=$(sudo -u "$owner" bash -c "$task_to_execute")
                    #switch back to root
                    echo "Pcron : $res"   
                    echo "Result : $res" >> /var/log/pcron
                fi
                
            done
        fi
    done

    sleep 15  # Attendre trente secondes
    #update files if there's new files in /etc/pcron
    get_files
done