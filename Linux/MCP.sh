#!/bin/bash

#enable firewall
sudo ufw enable

read -p "Do you want to run update.sh? (y/n): " yn

case $yn in
    [Yy]* ) echo "Proceeding...";;
    [Nn]* ) echo "Exiting..."; exit;;
    * ) echo "Invalid response. Please answer y or n.";;
esac

