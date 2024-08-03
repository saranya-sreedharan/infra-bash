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
CONFIG_FILE="$AVAILABLE_DIR/$DOMAIN"
SYMLINK="$ENABLED_DIR/$DOMAIN"

# Enable SSL
echo -e "${YELLOW}...enabling SSL${NC}"
certbot certonly --webroot -w "/home/saranya6mnspcoin/public_html" -d "$DOMAIN" -n --agree-tos --email admin@saranya6.mnsp.co.in

# Update virtual host configuration for SSL
echo -e "${YELLOW}...updating virtual host configuration for SSL${NC}"
cat <<EOL > "$CONFIG_FILE"
server {
    listen 80;
    listen [::]:80;
    server_name $DOMAIN www.$DOMAIN;

    return 301 https://\$host\$request_uri;
}

server {
    listen 443 ssl;
    listen [::]:443 ssl;
    server_name $DOMAIN www.$DOMAIN;

    ssl_certificate /etc/letsencrypt/live/$DOMAIN/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/$DOMAIN/privkey.pem;
    include /etc/letsencrypt/options-ssl-nginx.conf;
    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem;

    root /home/saranya6mnspcoin/public_html;
    index index.html index.htm;

    location / {
        try_files \$uri \$uri/ =404;
    }

    error_page 404 /404.html;
    error_page 500 502 503 504 /50x.html;
    location = /50x.html {
        root /usr/share/nginx/html;
    }

    access_log /var/log/nginx/$DOMAIN.access.log;
    error_log /var/log/nginx/$DOMAIN.error.log;
}
EOL

# Create a symbolic link to enable the site
echo -e "${YELLOW}...creating symbolic link to enable the site${NC}"
if ! ln -s "$CONFIG_FILE" "$SYMLINK"; then
    echo -e "${RED}failed to create link to enable the site.${NC}"
    exit 1
fi

# Reload Nginx to apply changes
if ! systemctl reload nginx; then
    echo -e "${RED}Failed to reload Nginx.${NC}"
    exit 1
fi

echo "SSL enabled for $DOMAIN successfully."

# Revert SSL
echo -e "${YELLOW}...reverting SSL${NC}"

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

# Reload Nginx to apply changes
if ! systemctl reload nginx; then
    echo -e "${RED}Failed to reload Nginx.${NC}"
    exit 1
fi

echo "SSL reverted for $DOMAIN successfully."
