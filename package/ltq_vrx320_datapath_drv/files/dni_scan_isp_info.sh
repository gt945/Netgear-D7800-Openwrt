#!/bin/sh

#dsl log saving
LOG="/etc/isp_dsl_info.txt"

LOCK_FILE="/tmp/.dni_xdsl_scan_isp_info.lock"

. /lib/cfgmgr/cfgmgr.sh

# TRUE/FALSE
TRUE=0
FALSE=1


OPTIONS=`for opt in $(grep '^func_.*()' $0 | cut -d_ -f2- | cut -d' ' -f1); do echo $opt; done`;

wanmac()
{
	local assigned=0
	local wantype=$($CONFIG get wan_proto)
	local use_this_mac_addr=00:00:00:00:00:00
    
	case "$wantype" in
	dhcp|static)
		[ "$($CONFIG get wan_ether_mac_assign)" = "1" ] && assigned=1
		[ "$($CONFIG get wan_ether_mac_assign)" = "2" ] && { assigned=2; use_this_mac_addr=$($CONFIG get wan_ether_this_mac); }
		;;
	pppoe)
		[ "$($CONFIG get wan_pppoe_mac_assign)" = "1" ] && assigned=1
		[ "$($CONFIG get wan_pppoe_mac_assign)" = "2" ] && { assigned=2; use_this_mac_addr=$($CONFIG get wan_pppoe_this_mac); }
		;;
	pptp)
		[ "$($CONFIG get wan_pptp_mac_assign)" = "1" ] && assigned=1
		[ "$($CONFIG get wan_pptp_mac_assign)" = "2" ] && { assigned=2; use_this_mac_addr=$($CONFIG get wan_pptp_this_mac); }
		;;
	bigpond)
		[ "$($CONFIG get wan_bpa_mac_assign)" = "1" ] && assigned=1
		[ "$($CONFIG get wan_bpa_mac_assign)" = "2" ] && { assigned=2; use_this_mac_addr=$($CONFIG get wan_bpa_this_mac); }
		;;
	l2tp)
		[ "$($CONFIG get wan_l2tp_mac_assign)" = "1" ] && assigned=1
		[ "$($CONFIG get wan_l2tp_mac_assign)" = "2" ] && { assigned=2; use_this_mac_addr=$($CONFIG get wan_l2tp_this_mac); }
		;;
	pppoa)
		[ "$($CONFIG get wan_pppoa_mac_assign)" = "1" ] && assigned=1
		[ "$($CONFIG get wan_pppoa_mac_assign)" = "2" ] && { assigned=2; use_this_mac_addr=$($CONFIG get wan_pppoa_this_mac); }
		;;
	ipoa)
		[ "$($CONFIG get wan_ipoa_mac_assign)" = "1" ] && assigned=1
		[ "$($CONFIG get wan_ipoa_mac_assign)" = "2" ] && { assigned=2; use_this_mac_addr=$($CONFIG get wan_ipoa_this_mac); }
		;;
	esac
	if [ "$assigned" = "0" ]; then
		echo $($CONFIG get wan_factory_mac)
	elif [ "$assigned" = "1" ]; then
		echo $($CONFIG get wan_remote_mac)
	else
		echo $use_this_mac_addr
	fi
}

# Inputs:
# $1 -- interface index
# $2 -- multiplexing( llc/vc)
# $3 -- vpi
# $4 -- vci
create_nas()
{
	# Parameters check

	local mp
	case "$2" in
		llc|LLC)
			mp=0;;
		vc|VC)
			mp=1;;
		*)
			echo "Unvalid multiplexing value:$2"
			[ -f $LOCK_FILE ] && rm $LOCK_FILE
			exit 0;;
	esac

	del_nas $1
	# Use br2684ctl to create nas interface
	qt br2684ctl -b -p 1 -c $1 -e $mp -q UBR,aal5:max_pcr=0,min_pcr=0 -a $3.$4 -s 65536
	usleep 100000
	ifconfig nas$1 hw ether $(wanmac) up
}

