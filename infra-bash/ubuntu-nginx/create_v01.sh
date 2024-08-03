#!/bin/bash

RED='\033[0;31m'  # Red colored text
NC='\033[0m'      # Normal text
YELLOW='\033[33m'  # Yellow Color
GREEN='\033[32m'   # Green Color

echo -e "${YELLOW}...Update packages${NC}"
if ! sudo apt-get update -y; then
    echo "Failed to update packages."
    exit 1
fi

echo -e "${YELLOW}...verifying nginx installation${NC}"
# Check if Nginx is installed
if [ -x "$(command -v nginx)" ]; then
    echo -e "${GREEN}Nginx is already installed.${NC}"
else
    # Install Nginx
    echo -e "${YELLOW}...Installing Nginx${NC}"
    sudo apt-get install -y nginx
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}Nginx Successfully installed.${NC}"
    else
        echo -e "${RED}Nginx Failed to install.${NC}"
        exit 1
    fi
fi

sudo systemctl start nginx
sudo systemctl enable nginx

ip_service="ifconfig.me/ip"  # or "ipecho.net/plain"

public_ip=$(curl -sS "$ip_service")

response=$(curl -IsS --max-time 5 "http://$public_ip" | head -n 1)

if [[ "$response" == *"200 OK"* ]]; then
  echo -e "${GREEN}Website is reachable.${NC}"
else
  echo -e "${RED}Website is not reachable or returned a non-OK status.${NC}"
fi

echo -e "${GREEN}Script executed successfully for installing nginx.${NC}"