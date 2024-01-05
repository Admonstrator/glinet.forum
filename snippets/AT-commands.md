# AT commands

```plain
Get Enabled Bands AT+QNWPREFCFG="ue_capability_band"
Get Carrier Aggregation",value:"AT+QCAINFO"}
Set 5G SA Bands AT+QNWPREFCFG="nr5g_band",1:2:3:5:7:8:12:13:14:18:20:25:26:28:29:30:38:40:41:48:66:70:71:75:76:77:78:79
Set 5G NSA Bands AT+QNWPREFCFG="nsa_nr5g_band",1:2:3:5:7:8:12:13:14:18:20:25:26:28:29:30:38:40:41:48:66:70:71:75:76:77:78:79
Set 4G LTE Bands AT+QNWPREFCFG="lte_band",1:2:3:4:5:7:8:12:13:14:17:18:19:20:25:26:28:29:30:32:34:38:39:40:41:42:43:46:48:66:71
Set WCDMA bands AT+QNWPREFCFG="gw_band",1:2:4:5:8:19
Get Network Mode AT+QNWPREFCFG="mode_pref"
Get Roaming Pref. AT+QNWPREFCFG="roam_pref"
Get Network Acquisition Order AT+QNWPREFCFG="rat_acq_order"
```