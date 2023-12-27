#!/bin/sh
#
#
# Description: This script enables ACME support on GL.iNet routers
# Thread: https://forum.gl-inet.com/t/is-there-a-way-to-get-a-letsencrypt-certificate-for-the-factory-ddns-on-the-mt6000/
# Author: Admon
# Date: 2023-12-27
#
# Usage: ./enable-acme.sh
# Warning: This script might potentially harm your router. Use it at your own risk.
#
echo "Warning: This script could potentially harm your router!"
echo "This script will disable HTTP-only access to the router."
echo "Do you want to continue? (y/N)"
read answer

if [ "$answer" != "${answer#[Yy]}" ]; then
    echo "Running opkg update ..."
    opkg update >/dev/null 2>&1
    echo "Installing luci-app-acme ..."
    opkg install luci-app-acme --force-depends >/dev/null 2>&1
    # Asking for the DDNS domain name
    # Loading the DDNS domain name from uci
    DDNS_DOMAIN=$(uci get ddns.glddns.domain)
    if [ -z "$DDNS_DOMAIN" ]; then
        echo "DDNS domain name not found. Please enable DDNS first."
        exit 1
    else
        echo "Detected DDNS domain name: $DDNS_DOMAIN"
        # Get only the first part of the domain name
        DDNS_DOMAIN_PREFIX=$(echo $DDNS_DOMAIN | cut -d'.' -f1)
        echo "Prefix of the DDNS domain name: $DDNS_DOMAIN_PREFIX"
        # Delete old ACME configuration file
        echo "Deleting old ACME configuration file for $DDNS_DOMAIN_PREFIX ..."
        uci delete acme.$DDNS_DOMAIN_PREFIX
        uci commit acme
        # Create new ACME configuration file
        echo "Creating ACME configuration file ..."
        uci set acme.@acme[0]=acme
        uci set acme.@acme[0].account_email='noreply@example.org'
        uci set acme.@acme[0].debug='1'
        uci set acme.$DDNS_DOMAIN_PREFIX=cert
        uci set acme.$DDNS_DOMAIN_PREFIX.enabled='1'
        uci set acme.$DDNS_DOMAIN_PREFIX.use_staging='0'
        uci set acme.$DDNS_DOMAIN_PREFIX.keylength='2048'
        uci set acme.$DDNS_DOMAIN_PREFIX.validation='standalone'
        uci set acme.$DDNS_DOMAIN_PREFIX.update_nginx='1'
        uci set acme.$DDNS_DOMAIN_PREFIX.domains="$DDNS_DOMAIN"
        uci commit acme

        # Disabling HTTP access to the router, because ACME requires port 80
        echo "Disabling HTTP access to the router ..."
        # Commenting out the HTTP line in nginx.conf
        sed -i 's/listen 80;/#listen 80;/g' /etc/nginx/conf.d/gl.conf
        # Same for IPv6
        sed -i 's/listen \[::\]:80;/#listen \[::\]:80;/g' /etc/nginx/conf.d/gl.conf
        # Creating firewall rule to open port 80
        echo "Creating firewall rule to open port 80 on WAN ..."
        uci set firewall.acme=rule
        uci set firewall.acme.dest_port='80'
        uci set firewall.acme.proto='tcp'
        uci set firewall.acme.name='GL-ACME'
        uci set firewall.acme.target='ACCEPT'
        uci set firewall.acme.src='wan'
        uci set firewall.acme.enabled='1'
        uci commit firewall
        echo "Restarting firewall ..."
        /etc/init.d/firewall restart
        # Restarting nginx
        echo "Restarting nginx ..."
        /etc/init.d/nginx restart
        # Restarting acme
        echo "Restarting acme ..."
        /etc/init.d/acme restart
        echo "Due to some unkown reasons, we need to restart acme again ..."
        sleep 5
        /etc/init.d/acme restart
        echo "Checking if certificate was issued ..."
        # Wait for 10 seconds
        sleep 10
        # Check if certificate was issued
        if [ -f "/etc/acme/$DDNS_DOMAIN/fullchain.cer" ]; then
            echo "Certificate was issued successfully."
            echo "Enabling HTTPS access to the router ..."
            # Uncommenting the HTTP line in nginx.conf
            sed -i 's/#listen 80;/listen 80;/g' /etc/nginx/conf.d/gl.conf
            # Same for IPv6
            sed -i 's/#listen \[::\]:80;/listen \[::\]:80;/g' /etc/nginx/conf.d/gl.conf
            # Restarting nginx
            echo "Installing certificate in nginx ..."
            # Install the certificate in nginx
            # Replace the ssl_certificate line in nginx.conf
            # Replace the whole line, because the path is different
            sed -i "s|ssl_certificate .*;|ssl_certificate /etc/acme/$DDNS_DOMAIN/fullchain.cer;|g" /etc/nginx/conf.d/gl.conf
            sed -i "s|ssl_certificate_key .*;|ssl_certificate_key /etc/acme/$DDNS_DOMAIN/$DDNS_DOMAIN.key;|g" /etc/nginx/conf.d/gl.conf
            # Restarting nginx
            echo "Restarting nginx ..."
            # Disabling firewall rule to open port 80
            echo "Disabling firewall rule to open port 80 on WAN ..."
            uci set firewall.acme.enabled='0'
            uci commit firewall
            # That's it
            echo ""
            echo "You can find the certificate files in /etc/acme/$DDNS_DOMAIN/"
            echo "The certificate files are:"
            echo "  /etc/acme/$DDNS_DOMAIN/fullchain.cer"
            echo "  /etc/acme/$DDNS_DOMAIN/$DDNS_DOMAIN.key"
            echo ""
            echo "The certificate will expire after 90 days."
            exit 0
        else
            echo "Certificate was not issued. Please check the log file /var/log/acme/acme.log."
            exit 1
        fi

    fi
else
    echo "Script aborted."
    exit 1
fi
