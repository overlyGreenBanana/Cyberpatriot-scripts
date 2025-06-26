#!/bin/bash

# Check if script is run as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" >&2
   exit 1
fi

# Get the user running the script (sudo user or root)
CURRENT_USER=$(logname 2>/dev/null || echo "$SUDO_USER")

# Log file for new passwords (restricted permissions)
LOGFILE="/root/user_passwords_$(date +%F_%H-%M-%S).log"
touch "$LOGFILE"
chmod 600 "$LOGFILE"

# Function to generate a secure random password
generate_password() {
    # 16 characters, including letters, numbers, and symbols
    tr -dc 'A-Za-z0-9!@#$%^&*()_+' < /dev/urandom | head -c 16
}

# Fixed password for root and current user
FIXED_PASSWORD="112358UtherPendragon"

# Change password for root
if echo "root:$FIXED_PASSWORD" | chpasswd; then
    echo "Changed password for root"
    echo "root:$FIXED_PASSWORD" >> "$LOGFILE"
else
    echo "Failed to change password for root" >&2
fi

# Change password for current user if not root
if [[ "$CURRENT_USER" != "root" && -n "$CURRENT_USER" ]]; then
    if echo "$CURRENT_USER:$FIXED_PASSWORD" | chpasswd; then
        echo "Changed password for $CURRENT_USER"
        echo "$CURRENT_USER:$FIXED_PASSWORD" >> "$LOGFILE"
    else
        echo "Failed to change password for $CURRENT_USER" >&2
    fi
fi

# Get list of users with valid login shells
USERS=$(awk -F: '$7 !~ /nologin|false/ {print $1}' /etc/passwd)

# Counter for changed passwords
changed=0

# Loop through each user to change their password, excluding root and current user
for user in $USERS; do
    # Skip root and current user
    if [[ "$user" != "$CURRENT_USER" && "$user" != "root" ]]; then
        # Skip system users (UID < 1000)
        uid=$(id -u "$user")
        if [[ $uid -ge 1000 ]]; then
            NEW_PASSWORD=$(generate_password)
            if echo "$user:$NEW_PASSWORD" | chpasswd; then
                echo "Changed password for $user"
                echo "$user:$NEW_PASSWORD" >> "$LOGFILE"
                ((changed++))
            else
                echo "Failed to change password for $user" >&2
            fi
        fi
    fi
done

# Summary
echo "Password change completed. Changed $changed user passwords (plus root and current user)."
echo "New passwords are stored in $LOGFILE"