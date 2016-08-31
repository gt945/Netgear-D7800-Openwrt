#!/bin/sh

ifname=$(uci -P /var/state get wireless.wlg_ext.ifname)

# iwlist scan comand output format like as:
# Cell 36 - Address: 00:90:4C:00:80:01
#	    ESSID:"NetgearABC123"
#	    Mode:Master
#	    Frequency:2.462 GHz (Channel 11)
#	    Quality=31/94  Signal level=-82 dBm  Noise level=-95 dBm
#	    ...
#
# this script output format:
# SSID CHANNEL SIGNAL
# "NetgearABC123" 11 -82

iwlist ${ifname:-ath0} scan | awk '
BEGIN { ORS=""; print "SSID CHANNEL SIGNAL\n" }
{
	if ($0 ~ /ESSID:/) {
		split($0, x1, ":")
		print x1[2]
	}
	if ($0 ~ /Channel/) {
		match($0, "Channel [0-9]+")
		print " " substr($0, RSTART+8, RLENGTH-8)
	}
	if ($0 ~ /Signal level/) {
		match($0, "Signal level=-[0-9]+")
		print " " substr($0, RSTART+13, RLENGTH-13) "\n"
	}
}'
