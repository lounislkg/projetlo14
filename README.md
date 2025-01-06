
# Projetlo14

Projet scolaire visant a refaire un programmateur de tache qui ressemble à cron

# Usage

  

Use `pcrontab -e` to open your personnal file to set up tasks.

View them with `pcrontab -l`.

Delete your file with `pcrontab -r`

  

Use `pcrontab [-u <user>] { -l | -e | -r }` to edit files of a particular user.

  

# Installation

## 0. Clone the project

`git clone <url>`

  

## 1. Install the project

You'll need *superuser* permission to install **pcron**

  

```

>cd ./projetlo14

>sudo bash installer.sh

```

## 2. Add a user to pcron

By default the only user allowed to use pcron is root.

After the installation you'll have to edit the file **/etc/pcron.allow** to add user that are allowed to use pcron and the file **/etc/pcron.deny** to add user that are not allowed to use pcron

```

root

John Doe

Bob

Alice

```

# Logs

You can find logs in **/var/log/pcron**. This file is only readable by root users.