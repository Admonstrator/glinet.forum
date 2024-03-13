#!/bin/sh
#
#
# Description: This script enables GL.iNet DDNS service behind another router
# Thread: https://forum.gl-inet.com/t/is-there-a-way-to-get-a-letsencrypt-certificate-for-the-factory-ddns-on-the-mt6000/
# Author: Admon
# Date: 2024-03-13
#
# Usage: ./glddns-behind-another-router.sh [--cron]
# Warning: This script might potentially harm your router. Use it at your own risk.
#

# Functions
preflight_check() {
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
    if [ -z "$PUBLIC_IP" ]; then
        echo -e "\033[31mx\033[0m ERROR: Could not get public IP address. Please check your internet connection."
        PREFLIGHT=1
    else
        echo -e "\033[32m✓\033[0m Public IP address: $PUBLIC_IP"
    fi

    if [ -z "$DDNS_DOMAIN" ]; then
        echo -e "\033[31mx\033[0m ERROR: DDNS domain name not found. Please enable DDNS first."
        PREFLIGHT=1
    else
        echo -e "\033[32m✓\033[0m Detected DDNS domain name: $DDNS_DOMAIN"
    fi

    # Get DDNS username
    if [ -z "$DDNS_USERNAME" ]; then
        echo -e "\033[31mx\033[0m ERROR: DDNS username not found. Please enable DDNS first."
        PREFLIGHT=1
    else
        echo -e "\033[32m✓\033[0m DDNS username found."
    fi

     # Get DDNS password
    if [ -z "$DDNS_PASSWORD" ]; then
        echo -e "\033[31mx\033[0m ERROR: DDNS password not found. Please enable DDNS first."
        PREFLIGHT=1
    else
        echo -e "\033[32m✓\033[0m DDNS password found."
    fi

    if [ "$PREFLIGHT" -eq "1" ]; then
        echo -e "\033[31mERROR: Prerequisites are not met. Exiting ...\033[0m"
        exit 1
    else
        echo -e "\033[32m✓\033[0m Prerequisites are met."
    fi
}

install_prequisites() {
    echo "┌────────────────────────────────────────────────────────────────────────┐"
    echo "│ I N S T A L L I N G   P R E R E Q U I S I T E S                        │"
    echo "└────────────────────────────────────────────────────────────────────────┘"
    echo "Installing coreutils-base64 ..."
    opkg update >/dev/null 2>&1
    opkg install coreutils-base64 --force-depends >/dev/null 2>&1
}

update_ddns() {
    echo "┌────────────────────────────────────────────────────────────────────────┐"
    echo "│ U P D A T I N G   D D N S                                              │"
    echo "└────────────────────────────────────────────────────────────────────────┘"
    echo "Updating DDNS ..."
    # Crafting authorization header in base64
    DDNS_LOGIN=$(echo -n $DDNS_USERNAME:$DDNS_PASSWORD | base64)
    curl -s --connect-timeout 4 -m 4 --insecure --location --request GET "http://$DDNS_USERNAME:$DDNS_PASSWORD@ddns.glddns.com/nic/update?hostname=$DDNS_DOMAIN_PREFIX&myip=$PUBLIC_IP" --header "Authorization: Basic $DDNS_LOGIN" --output /dev/null
    # if response is "OK" then the update was successful
    if [ $? -ne 0 ]; then
        FAIL=1
        echo -e "\033[31mx\033[0m ERROR: DDNS update failed."
    else
        echo -e "\033[32m✓\033[0m DDNS updated successfully, now checking ..."
        # Check if the IP address was updated
        DDNS_IP=$(nslookup $DDNS_DOMAIN ns1.glddns.com | sed -n '/Address/s/.*: \(.*\)/\1/p' | grep -v ':')
        if [ "$DDNS_IP" != "$PUBLIC_IP" ]; then
            echo -e "\033[32m✓\033[0m DDNS IP: $DDNS_IP"
            echo -e "\033[32m✓\033[0m Public IP: $PUBLIC_IP"
            echo -e "\033[31mx\033[0m ERROR: DDNS IP address was not updated."
            FAIL=1
        else
            echo -e "\033[32m✓\033[0m DDNS IP: $DDNS_IP"
            echo -e "\033[32m✓\033[0m Public IP: $PUBLIC_IP"
            echo -e "\033[32m✓\033[0m DDNS IP addresses match!"
            FAIL=0
        fi
    fi
}

