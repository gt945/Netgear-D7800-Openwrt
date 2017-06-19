#!/bin/sh
. /lib/cfgmgr/dsl_prepare.sh

#1. Call lantiq_dsl_wan.sh to configure/start WAN connection
#2. Do DNI WAN process


LOCK_FILE=/tmp/.dni_dsl_net_wan_lock
CONFIG=/bin/config
DSL_WAN=/usr/sbin/lantiq_dsl_wan.sh
DSL_WAN2=/usr/sbin/lantiq_dsl_wan2.sh

lock(){
if [ -f $LOCK_FILE ]; then
	echo "Another Ins has been run. Wait until it finish."
	exit 1
else
	touch $LOCK_FILE
fi
}

unlock()
{
	[ -f $LOCK_FILE ] && rm $LOCK_FILE
}

help()
{
	echo "Usage:"
	echo "$0 configure_wan_mode|start|stop"
}

configure_wan_mode() # $1: adsl/vdsl
{
	local wan_mode=vdsl_ptm
	[ "$1" = "adsl" ] && wan_mode=adsl_atm

	# modify dsl_wan_conf & reload driver if needed.
	$DSL_WAN configure_wan mode=$wan_mode

	# WAN2 use same driver as WAN1, so, we just modify the dsl_wan2_conf directly. avoid reloading the driver.
	echo "cfg_wan_mode=\"$wan_mode\"" > $dsl_wan2_conf
}

conf_args_append()
{
	if [ -z $1 -o -z $2 ]; then
		return
	else
		conf_args="$conf_args $1=$2"
	fi
}

connection_conf()
{
	case "$mode" in
		adsl*)
			conf_args=""
			vpi=`$CONFIG get dsl_wan_vpi`
			vci=`$CONFIG get dsl_wan_vci`
			conf_args_append vpi $vpi
			conf_args_append vci $vci
			encaps=`$CONFIG get dsl_wan_multiplex`
			if [ "X$encaps" = "Xvc" ]; then
				conf_args_append encaps vc
			else
				conf_args_append encaps llc
			fi
			;;
		vdsl*)
			conf_args=""
			;;
		*)
			echo "Invalid wan_mode:%mode."
			;;
	esac
	case "$proto" in
		pppoe)
			user=`$CONFIG get wan_pppoe_username`
			passwd=`$CONFIG get wan_pppoe_passwd`
			mtu=`$CONFIG get wan_pppoe_mtu`
			conf_args_append conn_type pppoe
			conf_args_append username $user
			conf_args_append password $passwd
			conf_args_append mtu $mtu
			;;
		pppoa)
			user=`$CONFIG get wan_pppoa_username`
			passwd=`$CONFIG get wan_pppoa_passwd`
			mtu=`$CONFIG get wan_pppoa_mtu`
			conf_args_append conn_type pppoa
			conf_args_append username $user
			conf_args_append password $passwd
			conf_args_append mtu $mtu
			;;
		static)
			ip=`$CONFIG get wan_ipaddr`
			netmask=`$CONFIG get wan_netmask`
			gw=`$CONFIG get wan_gateway`
			dns1=`$CONFIG get wan_ether_dns1`
			dns2=`$CONFIG get wan_ether_dns2`
			conf_args_append conn_type static
			conf_args_append ipaddr $ip
			conf_args_append netmask $netmask
			conf_args_append gateway $gw
			conf_args_append dns "$dns1,$dns2"
			;;
		ipoa)
			ip=`$CONFIG get wan_ipoa_ipaddr`
			netmask=`$CONFIG get wan_ipoa_netmask`
			gw=`$CONFIG get wan_ipoa_gateway`
			dns1=`$CONFIG get wan_ether_dns1`
			dns2=`$CONFIG get wan_ether_dns2`
			conf_args_append conn_type ipoa
			conf_args_append link_type ipoatm
			conf_args_append ipaddr $ip
			conf_args_append netmask $netmask
			conf_args_append gateway $gw
			conf_args_append dns "$dns1,$dns2"
			;;
		dhcp)
			conf_args_append conn_type dhcp
			;;
		*)
			echo "Unsupport wan_proto:$proto."
			unlock
			exit 2
			;;
	esac

	# VID
	vid=`$CONFIG get dsl_wan_data_vid`
	enable_wan_vid=`$CONFIG get dsl_wan_enable_vlanidActive`
	if [ "x$enable_wan_vid" = "x1" ]; then
		conf_args_append vlan $vid
		wan_pri=`$CONFIG get dsl_wan_priority`
		[ "x$wan_pri" != "x" ] && conf_args_append pri $wan_pri
	fi
}

