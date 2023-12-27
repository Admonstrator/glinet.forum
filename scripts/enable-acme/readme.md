# enable-acme.sh

## Description

The `enable-acme.sh` script enables the Automated Certificate Management Environment (ACME) for GL.iNet routers. **Renewal of the certificates is currently not supported.**

## Prerequisites

To execute the script, the following prerequisites must be met:

- A GL.iNet router with the latest firmware version.
- A working internet connection.
- DDNS must be enabled and configured.
- DDNS IP must be the same as the router's public IP.
- Disable VPN

## Usage

The following steps are required to enable ACME using the script:

1. Download the script onto the router.
2. Open an SSH connection to the router.
3. Navigate to the directory where the script is located.
4. Enter the command `sh enable-acme.sh` and press Enter.
5. Follow the on-screen instructions to complete the ACME process.

## Notes

- Ensure that you have sufficient permissions to execute the script.
- The script may vary depending on the router model and firmware version. Refer to the router's documentation for specific instructions.

## Reverting

To revert the changes to nginx, execute the following commands:

```sh
sed -i '/listen \[::\]:80;/c\listen \[::\]:80;' /etc/nginx/conf.d/gl.conf
sed -i '/listen \[::\]:80;/c\listen \[::\]:80;' /etc/nginx/conf.d/gl.conf
sed -i 's|ssl_certificate .*;|ssl_certificate /etc/nginx/nginx.cer;|g' /etc/nginx/conf.d/gl.conf
sed -i 's|ssl_certificate_key .*;|ssl_certificate_key /etc/nginx/nginx.key;|g' /etc/nginx/conf.d/gl.conf
/etc/init.d/nginx restart
```

## Disclaimer

This script is provided as is and without any warranty. Use it at your own risk.

**It's a really early stage and definitely not ready for production use.**

**It may break your router, your computer, your network or anything else. It may even burn down your house.**

**You have been warned!**
