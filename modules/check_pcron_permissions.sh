# Variables
ALLOW_FILE="/etc/pcron.allow"
DENY_FILE="/etc/pcron.deny"
user=$(whoami) 

# Create /etc/pcron.allow if it does not exist
if [ ! -f "$ALLOW_FILE" ]; then
    touch "$ALLOW_FILE"
    chmod 600 "$ALLOW_FILE"
    echo "root" > "$ALLOW_FILE"
else
    # Check if root is already in the file
    if ! grep -q "^root$" "$ALLOW_FILE"; then
        echo "Adding root to $ALLOW_FILE..."
        echo "root" >> "$ALLOW_FILE"
    fi
fi

# Create /etc/pcron.deny if it does not exist
if [ ! -e $DENY_FILE ]; then
    touch $DENY_FILE
    chmod 600 $DENY_FILE
fi
while IFS=: read -r user _; do
    # Si l'utilisateur n'est pas dans la liste des autorisés, ajoutez-le dans deny
    if [ ! grep -qw "$user" "$ALLOW_FILE" ]; then
        echo "$user" >> "$DENY_FILE"
    fi
done

if groups "$user" | grep -q "\broot\b"; then
    if grep -q "^$user$" /etc/pcron.deny; then
        echo "User $user is in root group but explicitly denied access to pcron."
        exit 1
    fi
    echo "User $user is in root group and allowed to use pcron."
    pcron "$@"
elif grep -q "^$user$" /etc/pcron.allow; then
    echo "User $user is allowed to use pcron based on /etc/pcron.allow."
    pcron "$@"
else
    echo "User $user is not allowed to use pcron."
    exit 1
fi

if grep -q "^$user$" /etc/pcron.deny; then
    echo "User $user is explicitly denied access to pcron."
    exit 1
fi
