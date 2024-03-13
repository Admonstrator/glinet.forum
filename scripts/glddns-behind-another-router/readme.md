# glddns-behind-another-router.sh

## Description

This script is designed to update the DDNS IP address of a GL.iNet router that is behind another router. It is useful when the GL.iNet router is not directly connected to the internet and is behind a NAT router. It will update the DDNS IP address to the public IP address of the NAT router.

## Prerequisites

To execute the script, the following prerequisites must be met:

- A GL.iNet router with the latest firmware version.
- A working internet connection.
- DDNS must be enabled and configured.

## Usage

You can run it without cloning the repository by using the following command:

```shell
wget -O glddns-behind-another-router.sh https://raw.githubusercontent.com/Admonstrator/glinet.forum/main/scripts/glddns-behind-another-router/glddns-behind-another-router.sh && sh glddns-behind-another-router.sh
```

The following steps are required to enable ACME using the script:

1. Download the script onto the router.
2. Open an SSH connection to the router.
3. Navigate to the directory where the script is located.
4. Enter the command `sh glddns-behind-another-router.sh` and press Enter.
5. Follow the on-screen instructions to complete the process.

## Renewal

The script will automatically renew the DDNS IP address every 30 minutes. For this reason an cronjob is created to run the script every 30 minutes.

You can manually renew the DDNS IP address by executing the following command:

```sh
sh /usr/bin/glddns-behind-another-router.sh --cron
```

## Notes

- Ensure that you have sufficient permissions to execute the script.
- 

## Reverting

To uninstall the script, you can execute the following command:

```sh
rm /usr/bin/glddns-behind-another-router.sh
crontab -l | grep -v "glddns-behind-another-router" | crontab -
```

## Disclaimer

This script is provided as is and without any warranty. Use it at your own risk.

**It may break your router, your computer, your network or anything else. It may even burn down your house.**

**You have been warned!**

## Thanks

Thanks to SpitzAX3000 from the GL.iNet forum for the inspiration to create this script. The original post can be found [here](https://forum.gl-inet.com/t/ddns-not-working/38997/7).