# $1: interface index
del_nas()
{
	ifconfig nas$1 down
	kill -9 `cat /var/run/br2684ctl-nas$1.pid`
	rm -rf /var/run/br2684ctl-nas$1.pid
	usleep 50000
}

pvc_detect()
{
	create_nas 2 $encap $vpi $vci
	if [ "$vpi" = "0" ] || [ "$vpi" = "1" ] || [ "$vpi" = "8" ]; then
		export OAM_PING_USLEEP=900000
		qt oamctl --f5 --vpi $vpi --vci $vci --scope 0 --loopback 400 --num-of-pings 2
	else
		export OAM_PING_USLEEP=250000
		qt oamctl --f5 --vpi $vpi --vci $vci --scope 0 --loopback 150 --num-of-pings 1
	fi

	#### Check here
	[ $? -eq 0 ] && return $TRUE || return $FALSE
}

pppoa_detect()
{
	local i=0
	# PPPoA detection
	del_nas 2
	if [ "x$encap" == "xvc" ]; then
		create_nas 10 "vc" 0 1000
	fi

	rm /tmp/ppp_exist -rf
	qt pppd user root password root maxfail 1 plugin /usr/lib/pppd/2.4.3/pppoatm.so $encap-encaps 0.$vpi.$vci persist unit 0 do_detect
	echo $! > /var/run/detect_pppoa.pid

	while [ $i -lt 5 ]
	do
		[ -f /tmp/ppp_exist ] && break
		sleep 2
		i=$(( $i+1 ))
	done

	if [ $i -eq 5 ]; then
		killall pppd
		[ "x$encap" == "xvc" ] && del_nas 10
		return $FALSE
	fi

	[ "x$encap" == "xvc" ] && del_nas 10
	[ "x`cat /tmp/ppp_exist`" == "x1" ] && return $TRUE || return $FALSE 

}

iface_existed ()
{
	ifconfig $1 >/dev/null 2>&1
}

iface_bridged ()
{
	local nifs iface
	nifs=`brctl show brwan | awk '!/bridge/ {print $NF}'`
	for iface in $nifs; do
		[ "$iface" = "$1" ] && return 0
	done
	return 1
}

wan_detect_full_scan() #$1 vdsl/adsl ifname
{
	# Run detwan to detect pppoe/dhcp first
	local vidTmp=-1 flag proto #flag 1: iface existed 2: existed & bridged
	local hw_iface=$1
	while [ $vidTmp -le 999 ]
	do
		flag=
		proto=
		vidTmp=$((vidTmp+1))
		if [ $vidTmp -gt 0 ]; then
			iface_existed $hw_iface.$vidTmp && flag=1 && iface=$hw_iface.$vidTmp
			iface_bridged $hw_iface.$vidTmp && flag=2 && iface=brwan
			if [ "x$flag" != "x1" ] && [ "x$flag" != "x2" ]; then
				vconfig add $hw_iface $vidTmp 2>/dev/null && sleep 1;
				ifconfig $hw_iface.$vidTmp up && iface=$hw_iface.$vidTmp
			fi
		else
			flag=1
			iface_bridged $hw_iface && iface=brwan || iface=$hw_iface
		fi
	
		wan_mac=`/sbin/ifconfig $iface 2>/dev/null|awk '/HWaddr/ { print $5 }'`
#		echo "Detect DSL WAN info,  iface:$iface, wan_mac:$wan_mac, remote_addr:$remote_addr, pc_mac:$pc_mac" > /dev/console
		
		/usr/sbin/detwan -p $remote_addr -i $iface -d $wan_mac -n $pc_mac
		detwanResult=$?

		[ "$(($detwanResult/2%2))" = "1" ] && { proto="$proto dhcp"; echo "dhcp detected!!!"; }  #DHCP
		[ "$(($detwanResult%2))" = "1" ] && { proto="$proto pppoe"; echo "pppoe detected!!!"; }		#PPPoE
		if [ "$hw_iface" = "nas2" -a $vidTmp -eq 0 ]; then
			pppoa_detect
			kill -9 `cat /var/run/detect_pppoa.pid`
			rm -rf /var/run/detect_pppoa.pid
			sleep 3
			create_nas 2 $encap $vpi $vci
			proto="$proto pppoa"; echo "pppoa detected!!!";  #PPOA
		fi
		
		if [ "x$flag" != "x1" ] && [ "x$flag" != "x2" ]; then
			vconfig rem $iface
		fi

		[ -z $proto ] && continue

		if [ "$hw_iface" = "nas2" ]; then
#			echo "Got a available connect infomation, iface: $iface, vpi:$vpi,vci:$vci,encap:$encap,vlanid:$vidTmp, proto:$proto" > /dev/console
			echo "Got a available connect infomation, iface: $iface, vpi:$vpi,vci:$vci,encap:$encap,vlanid:$vidTmp, proto:$proto" >> $LOG
		else
#			echo "Got a available connect infomation, iface: $iface, vlanid:$vidTmp, proto:$proto" > /dev/console
			echo "Got a available connect infomation, iface: $iface, vlanid:$vidTmp, proto:$proto" >> $LOG
		fi

	done

}

