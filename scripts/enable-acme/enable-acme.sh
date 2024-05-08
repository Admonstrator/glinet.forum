#!/bin/sh
# This script repository was moved to https://github.com/Admonstrator/glinet-enable-acme
# This file is only a redirector to the new repository
# It will try to update itself if a new version is available
SCRIPT_VERSION="2024.06.05.00"

invoke_update() {
    echo -e "\033[93mThe repository for this script has been moved to https://github.com/Admonstrator/glinet-enable-acme\033[0m"
    echo -e "\033[93mThis script will now try to update itself to the new repository\033[0m"
    echo -e "\033[93mIf this fails, please update the script manually\033[0m"
    wget -qO /tmp/enable-acme.sh "https://raw.githubusercontent.com/Admonstrator/glinet-enable-acme/main/enable-acme.sh"
    # Get current script path
    SCRIPT_PATH=$(readlink -f "$0")
    # Replace current script with updated script
    rm "$SCRIPT_PATH"
    mv /tmp/enable-acme.sh "$SCRIPT_PATH"
    chmod +x "$SCRIPT_PATH"
    sleep 3
    exec "$SCRIPT_PATH" "$@"
}

invoke_update "$@"
exit 0