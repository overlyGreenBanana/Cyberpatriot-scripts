#!/bin/bash

# Check if script is run as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root"
   exit 1
fi

# Debian/Ubuntu
update_debian() {
    echo "Detected Debian/Ubuntu-based system"
    apt update
    apt upgrade -y
    apt dist-upgrade -y
    apt autoremove -y
    apt autoclean
}

# fedora
update_fedora() {
    echo "Detected Fedora-based system"
    dnf upgrade --refresh -y
    dnf autoremove -y
}

# yum
update_yum() {
    echo "Detected yum-based system"
    yum update -y
    yum autoremove -y
}

# zypper
update_zypper() {
    echo "Detected openSUSE-based system"
    zypper refresh
    zypper update -y
}

# Check for package manager and run appropriate update function
if command -v apt >/dev/null 2>&1; then
    update_debian
elif command -v dnf >/dev/null 2>&1; then
    update_fedora
elif command -v yum >/dev/null 2>&1; then
    update_yum
elif command -v zypper >/dev/null 2>&1; then
    update_zypper
else
    echo "No supported package manager found (apt, dnf, yum, or zypper)"
    exit 1
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
