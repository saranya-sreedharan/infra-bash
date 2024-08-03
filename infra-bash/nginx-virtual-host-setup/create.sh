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
SUSPENDED_DIR="/etc/nginx/sites-suspended"
CONFIG_FILE="$AVAILABLE_DIR/$DOMAIN.conf"
SYMLINK="$ENABLED_DIR/$DOMAIN"

# Create the web root directory
echo -e "${YELLOW}...creating the web_root directory${NC}"
if ! mkdir -p "$WEB_ROOT"; then
 echo -e "${RED}failed create the directory.${NC}"
 exit 1
fi

echo -e "${YELLOW}...creating the basic html page${NC}"
# Create a basic HTML file for testing
echo "<html><head><title>Welcome to $DOMAIN</title></head><body><h1>Success! $DOMAIN is working!</h1></body></html>" > "$WEB_ROOT/index.html"

echo -e "${YELLOW}...Creating the virtual host.${NC}"
# Create the virtual host configuration file in sites-available
cat <<EOL > "$CONFIG_FILE"
server {
    listen 80;
    server_name $DOMAIN www.$DOMAIN;

    root $WEB_ROOT;
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
if ! ln -s "$CONFIG_FILE" "$SYMLINK"; then
 echo -e "${RED}failed to create link to enable the site.${NC}"
 exit 1
fi

if ! sudo nginx -t; then
 echo -e "${RED} syntax error in nginx${NC}"
 exit 1
fi
# Reload Nginx to apply changes
if ! sudo systemctl reload nginx; then
 echo -e "${YELLOW}...Failed to restart the nginx.${NC}"
 exit 1
fi
echo "Virtual host for $DOMAIN has been set up successfully."
