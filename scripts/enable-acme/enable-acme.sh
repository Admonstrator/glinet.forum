#!/bin/sh
#
#
# Description: This script enables ACME support on GL.iNet routers
# Thread: https://forum.gl-inet.com/t/is-there-a-way-to-get-a-letsencrypt-certificate-for-the-factory-ddns-on-the-mt6000/
# Author: Admon
# Update: 2024-03-09
# Date: 2023-12-27
#
# Usage: ./enable-acme.sh [--renew]
# Warning: This script might potentially harm your router. Use it at your own risk.
#

# Functions
create_acme_config() {
    echo "┌────────────────────────────────────────────────────────────────────────┐"
    echo "│ C R E A T I N G   A C M E   C O N F I G U R A T I O N                  │"
    echo "└────────────────────────────────────────────────────────────────────────┘"
    # Delete old ACME configuration file
    echo "Deleting old ACME configuration file for $DDNS_DOMAIN_PREFIX ..."
    uci delete acme.$DDNS_DOMAIN_PREFIX
    uci commit acme
    # Create new ACME configuration file
    echo "Creating ACME configuration file ..."
    uci set acme.@acme[0]=acme
    uci set acme.@acme[0].account_email='acme@glddns.com'
    uci set acme.@acme[0].debug='1'
    uci set acme.$DDNS_DOMAIN_PREFIX=cert
    uci set acme.$DDNS_DOMAIN_PREFIX.enabled='1'
    uci set acme.$DDNS_DOMAIN_PREFIX.use_staging='0'
    uci set acme.$DDNS_DOMAIN_PREFIX.keylength='2048'
    uci set acme.$DDNS_DOMAIN_PREFIX.validation='standalone'
    uci set acme.$DDNS_DOMAIN_PREFIX.update_nginx='1'
    uci set acme.$DDNS_DOMAIN_PREFIX.domains="$DDNS_DOMAIN"
    uci commit acme
    /etc/init.d/acme restart
}

open_firewall() {
    echo "┌────────────────────────────────────────────────────────────────────────┐"
    echo "│ C O N F I G U R I N G   F I R E W A L L                                │"
    echo "└────────────────────────────────────────────────────────────────────────┘"
    if [ "$1" -eq 1 ]; then
        echo "Creating firewall rule to open port 80 on WAN ..."
        uci set firewall.acme=rule
        uci set firewall.acme.dest_port='80'
        uci set firewall.acme.proto='tcp'
        uci set firewall.acme.name='GL-ACME'
        uci set firewall.acme.target='ACCEPT'
        uci set firewall.acme.src='wan'
        uci set firewall.acme.enabled='1'
    else
        echo "Disabling firewall rule to open port 80 on WAN ..."
        uci set firewall.acme.enabled='0'
    fi
    echo "Restarting firewall ..."
    /etc/init.d/firewall restart 2&>/dev/null
    uci commit firewall
}

