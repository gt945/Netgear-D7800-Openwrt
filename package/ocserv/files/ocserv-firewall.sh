#!/bin/sh
case $1 in
start)
	echo "Start Ocserv firewall"
	iptables -I INPUT 11 -i vpns+ -j br0_in
	iptables -I OUTPUT 11 -o vpns+ -j fw2loc
	iptables -I FORWARD 4 -i vpns+ -j br0_fwd
	iptables -I br0_fwd 3 -o vpns+ -j loc2loc
;;
stop)
	echo "Stop Ocserv firewall"
	iptables -D INPUT -i vpns+ -j br0_in
	iptables -D OUTPUT -o vpns+ -j fw2loc
	iptables -D FORWARD -i vpns+ -j br0_fwd
	iptables -D br0_fwd -o vpns+ -j loc2loc
;;
esac
