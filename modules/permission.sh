# Variables
ALLOW_FILE="/etc/pcron.allow"
DENY_FILE="/etc/pcron.deny"
user=$(whoami) 

# Read the file /etc/pcron.allow and check if the user is allowed to use pcron
if [ -f "$ALLOW_FILE" ]; then
    while IFS= read -r line
    do
        if [ "$line" = "$user" ]; then
            exit 0
        fi
    done < "$ALLOW_FILE"  
fi

# Read the file /etc/pcron.deny and check if the user is denied to use pcron
if [ -f "$DENY_FILE" ]; then
    while IFS= read -r line
    do
        if [ "$line" = "$user" ]; then
            echo "User $user is explicitly denied access to pcron."
            exit 1
        fi
    done < "$DENY_FILE"
fi

exit 2