preflight_check() {
    FIRMWARE_VERSION=$(cut -c1 </etc/glversion)
    PREFLIGHT=0
    echo "┌────────────────────────────────────────────────────────────────────────┐"
    echo "│ C H E C K I N G   P R E R E Q U I S I T E S                            │"
    echo "└────────────────────────────────────────────────────────────────────────┘"
    echo "Checking if prerequisites are met ..."
    if [ "${FIRMWARE_VERSION}" -lt 4 ]; then
        echo -e "\033[31mx\033[0m ERROR: This script only works on firmware version 4 or higher."
        PREFLIGHT=1
    else
        echo -e "\033[32m✓\033[0m Firmware version: $FIRMWARE_VERSION"
    fi
    # Check if public IP address is available
    PUBLIC_IP=$(sudo -g nonevpn curl -s https://api.ipify.org)
    if [ -z "$PUBLIC_IP" ]; then
        echo -e "\033[31mx\033[0m ERROR: Could not get public IP address. Please check your internet connection."
        PREFLIGHT=1
    else
        echo -e "\033[32m✓\033[0m Public IP address: $PUBLIC_IP"
    fi
    DDNS_DOMAIN=$(uci get ddns.glddns.domain)
    DDNS_IP=$(nslookup $DDNS_DOMAIN | grep Address | tail -n 1 | awk '{print $3}')
    if [ -z "$DDNS_IP" ]; then
        echo -e "\033[31mx\033[0m ERROR: DDNS IP address not found. Please enable DDNS first."
        PREFLIGHT=1
    else
        echo -e "\033[32m✓\033[0m Detected DDNS IP address: $DDNS_IP"
    fi
    if [ -z "$DDNS_DOMAIN" ]; then
        echo -e "\033[31mx\033[0m ERROR: DDNS domain name not found. Please enable DDNS first."
        PREFLIGHT=1
    else
        echo -e "\033[32m✓\033[0m Detected DDNS domain name: $DDNS_DOMAIN"
    fi
    # Get only the first part of the domain name
    DDNS_DOMAIN_PREFIX=$(echo $DDNS_DOMAIN | cut -d'.' -f1)
    echo -e "\033[32m✓\033[0m Prefix of the DDNS domain name: $DDNS_DOMAIN_PREFIX"
    # Check if public IP matches DDNS IP
    if [ "$PUBLIC_IP" != "$DDNS_IP" ]; then
        echo -e "\033[31mx\033[0m Public IP does not match DDNS IP!"
        PREFLIGHT=1
    else
        echo -e "\033[32m✓\033[0m Public IP matches DDNS IP."
    fi

    if [ "$PREFLIGHT" -eq "1" ]; then
        echo -e "\033[31mERROR: Prerequisites are not met. Exiting ...\033[0m"
        exit 1
    else
        echo -e "\033[32m✓\033[0m Prerequisites are met."
    fi
}

invoke_intro() {
    echo "┌────────────────────────────────────────────────────────────────────────┐"
    echo "│ GL.iNet router script by Admon 🦭 for the GL.iNET community            │"
    echo "├────────────────────────────────────────────────────────────────────────┤"
    echo "│ WARNING: THIS SCRIPT MIGHT POTENTIALLY HARM YOUR ROUTER!               │"
    echo "│ It's only recommended to use this script if you know what you're doing.│"
    echo "├────────────────────────────────────────────────────────────────────────┤"
    echo "│ This script will enable ACME support on your router.                   │"
    echo "│                                                                        │"
    echo "│ Prerequisites:                                                         │"
    echo "│ 1. You need to have the GL DDNS service enabled.                       │"
    echo "│ 2. The router needs to have a public IPv4 address.                     │"
    echo "└────────────────────────────────────────────────────────────────────────┘"
}

install_prequisites() {
    echo "┌────────────────────────────────────────────────────────────────────────┐"
    echo "│ I N S T A L L I N G   P R E R E Q U I S I T E S                        │"
    echo "└────────────────────────────────────────────────────────────────────────┘"
    echo "Installing luci-app-acme ..."
    opkg update >/dev/null 2>&1
    opkg install luci-app-acme --force-depends >/dev/null 2>&1
}

config_nginx() {
    echo "┌────────────────────────────────────────────────────────────────────────┐"
    echo "│ C O N F I G U R I N G   N G I N X                                      │"
    echo "└────────────────────────────────────────────────────────────────────────┘"
    if [ "$1" -eq 1 ]; then
        echo "Disabling HTTP access to the router ..."
        # Commenting out the HTTP line in nginx.conf
        sed -i 's/listen 80;/#listen 80;/g' /etc/nginx/conf.d/gl.conf
        # Same for IPv6
        sed -i 's/listen \[::\]:80;/#listen \[::\]:80;/g' /etc/nginx/conf.d/gl.conf
    else
        echo "Enabling HTTP access to the router ..."
        # Uncommenting the HTTP line in nginx.conf
        sed -i 's/#listen 80;/listen 80;/g' /etc/nginx/conf.d/gl.conf
        # Same for IPv6
        sed -i 's/#listen \[::\]:80;/listen \[::\]:80;/g' /etc/nginx/conf.d/gl.conf
    fi
    echo "Restarting nginx ..."
    /etc/init.d/nginx restart

}

get_acme_cert(){
    echo "┌────────────────────────────────────────────────────────────────────────┐"
    echo "│ G E T T I N G   A C M E   C E R T I F I C A T E                        │"
    echo "└────────────────────────────────────────────────────────────────────────┘"
    echo "Restarting acme ..."
    /etc/init.d/acme restart
    sleep 5
    /etc/init.d/acme restart
    echo "Checking if certificate was issued ..."
    # Wait for 10 seconds
    sleep 10
    # Check if certificate was issued
    if [ -f "/etc/acme/$DDNS_DOMAIN/fullchain.cer" ]; then
        echo "Certificate was issued successfully."
        echo "Installing certificate in nginx ..."
        # Install the certificate in nginx
        # Replace the ssl_certificate line in nginx.conf
        # Replace the whole line, because the path is different
        sed -i "s|ssl_certificate .*;|ssl_certificate /etc/acme/$DDNS_DOMAIN/fullchain.cer;|g" /etc/nginx/conf.d/gl.conf
        sed -i "s|ssl_certificate_key .*;|ssl_certificate_key /etc/acme/$DDNS_DOMAIN/$DDNS_DOMAIN.key;|g" /etc/nginx/conf.d/gl.conf
        FAIL=0
    else
        echo -e "\033[31mERROR: Certificate was not issued. Please check the log by running logread.\033[0m"
        FAIL=1
    fi
}

invoke_outro() {
    if [ "$FAIL" -eq 1 ]; then
        echo -e "\033[31m┌────────────────────────────────────────────────────────────────────────┐\033[0m"
        echo -e "\033[31m│ A C M E   F A I L E D                                                  │\033[0m"
        echo -e "\033[31m└────────────────────────────────────────────────────────────────────────┘\033[0m"
        echo -e "\033[31mThe ACME certificate was not installed successfully.\033[0m"
        echo -e "\033[31mPlease report any issues on the GL.iNET forum.\033[0m"
        echo ""
        echo -e "\033[31mYou can find the log file by executing logread\033[0m"
        echo "🦭 👋"
        exit 1
    else
        # Install cronjob
        install_cronjob
        echo -e "\033[32m┌────────────────────────────────────────────────────────────────────────┐\033[0m"
        echo -e "\033[32m│ A C M E   E N A B L E D   S U C C E S S F U L L Y                      │\033[0m"
        echo -e "\033[32m└────────────────────────────────────────────────────────────────────────┘\033[0m"
        echo -e "\033[32mThe ACME certificate was installed successfully.\033[0m"
        echo -e "\033[32mYou can now access your router via HTTPS.\033[0m"
        echo -e "\033[32mPlease report any issues on the GL.iNET forum.\033[0m"
        echo ""
        echo -e "\033[32mYou can find the certificate files in /etc/acme/$DDNS_DOMAIN/\033[0m"
        echo -e "\033[32mThe certificate files are:\033[0m"
        echo -e "\033[32m  /etc/acme/$DDNS_DOMAIN/fullchain.cer\033[0m"
        echo -e "\033[32m  /etc/acme/$DDNS_DOMAIN/$DDNS_DOMAIN.key\033[0m"
        echo ""
        echo -e "\033[32mThe certificate will expire after 90 days.\033[0m"
        echo -e "\033[32mThe cron job to renew the certificate is already installed.\033[0m"
        echo -e "\033[32mRenewal will happen automatically.\033[0m"
        echo "🦭 👋"
        exit 0
    fi
}

install_cronjob() {
    echo "┌────────────────────────────────────────────────────────────────────────┐"
    echo "│ I N S T A L L I N G   C R O N J O B                                    │"
    echo "└────────────────────────────────────────────────────────────────────────┘"
    # Create cron job to renew the certificate
    echo "Checking if cronjob already exists ..."
    if crontab -l | grep -q "enable-acme"; then
        echo "Cron job already exists. Skipping ..."
    else
        echo "Installing cronjob ..."
        install_script
        (crontab -l 2>/dev/null; echo "0 0 * * * /usr/bin/enable-acme --renew ") | crontab -
        echo -e "\033[32m✓\033[0m Cronjob installed successfully."
    fi
}

install_script() {
    # Copying the script to /usr/bin
    echo "Copying the script to /usr/bin ..."
    cp $0 /usr/bin/enable-acme
    chmod +x /usr/bin/enable-acme
    echo -e "\033[32m✓\033[0m Script installed successfully."
}

invoke_renewal(){
    open_firewall 1
    config_nginx 1
    echo "┌────────────────────────────────────────────────────────────────────────┐"
    echo "│ R E N E W I N G   C E R T I F I C A T E                                │"
    echo "└────────────────────────────────────────────────────────────────────────┘"
    /usr/lib/acme/acme.sh --cron --home /etc/acme
    config_nginx 0
    open_firewall 0
}

# Main
# Check if --renew is used
if [ "$1" = "--renew" ]; then
    invoke_renewal
    exit 0
else 
    invoke_intro
    preflight_check
    echo "Do you want to continue? (y/N)"
    read answer
    if [ "$answer" != "${answer#[Yy]}" ]; then
        install_prequisites
        open_firewall 1
        create_acme_config
        config_nginx 1
        get_acme_cert
        config_nginx 0
        open_firewall 0
        invoke_outro
    else
        echo "Ok, see you next time!"
        exit 1
    fi
fi