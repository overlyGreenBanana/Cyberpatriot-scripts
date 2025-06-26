#!/bin/bash


# Function to validate usernames
validate_username() {
    local username=$1
    if [[ ! "$username" =~ ^[a-z_][a-z0-9_-]*$ ]]; then
        echo "Invalid username: $username" >&2
        return 1
    fi
    return 0
}

# Get authorized users
echo "Enter authorized regular users (space-separated list):"
read -a authorized_users

# Get authorized admins
echo "Enter authorized admin users (space-separated list):"
read -a authorized_admins

# Verify all usernames are valid
for user in "${authorized_users[@]}" "${authorized_admins[@]}"; do
    if ! validate_username "$user"; then
        echo "Aborting due to invalid username."
        exit 1
    fi
done

# Combine all authorized users (both regular and admin)
all_authorized=("${authorized_users[@]}" "${authorized_admins[@]}")

# Get all existing human users (UID >= 1000, excluding nobody)
existing_users=($(awk -F: '$3 >= 1000 && $1 != "nobody" {print $1}' /etc/passwd))

# Process unauthorized users (exist but not in authorized lists)
for user in "${existing_users[@]}"; do
    if [[ ! " ${all_authorized[@]} " =~ " $user " ]]; then
        echo "Removing unauthorized user: $user"
        # Remove user from admin groups first
        for group in $(groups "$user" | cut -d: -f2); do
            if [[ "$group" == "sudo" || "$group" == "admin" ]]; then
                deluser "$user" "$group" >/dev/null
            fi
        done
        # Delete the user and their home directory
        userdel -r "$user" 2>/dev/null
    fi
done

# Process authorized regular users
for user in "${authorized_users[@]}"; do
    # Check if user exists
    if id "$user" &>/dev/null; then
        # User exists, remove from admin groups if present
        if groups "$user" | grep -q '\bsudo\b'; then
            echo "Removing admin privileges from: $user"
            deluser "$user" sudo >/dev/null
        fi
        if groups "$user" | grep -q '\badmin\b'; then
            echo "Removing admin privileges from: $user"
            deluser "$user" admin >/dev/null
        fi
    else
        # User doesn't exist, create them
        echo "Creating regular user: $user"
        adduser --disabled-password --gecos "" "$user" >/dev/null
    fi
done

# Process authorized admin users
for user in "${authorized_admins[@]}"; do
    # Check if user exists
    if id "$user" &>/dev/null; then
        # User exists, ensure they're in sudo group
        if ! groups "$user" | grep -q '\bsudo\b'; then
            echo "Adding admin privileges to: $user"
            usermod -aG sudo "$user"
        fi
    else
        # User doesn't exist, create them with admin privileges
        echo "Creating admin user: $user"
        adduser --disabled-password --gecos "" "$user" >/dev/null
        usermod -aG sudo "$user"
    fi
done

echo "User permission management completed."