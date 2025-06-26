#!/bin/bash

# Elevate to root once at the beginning
if [ "$(id -u)" -ne 0 ]; then
    sudo -v # Cache credentials
    exec sudo "$0" "$@" # Re-run as root
    exit 1
fi

# Now running as root - no more sudo needed
SCRIPT_DIR="/home/$SUDO_USER/Downloads/Cyberpatriot-scripts-main/Linux"

# Make scripts executable
chmod +x "$SCRIPT_DIR/"*.sh

# Install dbus-x11 (for opening new terminals)
apt install -y dbus-x11

# Enable firewall
ufw enable >/dev/null 2>&1

# Function to run commands in new terminal
run_as_user() {
    local cmd="cd '$SCRIPT_DIR' && ./$1"
    gnome-terminal -- bash -c "su $SUDO_USER -c '$cmd'; exec bash"
}

# Prompts
read -p "Run update.sh? (y/n): " yn
[[ $yn =~ [Yy] ]] && run_as_user "update.sh"

read -p "Change all passwords? (y/n): " yn
[[ $yn =~ [Yy] ]] && run_as_user "change_passwords.sh"

read -p "Rectify users? (y/n): " yn
[[ $yn =~ [Yy] ]] && run_as_user "user_rectifier.sh"

# Clean up
apt remove -y dbus-x11