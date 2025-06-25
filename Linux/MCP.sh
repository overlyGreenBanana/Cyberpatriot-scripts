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
cd Downloads/Linux
read -p "Do you want to run update.sh? (y/n): " yn

case $yn in
    [Yy]* ) echo "Proceeding..."; gnome-terminal -- bash -c "./update.sh" || echo "Failed to run update.sh. You are likely not in the correct directory." >&2; exit 1;;
    [Nn]* ) echo "Exiting..."; exit;;
    * ) echo "Invalid response. Please answer y or n.";;
esac

