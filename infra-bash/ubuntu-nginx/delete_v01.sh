#!/bin/bash

RED='\033[0;31m'  # Red colored text
NC='\033[0m'      # Normal text
YELLOW='\033[33m'  # Yellow Color
GREEN='\033[32m'   # Green Color

echo -e "${YELLOW}...Check if Nginx is running${NC}"
if pgrep -x "nginx" > /dev/null
then
    # Nginx is running, stop it
    echo -e "${YELLOW}...Stopping Nginx${NC}"
    if ! sudo systemctl stop nginx; then
        echo -e "${RED}Failed to stop nginx.${NC}"
        exit 1
    fi

    # Purge Nginx
    echo -e "${YELLOW}...Purging Nginx${NC}"
    if ! sudo apt-get purge nginx* -y; then
        echo -e "${RED}Nginx purge failed.${NC}"
        exit 1
    fi
    
    sudo apt-get autoremove -y
    sudo rm -rf /etc/nginx
    
    
    
else
    # Nginx is not running
    if dpkg -l | grep -q "nginx"
    then
        # Nginx is installed but not running
        echo -e "${YELLOW}...Nginx is not running, but it is installed. Purging Nginx${NC}"
        sudo apt-get purge nginx* -y
        sudo apt-get autoremove -y
        sudo rm -rf /etc/nginx
        echo -e "${GREEN}...Nginx purged successfully.${NC}"
    else
        # Nginx is not installed
        echo -e "${YELLOW}...Nginx is not present. Nothing to delete.${NC}"
    fi
fi
echo -e "${GREEN}The script executed successfully for uninstalling Nginx.${NC}"