fs_vpis="0 1 8 2 3 4 5 6 7 9 10"
# vci range [32, 102] with step 1
func_adsl_full_scan_isp_info ()
{
	while [ -f $LOCK_FILE ]; do
		sleep 1
	done

	touch $LOCK_FILE

#	echo "Detect WAN connection information starting, < country: $($CONFIG get dsl_wan_country), ISP: $($CONFIG get dsl_wan_isp), DSL type: ADSL >" > /dev/console

	echo "Detect WAN connection information starting, < country: $($CONFIG get dsl_wan_country), ISP: $($CONFIG get dsl_wan_isp), DSL type: ADSL >" > $LOG
	protoResult=0
	killall oamd
	qt /usr/bin/oamd &
	for vpi in $fs_vpis
	do
		vci=32
		while [ $vci -le 102 ]
		do
			for encap in llc vc
			do
				pvc_detect && wan_detect_full_scan nas2
			done
			vci=$((vci+1))
		done
	done

	del_nas 2
	qt killall oamd
#	echo "ADSL scan end." > /dev/console
	echo "ADSL scan end." >> $LOG

	rm -rf $LOCK_FILE
	exit 0
}

func_vdsl_full_scan_isp_info ()
{
	while [ -f $LOCK_FILE ]; do
		sleep 1
	done

	touch $LOCK_FILE

#	echo "Detect WAN connection information starting, < country: $($CONFIG get dsl_wan_country), ISP: $($CONFIG get dsl_wan_isp), DSL type: VDSL >" > /dev/console
	echo "Detect WAN connection information starting, < country: $($CONFIG get dsl_wan_country), ISP: $($CONFIG get dsl_wan_isp), DSL type: VDSL >" > $LOG
	vdsl_wan_ifname=`$CONFIG get vdsl_wan_ifname`
	ifconfig $vdsl_wan_ifname hw ether $(wanmac) up
	wan_detect_full_scan $vdsl_wan_ifname
#	echo "VDSL scan end." > /dev/console
	echo "VDSL scan end." >> $LOG

	rm -rf $LOCK_FILE
	exit 0
}

#type=$1
#shift
#eval $@
#case "$type" in
#	adsl_scan)
#		func_adsl_full_scan_isp_info
#		;;
#	vdsl_scan)
#		func_vdsl_full_scan_isp_info
#		;;
#	*)
#		echo $"Usage: $0 {adsl_scan|vdsl_scan}"
#		exit 1
#esac

for opt in $OPTIONS; do
	if [ -n "$1" ] && [ "$1" = "$opt" ]; then
		shift
		eval $@
		func_$opt

		exit 0;
	fi
done

echo "Error: dni_scan_isp_info.sh not option $opt." > /dev/console
