# projetlo14
 Projet scolaire visant a refaire un programmateur de tache qui ressemble à cron
# Usage
## 1. Install the project 
    `sudo bash installer.sh`
## 2. Add a user to pcron
    By default the only user allowed to use pcron is root.
    After the installation you'll have to edit the file **/etc/pcron.allow** to add user that are allowed to use pcron and the file **/etc/pcron.deny** to add user that are not allowed to use pcron
    ```
        root
        John Doe
        Bob
        Alice
    ```
## Logs
    You can find logs in **/var/log/pcron**. This file is only readable by root users.