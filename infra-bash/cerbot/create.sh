#!/bin/bash
RED='\033[0;31m'  # Red colored text
NC='\033[0m'      # Normal text
YELLOW='\033[33m'  # Yellow Color
GREEN='\033[32m'   # Green Color

echo -e "${YELLOW}...Installing Certbot and its Nginx plugin${NC}"
if ! sudo apt install -y certbot python3-certbot-nginx; then 
    echo -e "${RED}Package installation failed.${NC}"
    echo -e "${RED}Please check the error message above for more details.${NC}"
    exit 1
fi


echo -e "${YELLOW}...Verify Nginx configuration${NC}"
if ! sudo nginx -t; then
    echo -e "${RED}nginx syntax is not correct${NC}\n"
    exit 1
fi

echo -e "${YELLOW}...Reload Nginx to apply changes${NC}"
if ! sudo systemctl reload nginx; then
    echo -e "${RED}nginx reload failed${NC}\n"
    exit 1
fi


ip_service="ifconfig.me/ip"  # or "ipecho.net/plain"

public_ip=$(curl -sS "$ip_service")

response=$(curl -IsS --max-time 5 "http://$public_ip" | head -n 1)

if [[ "$response" == *"200 OK"* ]]; then
  echo -e "${GREEN}Website is reachable.${NC}"
else
  echo -e "${RED}Website is not reachable or returned a non-OK status.${NC}"
fi
echo -e "${GREEN}Script executed successfully for installing certbot.${NC}"