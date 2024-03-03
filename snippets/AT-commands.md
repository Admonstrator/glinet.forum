# AT commands

This is a collection of AT commands for various modems.
Some of them are specific to GL.iNet devices, some are specific to the modem used.
Mostly you can just try them out and see if they work for you.

The list is not complete and will be updated from time to time.

## Commands

Title | Command | Description
--- | --- | ---
Set IMEI | `AT+EGMR=1,7,"XXXXXXXXXXXXXX"` | Replace XXXXXXXXXXXXXX with your IMEI
Get enabled bands | `AT+QNWPREFCFG="ue_capability_band"` | Get the list of enabled bands
Get Carrier Aggregation | `AT+QCAINFO` | Retrieve Carrier Aggregation information
Set 5G SA Bands | `AT+QNWPREFCFG="nr5g_band",1:2:3:5:7:8:12:13:14:18:20:25:26:28:29:30:38:40:41:48:66:70:71:75:76:77:78:79` | Set 5G Standalone Bands
Set 5G NSA Bands | `AT+QNWPREFCFG="nsa_nr5g_band",1:2:3:5:7:8:12:13:14:18:20:25:26:28:29:30:38:40:41:48:66:70:71:75:76:77:78:79` | Set 5G Non-Standalone Bands
Set 4G LTE Bands | `AT+QNWPREFCFG="lte_band",1:2:3:4:5:7:8:12:13:14:17:18:19:20:25:26:28:29:30:32:34:38:39:40:41:42:43:46:48:66:71` | Set 4G LTE Bands
Set WCDMA Bands | `AT+QNWPREFCFG="gw_band",1:2:4:5:8:19` | Set WCDMA Bands
Get Network Mode | `AT+QNWPREFCFG="mode_pref"` | Get current network mode preference
Get Roaming Pref. | `AT+QNWPREFCFG="roam_pref"` | Get roaming preference
Get Network Acquisition Order | `AT+QNWPREFCFG="rat_acq_order"` | Get network acquisition order
Enable Wi-Fi-Call | `AT+QMBNCFG="Select", "ROW_Commercial"` | Enable or disable Wi-Fi Calling (results may vary)
Get Signal Strength | `AT+CSQ` | Retrieve signal strength
Get Signal Quality | `AT+CESQ` | Retrieve signal quality
Get Network Operator | `AT+COPS?` | Get current network operator
Get Network Operator List | `AT+COPS=?` | Get list of available network operators
Get Network Registration Status | `AT+CREG?` | Get network registration status
Get Network Technology | `AT+QNWINFO` | Get current network technology
Get Network Information | `AT+QNWINFO` | Get detailed network information
Get Network Operator Name | `AT+QSPN` | Get network operator name
Get Network Time | `AT+CCLK?` | Get current network time