connection_wan2_conf()
{
	case "$mode" in
		adsl*)
			conf_args=""
			vpi=`$CONFIG get dsl_wan2_vpi`
			vci=`$CONFIG get dsl_wan2_vci`
			encaps=`$CONFIG get dsl_wan2_multiplex`
			conf_args_append vpi $vpi
			conf_args_append vci $vci
			if [ "X$encaps" = "Xvc" ]; then
				conf_args_append encaps vc
			else
				conf_args_append encaps llc
			fi
			;;
		vdsl*)
			conf_args=""
			;;
		*)
			echo "Invalid wan_mode:%mode."
			;;
	esac
	case "$proto2" in
		static|STATIC)
			ip=`$CONFIG get wan2_ipaddr`
			netmask=`$CONFIG get wan2_netmask`
			gw=`$CONFIG get wan2_gateway`
			dns1=`$CONFIG get wan2_ether_dns1`
			dns2=`$CONFIG get wan2_ether_dns2`
			conf_args_append conn_type static
			conf_args_append ipaddr $ip
			conf_args_append netmask $netmask
			conf_args_append gateway $gw
			conf_args_append dns $dns1
			;;
		dhcp|DHCP)
			[ "x$($CONFIG get wan2_ether_wan_assign)" = "x" ] && $CONFIG set wan2_ether_wan_assign=0
			[ "x$($CONFIG get wan2_ether_dns_assign)" = "x" ] && $CONFIG set wan2_ether_dns_assign=0
			conf_args_append conn_type dhcp
			;;
		bridged)
			conf_args_append conn_type bridged
			;;
		*)
			echo "Unsupport wan2_proto:$proto2."
			unlock
			exit 2
			;;
	esac

	# VID
	vid=`$CONFIG get dsl_wan_video_vid`
	enable_wan_vid=`$CONFIG get dsl_wan2_enable_vlanidActive`
	if [ "x$enable_wan_vid" = "x1" ]; then
		conf_args_append vlan $vid
		wan2_pri=`$CONFIG get dsl_wan2_priority`
		[ "x$wan2_pri" != "x" ] && conf_args_append pri $wan2_pri
	fi
}

iface_bridged ()
{
	local nifs iface
	nifs=`brctl show $1 | awk '!/bridge/ {print $NF}'`
	for iface in $nifs; do
		[ "$iface" = "$2" ] && return 0
	done
	return 1
}

real_wan2_ifname_setting() #this function is for saving wan2 iface for other progress use
{
	local DSL_RAW video_vid vid_active wan2_ifname
	DSL_RAW=ptm0
	if [ "$($CONFIG get dsl_wan_type)" = "adsl" ]; then
		[ "x$($CONFIG get dsl_need_double_vpi)" = "x1" ] && DSL_RAW=nas22 || DSL_RAW=nas0
	fi

	video_vid=`$CONFIG get dsl_wan_video_vid`
	vid_active=`$CONFIG get dsl_wan2_enable_vlanidActive`
	if [ "x$vid_active" = "x1" ] && [ "x$video_vid" != "x" -a "x$video_vid" != "x0" ]; then
		wan2_ifname=$DSL_RAW.$video_vid
	else
		wan2_ifname=$DSL_RAW
	fi

	iface_bridged br$video_vid $wan2_ifname && wan2_ifname=br$video_vid
	iface_bridged brwan $wan2_ifname && [ "X$($CONFIG get wan2_is_ipoe)" != "X1" ] && wan2_ifname=brwan
	$CONFIG set real_wan2_ifname=$wan2_ifname
}

