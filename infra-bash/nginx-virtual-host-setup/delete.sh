#!/bin/bash

RED='\033[0;31m'  # Red colored text
NC='\033[0m'      # Normal text
YELLOW='\033[33m'  # Yellow Color
GREEN='\033[32m'   # Green Color

# Check if script is run as root
if [ "$EUID" -ne 0 ]; then
    echo "Please run as root or use sudo."
    exit 1
fi

# Define variables
DOMAIN="saranya6.mnsp.co.in"
WEB_ROOT="/home/saranya6mnspcoin/public_html"
AVAILABLE_DIR="/etc/nginx/sites-available"
ENABLED_DIR="/etc/nginx/sites-enabled"
CONFIG_FILE="$AVAILABLE_DIR/$DOMAIN.conf"
SYMLINK="$ENABLED_DIR/$DOMAIN"

# Remove the symbolic link
echo -e "${YELLOW}...removing the symbolic link${NC}"
if [ -e "$SYMLINK" ]; then
    rm "$SYMLINK"
else
    echo -e "${RED}symbolic link not found.${NC}"
fi

# Remove the virtual host configuration file
echo -e "${YELLOW}...removing the virtual host configuration file${NC}"
if [ -e "$CONFIG_FILE" ]; then
    rm "$CONFIG_FILE"
else
    echo -e "${RED}virtual host configuration file not found.${NC}"
fi

# Remove the web root directory
echo -e "${YELLOW}...removing the web root directory${NC}"
if [ -d "$WEB_ROOT" ]; then
    rm -r "$WEB_ROOT"
else
    echo -e "${RED}web root directory not found.${NC}"
fi

# Reload Nginx to apply changes
if ! sudo nginx -t; then
    echo -e "${RED}syntax error in nginx${NC}"
    exit 1
fi

if ! sudo systemctl reload nginx; then
    echo -e "${RED}Failed to reload Nginx.${NC}"
    exit 1
fi

echo "Reverted setup for $DOMAIN successfully."
