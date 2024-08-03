#!/bin/bash

RED='\033[0;31m'    # Red colored text
NC='\033[0m'        # Normal text
YELLOW='\033[33m'   # Yellow Color
GREEN='\033[32m'    # Green Color

# Check if Certbot and its Nginx plugin are installed before uninstalling
if ! dpkg -l | grep -q "certbot\|python3-certbot-nginx"; then
    echo -e "${YELLOW}Certbot and its Nginx plugin are not installed.${NC}"
    exit 0
fi

echo -e "${YELLOW}...Uninstalling Certbot and its Nginx plugin${NC}"
if ! sudo apt remove --purge -y certbot python3-certbot-nginx; then
    echo -e "${RED}Removing Certbot failed.${NC}"
    exit 1
fi

echo -e "${YELLOW}...Verify Nginx configuration${NC}"
if ! sudo nginx -t; then
    echo -e "${RED}Nginx configuration syntax is not correct.${NC}"
    exit 1
fi

echo -e "${YELLOW}...Reload Nginx to apply changes${NC}"
if ! sudo systemctl reload nginx; then
    echo -e "${RED}Nginx reload failed.${NC}"
    exit 1
fi

echo -e "${GREEN}Reverted changes. Certbot and its Nginx plugin are uninstalled.${NC}"

# Improved method to obtain the public IP address
ip_service="ifconfig.me/ip"  # or "ipecho.net/plain"

public_ip=$(curl -sS "$ip_service")
echo $public_ip

# public_ip=$(curl -sS ifconfig.co)

response=$(curl -IsS --max-time 5 "http://$public_ip" | head -n 1)

if [[ "$response" == *"200 OK"* ]]; then
    echo -e "${GREEN}Website is reachable.${NC}"
else
    echo -e "${RED}Website is not reachable or returned a non-OK status.${NC}"
fi

echo -e "${GREEN}Script executed successfully for removing Certbot.${NC}"
