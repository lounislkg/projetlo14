# Variables
ALLOW_FILE="/etc/pcron.allow"
DENY_FILE="/etc/pcron.deny"
user=$(whoami) 

if grep -q "^$user$" /etc/pcron.deny; then
    echo "User $user is explicitly denied access to pcron."
    exit 1
fi

if groups "$user" | grep -q "\broot\b"; then
    if grep -q "^$user$" /etc/pcron.deny; then
        echo "User $user is in root group but explicitly denied access to pcron."
        exit 1
    fi
    echo "User $user is in root group and allowed to use pcron."
    exit 0
elif grep -q "^$user$" /etc/pcron.allow; then
    echo "User $user is allowed to use pcron based on /etc/pcron.allow."
    exit 0
else
    echo "User $user is not allowed to use pcron. Ask the system administrator to add you to /etc/pcron.allow."
    exit 1
fi