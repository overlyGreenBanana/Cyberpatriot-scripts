#!/bin/bash

# Check if script is run as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" >&2
   exit 1
fi
#allows for opening of new shells
sudo apt install dbus-x11
#enable firewall in another window so this script keeps running
gnome-terminal -- bash -c "sudo ufw enable"
#navigates to the correct directory, downloads/linux.
cd ~
cd Downloads/Cyberpatriot-scripts-main/Linux
sudo chmod +x ./update.sh
sudo chmod +x ./change_passwords.sh
read -p "Do you want to run update.sh? (y/n): " yn

case $yn in
    [Yy]* ) echo "Proceeding..."; gnome-terminal -- bash -c "sudo ./update.sh" || echo "Failed to run update.sh. You are likely not in the correct directory." >&2;;
    [Nn]* ) echo "Exiting...";;
    * ) echo "Invalid response. Please answer y or n.";;
esac

read -p "Do you want to change all passwords? (y/n): " yn

case $yn in
    [Yy]* ) echo "Proceeding..."; gnome-terminal -- bash -c "sudo ./change_passwords.sh" || echo "Failed to run ./change_passwords.sh You are likely not in the correct directory." >&2;;
    [Nn]* ) echo "Exiting...";;
    * ) echo "Invalid response. Please answer y or n.";;
esac
sudo apt remove dbus-x11
