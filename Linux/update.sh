#!/bin/bash

# Check if script is run as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root"
   exit 1
fi

# Debian/Ubuntu
    echo "Detected Debian/Ubuntu-based system"
    apt update
    apt upgrade -y
    apt dist-upgrade -y
    apt autoremove -y
    apt autoclean



fi

# snap
if command -v snap >/dev/null 2>&1; then
    echo "Updating snap packages"
    snap refresh
fi

# flatpak
if command -v flatpak >/dev/null 2>&1; then
    echo "Updating flatpak packages"
    flatpak update -y
fi

echo "Software update completed!"

# Close the terminal
if [[ -t 1 ]]; then
    sleep 2
    kill -HUP $PPID
fi

exit 0