dsl_start()
{
	mode=`$CONFIG get dsl_wan_type`
	proto=`$CONFIG get wan_proto`

	prepare_dsl_scr_and_restart_dsl_link_if_needed

	$CONFIG set dsl_need_double_vpi=0

	configure_wan_mode $mode

	wan_enable=`$CONFIG get dsl_wan_enablewan`
	if [ "x$wan_enable" = "x1" ]; then
		# Configure WAN connection
		connection_conf
		$DSL_WAN configure_connection $conf_args
	
		# Start WAN connection
		$DSL_WAN start_connection $1

		internet_vid=`$CONFIG get dsl_wan_data_vid`
		internet_pri=`$CONFIG get dsl_wan_priority`
		$CONFIG set vlan_tag_1="1 Internet ${internet_vid:-0} ${internet_pri:-0} 0 0"
	fi

	wan2_active=`$CONFIG get wan2_active`
	video_enable=`$CONFIG get dsl_wan_video_enable`
	wan2_enable=`$CONFIG get dsl_wan2_enablewan`
	$CONFIG set wan2_proto=`$CONFIG get dsl_wan_video_proto`
	local iptv_enable=0
	if [ "$wan2_active" = "1" ] && [ "$video_enable" = "1" ] && [ "x$wan2_enable" = "x1" ]; then
		iptv_enable=1
		proto2=`$CONFIG get dsl_wan_video_proto`
		[ "x$proto2" = "x" ] && {
			$CONFIG set dsl_wan_video_proto="dhcp"
			proto2="dhcp"
		}
		$CONFIG set wan2_is_ipoe=0 #the flag for wan2 user IPOE proto

		# for double vpi/vci settings
		[ "x$($CONFIG get dsl_wan2_vpi)" != "x$($CONFIG get dsl_wan_vpi)" -o "x$($CONFIG get dsl_wan2_vci)" != "x$($CONFIG get dsl_wan_vci)" -o "x$($CONFIG get dsl_wan2_multiplex)" != "x$($CONFIG get dsl_wan_multiplex)" ] && $CONFIG set dsl_need_double_vpi=1 || $CONFIG set dsl_need_double_vpi=0

		# Configure WAN connection
		connection_wan2_conf
		$DSL_WAN2 configure_connection $conf_args

		# Start WAN connection
		$DSL_WAN2 start_connection $1

		# Start igmpproxy when WAN2 up
		if [ "x$($CONFIG get dsl_wan2_bridge_mode)" != "x1" ]; then
			real_wan2_ifname_setting
			$CONFIG set wan_endis_igmp=1
			cmd_igmp stop
			cmd_igmp start &
		fi
	fi

	local iptv_vid=`$CONFIG get dsl_wan_video_vid`
	local iptv_pri=`$CONFIG get dsl_wan2_priority`
	if [ "x$($CONFIG get dsl_wan_video_enable)" = "x1" ] && [ "$internet_vid" != "$iptv_vid" ] && [ "x$($CONFIG get dsl_wan2_bridge_mode)" = "x1" ]; then
		local i
		for i in 1 2 3 4 5 6 7 8 9 10; do
			local vlan_tag=`$CONFIG get vlan_tag_$i`
			local vlan_iptv=`echo $vlan_tag | grep "IPTV ${iptv_vid:-0}"`
			[ -z "$vlan_tag" -o -n "$vlan_iptv" ] && break
		done
		# do not sync bridge group info to vlan/bridge page in case of confusion.
		# $CONFIG set vlan_tag_$i="$iptv_enable IPTV ${iptv_vid:-0} ${iptv_pri:-0} $($CONFIG get iptv_mask) 0"
	fi
	$CONFIG commit

	[ "$($CONFIG get device_mode)" = "modem" ] && return
}

dsl_stop()
{
	killall dot1agd
	$DSL_WAN stop_connection
	
	wan2_active=`$CONFIG get wan2_active`
	video_enable=`$CONFIG get dsl_wan_video_enable`

	#WAN2 stop should be always excuted, if no WAN2, stop_connection will return straightly.
	$DSL_WAN2 stop_connection
	$CONFIG set real_wan2_ifname=
}

lock
case $1 in
	configure_wan_mode)
		shift
		configure_wan_mode "$@"
		;;
	start)
		dsl_start $2
		;;
	stop)
		dsl_stop
		;;
	*)
		help
		;;
esac
unlock
