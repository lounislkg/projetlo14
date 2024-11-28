#!/bin/bash

source ./modules/parser.sh

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

# Loop to check the time and execute the task contained in the file
while true; do
    current_time=$(date "+%M %H %d %m %w")
    for file in "${files[@]}"; do
        if [ -f "$file" ]; then
            IFS=$'\n'
            for line in $(cat $file); do
                #parse every line and return the command to execute
                parser "$line"
            done
        fi
    done

    sleep 15  # Attendre trente secondes
    #update files if there's new files in /etc/pcron
    get_files
done