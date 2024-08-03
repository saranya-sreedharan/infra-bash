#!/bin/bash

set -e

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
AVAILABLE_DIR="/etc/nginx/sites-available"
ENABLED_DIR="/etc/nginx/sites-enabled"
CONFIG_FILE="$AVAILABLE_DIR/$DOMAIN.conf"
SYMLINK="$ENABLED_DIR/$DOMAIN"

# Remove SSL configuration
echo -e "${YELLOW}...removing SSL configuration${NC}"
if [ -e "$CONFIG_FILE" ]; then
    rm "$CONFIG_FILE"
else
    echo -e "${RED}virtual host configuration file not found.${NC}"
fi

# Remove symbolic link
echo -e "${YELLOW}...removing symbolic link${NC}"
if [ -e "$SYMLINK" ]; then
    rm "$SYMLINK"
else
    echo -e "${RED}symbolic link not found.${NC}"
fi

# Remove SSL certificates obtained by Certbot
echo -e "${YELLOW}...removing SSL certificates obtained by Certbot${NC}"
certbot revoke --cert-path "/etc/letsencrypt/live/$DOMAIN/fullchain.pem"
certbot delete --cert-name "$DOMAIN"


# Remove the symbolic link for saranya6.mnsp.co.in
echo -e "${YELLOW}...removing the symbolic link for $DOMAIN${NC}"
if [ -e "$ENABLED_DIR/$DOMAIN" ]; then
    rm -rf "$ENABLED_DIR/$DOMAIN"
    echo -e "${GREEN}Symbolic link for $DOMAIN removed successfully.${NC}"
else
    echo -e "${RED}Symbolic link for $DOMAIN not found.${NC}"
fi


# Reload Nginx to apply changes
if ! systemctl reload nginx; then
    echo -e "${RED}Failed to reload Nginx.${NC}"
    exit 1
fi

echo "SSL reverted for $DOMAIN successfully."