invoke_intro() {
    echo "┌────────────────────────────────────────────────────────────────────────┐"
    echo "│ GL.iNet router script by Admon 🦭 for the GL.iNet community            │"
    echo "├────────────────────────────────────────────────────────────────────────┤"
    echo "│ WARNING: THIS SCRIPT MIGHT POTENTIALLY HARM YOUR ROUTER!               │"
    echo "│ It's only recommended to use this script if you know what you're doing.│"
    echo "├────────────────────────────────────────────────────────────────────────┤"
    echo "│ This script will customize your routers DDNS service to use            │"
    echo "│ the real ip address instead of the one provided by WAN1                │"
    echo "│                                                                        │"
    echo "│ Prerequisites:                                                         │"
    echo "│ 1. You need to have the GL DDNS service enabled.                       │"
    echo "│ 2. The router needs to have a public IPv4 address.                     │"
    echo "└────────────────────────────────────────────────────────────────────────┘"
}

invoke_outro() {
    if [ "$FAIL" -eq 1 ]; then
        echo -e "\033[31m┌────────────────────────────────────────────────────────────────────────┐\033[0m"
        echo -e "\033[31m│ D D N S   U P D A T E   F A I L E D                                    │\033[0m"
        echo -e "\033[31m└────────────────────────────────────────────────────────────────────────┘\033[0m"
        echo -e "\033[31mThe DDNS update failed. Please check the log file for more information.\033[0m"
        echo ""
        echo -e "\033[31mYou can find the log file by executing logread\033[0m"
        echo "🦭 👋"
        exit 1
    else
        # Install cronjob
        install_cronjob
        echo -e "\033[32m┌────────────────────────────────────────────────────────────────────────┐\033[0m"
        echo -e "\033[32m│ D D N S   U P D A T E   S U C C E S S F U L                            │\033[0m"
        echo -e "\033[32m└────────────────────────────────────────────────────────────────────────┘\033[0m"
        echo "🦭 👋"
        exit 0
    fi
}

install_cronjob() {
    echo "┌────────────────────────────────────────────────────────────────────────┐"
    echo "│ I N S T A L L I N G   C R O N J O B                                    │"
    echo "└────────────────────────────────────────────────────────────────────────┘"
    # Create cron job to renew the IP address every 30 minutes
    echo "Checking if cronjob already exists ..."
    if crontab -l | grep -q "glddns-behind-another-router"; then
        # Delete existing cronjob
        echo "Cronjob already exists. Deleting ..."
        crontab -l | grep -v "glddns-behind-another-router" | crontab -
        echo -e "\033[32m✓\033[0m Cronjob deleted successfully."
    fi
    echo "Installing cronjob ..."
    install_script
    (crontab -l 2>/dev/null; echo "*/30 * * * * /usr/bin/glddns-behind-another-router --cron") | crontab -
    echo -e "\033[32m✓\033[0m Cronjob installed successfully."
}

install_script() {
    # Copying the script to /usr/bin
    echo "Copying the script to /usr/bin ..."
    # If the script is already installed, remove it first
    if [ -f /usr/bin/glddns-behind-another-router ]; then
        rm /usr/bin/glddns-behind-another-router
    fi
    cp $0 /usr/bin/glddns-behind-another-router
    chmod +x /usr/bin/glddns-behind-another-router
    echo -e "\033[32m✓\033[0m Script installed successfully."
}

# Main
PUBLIC_IP=$(sudo -g nonevpn curl -4 -s https://api.ipify.org)
DDNS_DOMAIN=$(uci get ddns.glddns.domain)
DDNS_DOMAIN_PREFIX=$(echo $DDNS_DOMAIN | cut -d'.' -f1)
DDNS_USERNAME=$(uci get ddns.glddns.username)
DDNS_PASSWORD=$(uci get ddns.glddns.password)
FIRMWARE_VERSION=$(cut -c1 </etc/glversion)

if [ "$1" = "--cron" ]; then
    update_ddns
    exit 0
fi

invoke_intro
preflight_check
echo "Do you want to continue? (y/N)"
read answer
if [ "$answer" != "${answer#[Yy]}" ]; then
    install_prequisites
    update_ddns
    invoke_outro
else
    echo "Ok, see you next time!"
    exit 1
fi