# How to get support quickly

First of all I would like to welcome you to the forum! :wave:

By visiting here, you have taken the first step towards getting quick support from the community and [official GL.iNet staff](https://forum.gl-inet.com/about). To make this a good experience for you, there are a few things you should keep in mind - apart from netiquette.

**Important note:**

Support here is usually provided by community members. These are users like you and me. Please be friendly and understand that such people do not work for GL.iNet or are involved in product development. If in doubt, you can email support@gl-inet.com for official support.

**Important note 2:**

I am also just a normal forum member, not a staff member. However, since I know and love forums from my childhood, I enjoy creating such guides. :smile:

## Table of Contents

[toc]

## Important links

### Official documentation

[for firmware 4.x :link:](https://docs.gl-inet.com/router/en/4/) | [for firmware 3.x :link:](https://docs.gl-inet.com/router/en/3/) | [for firmware 2.x :link:](https://docs.gl-inet.com/router/en/2/)

### Instructions & Tutorials

[for firmware 4.x :link:](https://docs.gl-inet.com/router/en/4/tutorials/) | [for firmware 3.x :link:](https://docs.gl-inet.com/router/en/3/tutorials/) 

### Common problems & their solutions

[for firmware 4.x :link:](https://docs.gl-inet.com/router/en/4/faq/) | [for firmware 3.x :link:](https://docs.gl-inet.com/router/en/3/) 

---

**Find out your firmware in the admin panel:**

After logging into the admin panel, the firmware version is displayed at the top:



**Find out your firmware via SSH:**

The following command returns the currently used version: `cat /etc/glversion`

---

### Current firmware downloads

[You can find all downloads here :link:](https://dl.gl-inet.com/)

### Which firmware flavor for what?

| Firmware flavor | Usage                                                        |
| --------------- | ------------------------------------------------------------ |
| Stable          | Latest version that has been released for operation and has been sufficiently tested. |
| RC              | "Release Candidate" - A beta firmware that will soon be labeled as "stable". As a rule, no major problems are to be expected. |
| Beta            | Newer version that has not yet been fully tested. Use at your own risk! |
| Snapshot        | Also called "nightly" or "testing": Is generated every night from the current source code and therefore contains the latest changes (but also a lot of bugs). Use at your own risk and generally not recommended! |
| Clean           | Firmware without GL.iNet addons - corresponds more to an original OpenWrt firmware |
| Tor             | This firmware has Tor installed by default, this feature is in beta. Use at your own risk! |

---

### Help, I've broken my router!

Nothing works anymore? The web interface is not accessible or you have installed the wrong firmware?

Don't panic. In most cases, the router is not broken at all, it is just the operating system that is no longer operational. If in doubt, follow the "Debrick using U-Boot" instructions here: [Using Uboot to Debrick Your Router :link:](https://docs.gl-inet.com/router/en/4/faq/debrick/)

**Note:** 
There can sometimes be problems when debricking with MacOS or Linux. It is best to try it from a Windows computer.

## Technical problems?

Do you have technical problems with a GL.iNet device or a question about a function? Then let's work together to find a solution. Usually, a few technical details are needed to analyze the error. Don't worry, we'll collect them together now.

### Necessary information

You should provide the following information in your forum post:

* Which router (which model?) are you using?
* Which firmware version is in use?
* How is your router connected to the Internet?
  * By cable via the router of your Internet provider? (If yes, which router and which ISP?)
  * Via WLAN? (If yes, which network and which encryption?)
  * By cell phone? (If yes, which mobile provider?)
* Which DNS server do you use? (The local one of your ISP? AdGuard Home? Another one?)
* Do you use DHCP or static IP addresses?

### English is important

As previously mentioned, help is often provided by community members in this forum. As the GL.iNet community comes from many different countries, it is important that we all use English as a primary language.

Of course, not everyone can speak English equally well, so I recommend that you use an online translator if necessary. In addition to [DeepL :link:](https://www.deepl.com/translator), [Google Translate :link:](https://translate.google.com/) is of course also worth mentioning.

We can only help each other well when we all understand what each other is saying.

### Graphical representation

It can be helpful if you can display your network structure graphically. For example, use the free solution [draw.io :link:](https://draw.io) and simply draw a rough diagram of the devices and how they are connected to each other.

This could look like this, for example:



The more information you can provide at the beginning, the better!
 A rough sketch is usually enough to help you understand what you want to achieve.

### General troubleshooting

It makes sense to carry out a few troubleshooting steps in advance and share your results directly in the forum. This may save you having to ask questions and help you more quickly.

#### Ping

Can you reach the Internet? Check the "ping" to the IP address 9.9.9.9

[Instructions for Windows, OS X and Linux can be found here :link:](https://www.wikihow.com/Ping-an-IP-Address)

#### Test DNS resolution

Does the resolution of domain names work? Check this with the domain `gl-inet.com` - the answer should be `52.41.190.83`.

Feel free to share the output of this command in your forum post.

[Instructions for Windows :link:](https://support.intermedia.com/app/articles/detail/a_id/24552/) | [Instructions for Linux :link:](https://www.geeksforgeeks.org/nslookup-command-in-linux-with-examples/) | [Instructions for OS X :link:](https://td.usnh.edu/TDClient/60/Portal/KB/ArticleDet?ID=775)

#### Collect log files

You can download all log files directly via the web GUI of your router.

[Interface Guide: Log files :link:](https://docs.gl-inet.com/router/en/4/interface_guide/log/)

#### Delete all settings

If you play a lot with the configuration of your router, a lot can go wrong. Therefore, it is sometimes helpful to reset all settings and start "from scratch".

[Reset Firmware Guide :link:](https://docs.gl-inet.com/router/en/4/interface_guide/reset_firmware/)