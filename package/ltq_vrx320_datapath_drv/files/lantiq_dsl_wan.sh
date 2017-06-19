#!/bin/sh
# Script to create/manage Lantiq VRX320 based DSL WAN connections.
# Copyright(c) Lantiq Deutschland GmbH 2014

# Detect Bonding Card connected or not.
ltq_pci_count=`grep 0x1bef /sys/bus/pci/devices/*/subsystem_vendor 2>/dev/null|wc -l`;
if [ -n "$ltq_pci_count" ] && [ "$ltq_pci_count" = "2" ]; then
	# For Bonding Line number is -1. Else we remove this parameter itself (just comment out or remove or macro protect).
	line_num=-1
fi

# DSL Modes
adsl_mode=0
vdsl_mode=1
atm_mode=1
ptm_mode=2
auto_mode=4

. /lib/cfgmgr/dsl_prepare.sh
[ "$(basename $0)" = "lantiq_dsl_wan.sh" ] && DSL_WAN=wan1 || DSL_WAN=wan2
CONFIG=/bin/config
FIREWALL="/www/cgi-bin/firewall.sh"

# Default settings (MTU)
atm_mtu=1500
[ -n "$line_num" ] && ptm_mtu=1498 || ptm_mtu=1500

########## Supporting user input/config write functions #############
[ "$DSL_WAN" = "wan1" ] && CFG_FILE="$dsl_wan_conf" || CFG_FILE="$dsl_wan2_conf"
#CFG_FILE="lantiq_dsl_wan.conf"

OPTIONS=`for opt in $(grep '^func_.*()' $0 | cut -d_ -f2- | cut -d' ' -f1); do echo $opt; done`;
optional_params="vlan encaps link_type qos"

show_hlp_options ()
{
	local inp o_inp symb;
	if [ -n "$__hlp" ]; then
		echo "Supported arguments: "
		for inp in $@; do
			symb="<>";
			for o_inp in $optional_params; do
				if [ "$inp" = "$o_inp" ]; then
					symb="[]  (optional)"; break;
				fi
			done
			echo "  $inp=$symb";
		done
	fi
}

conf_write ()
{
	local oth="";

	[ -n "$conf_start" ] && return 0;

	[ "$1" = "wan_mode" ] && echo -n > $CFG_FILE
	grep -q "^cfg_$1"= $CFG_FILE 2>/dev/null && {
		sed -i "s/^cfg_$1=.*/cfg_$1=\"$2\"/g" $CFG_FILE
	} || echo cfg_$1="\"$2\"" >> $CFG_FILE

	[ "$1" = "password" ] && oth="****" || oth="$2"
	echo "Written '$1=$oth' to config file."
	sync
}

conf_read ()
{
	if [ -f $CFG_FILE ]; then
		. $CFG_FILE
	else
		echo "Unable to open config file: $CFG_FILE or WAN is not configured. Please verify!!"
	fi
}

compare_cfg_inputs ()
{
	local inp;
	[ -n "$conf_start" ] && return 1;

	for inp in $@; do
		if ! eval [ '"''$'$inp'"' = '"''$'cfg_$inp'"' ]; then
			return 1
		fi
	done
	return 0
}

conf_export ()
{
	local val=""
	if [ -f $CFG_FILE ]; then
		for val in `grep ^cfg_.*= $CFG_FILE`; do eval ${val#cfg_}; done
	else
		echo "Unable to open config file: $CFG_FILE or WAN is not configured. Please verify!!"
	fi
}

get_next_mac ()
{
	local assigned=0
	local wantype=$($CONFIG get wan_proto)
	local use_this_mac_addr=00:00:00:00:00:00
	local country=$($CONFIG get dsl_wan_country)
	local isp=$($CONFIG get dsl_wan_isp)

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
	esac

	if [ "$country" = "UK" -a "$isp" = "Sky" -a "$($CONFIG get wan_ether_this_mac)" != "" ]; then
		echo $($CONFIG get wan_ether_this_mac)
	elif [ "$assigned" = "0" ]; then
		echo $($CONFIG get wan_factory_mac)
	elif [ "$assigned" = "1" ]; then
		echo $($CONFIG get wan_remote_mac)
	else
		echo $use_this_mac_addr
	fi
#	$CONFIG get wan_factory_mac
#	local _ia _tmp c_mac n_mac;
#	c_mac=`/sbin/ifconfig $ref_i 2>/dev/null|awk '/HWaddr/ { print $5 }'|sed 's/://g'`;
#	[ -n $c_mac ] || return 1
#	_tmp=`echo $(printf "%.12X\n" $((0x$c_mac+1)))`
#	_ia=0;
#	while [ $_ia -lt 12 ]; do
#		n_mac=$n_mac`echo ${_tmp:$_ia:2}:`
#		_ia=$((_ia+2))
#	done
#	echo ${n_mac::17}
}

#Args: <parameter> [valid fields separated with spaces or '-' if numbers]
verify_input ()
{
	local inp param opt_hlp;
	if [ -z "$2" ]; then
		set|grep -q ^$1=|| {
			echo "Please specify a correct input to: '$1' or leave blank as $1=\"\" if empty."
			[ -n "$conf_start" ] && {
				echo "Please edit the config file $CFG_FILE to provide the input."
			}
			exit 1;
		} && return 0
	fi
	eval param='$'$1
	for inp in $2; do
		echo $inp|grep -q "^[[:digit:]]*-[[:digit:]]*$" && {
			if [ -n "$param" ] && [ $param -ge `echo $inp|cut -d- -f1` 2>/dev/null ] && [ $param -le `echo $inp|cut -d- -f2` 2>/dev/null ]; then
				return 0;
			fi
		}
		if [ "$param" = "$inp" ]; then
			return 0;
		fi
	done
	echo "Please specify a correct input to: '$1' as $1=\"<$(echo $2|sed 's/ /\//g')>\"";
	[ -n "$conf_start" ] && {
		echo "Please edit the config file $CFG_FILE to provide the input."
	}

	exit 1;
}

verify_and_write_inputs ()
{
	local opt;

	show_hlp_options $@

	for opt in $@; do
		case "$opt" in
		"vlan")
			if [ -n "$vlan" ]; then
				verify_input vlan "0-4095"
			fi;;
		"pri")
			if [ -n "$pri" ]; then
				verify_input pri "0-7"
			fi;;
		"vpi")
			verify_input vpi "0-255";;
		"vci")
			verify_input vci "0-65535";;
		"encaps")
			if [ -n "$encaps" ]; then	
				verify_input encaps "llc vc"
			else
				encaps="llc"
			fi;;
		"link_type")
			if [ -n "$link_type" ]; then
				verify_input link_type "eoatm ipoatm"
			else
				link_type="eoatm"
			fi;;
		"qos")
			if [ -n "$qos" ]; then
				case "$(echo $qos \
				|sed -e 's/aal0://g' -e 's/aal5://g' -e 's/[:,]max_pcr=//g' -e 's/[:,]cdv=//g' -e 's/[:,]min_pcr=//g' \
				-e 's/[:,]scr=//g' -e 's/[:,]mbs=//g' -e 's/[0-9,]//g')" in
					"UBR");;
					"CBR");;
					"VBR");;
					"ABR");;
					"NRT-VBR");;
					"RT-VBR");;
					"UBR+");;
					"GFR");;
					*) echo "Please provide valid ATM QoS parameter and options"
					   echo "Format: qos=\"UBR/CBR/VBR/ABR/NRT-VBR/RT-VBR/UBR+/GFR,aal0/aal5:max_pcr=NN,min_pcr=NN,cdv=NN,scr=NN,mbs=NN\"";
					   exit 1;
				esac
			fi;;
		*) eval verify_input $opt '$'$opt
		esac
	done

	compare_cfg_inputs wan_mode $@ && {
		echo "These values are already configured."
		echo "To start the WAN with these values, execute with the option 'start_connection'."
		exit 1;
	}

	conf_write wan_mode $wan_mode
	for opt in $@; do
		eval conf_write $opt '$'$opt
	done

	# Start WAN connection only if start is called.
	if [ -z "$conf_start" ]; then
		echo "To start the WAN with these values, execute with the option 'start_connection'."
		exit 0
	else
		# Globally export next mac 'next_mac'
		next_mac=`get_next_mac`;
		if [ -n "$next_mac" ]; then
			next_mac="hw ether $next_mac"
		fi
	fi
}

l_rmmod ()
{
	grep -q $1 /proc/modules && rmmod $1
}

l_insmod ()
{
	grep -q $1 /proc/modules || insmod /lib/modules/*/$1.ko
}

############# WAN Configuration and connection functions ################

link_restart ()
{
	sleep 1;
	/opt/lantiq/bin/dsl_cpe_pipe.sh acs $line_num 2
}

xDSL_AnnexMode_a="AnnexA"
xDSL_AnnexMode_b="AnnexB"
xTSE_a="05 00 04 00 4C 01 04"   # Annex : A, L, M
xTSE_b="10 00 10 40 00 04 01"   # Annex : B, J
get_xDSL_AnnexMode()
{
   local str=$($CONFIG get xDSL_AnnexMode)
   [ -n "$str" ] && echo "$str" && return
   [ "$($CONFIG get GUI_Region)" = "German" ] && echo "$xDSL_AnnexMode_b" || echo "$xDSL_AnnexMode_a"
}
get_xTSE()
{
	[ $(get_xDSL_AnnexMode) = $xDSL_AnnexMode_b ] && echo $xTSE_b || echo $xTSE_a
}

switch_wan_mode_to_VDSL_PTM ()
{
	echo "Switching WAN mode to VDSL_PTM"
	/opt/lantiq/bin/dsl_cpe_pipe.sh g997xtusecs $line_num $(get_xTSE) 07
	/opt/lantiq/bin/dsl_cpe_pipe.sh sics $line_num $adsl_mode $atm_mode 1 1 3
	/opt/lantiq/bin/dsl_cpe_pipe.sh sics $line_num $vdsl_mode $ptm_mode 1 1 3
	link_restart
#	next_mac=`get_next_mac`;
#	/opt/lantiq/bin/dsl_cpe_pipe.sh dsmmcs $line_num $next_mac
}

switch_wan_mode_to_VDSL_ATM ()
{
	echo "Switching WAN mode to VDSL_ATM"
	/opt/lantiq/bin/dsl_cpe_pipe.sh g997xtusecs $line_num $(get_xTSE) 07
	/opt/lantiq/bin/dsl_cpe_pipe.sh sics $line_num $adsl_mode $atm_mode 1 1 3
	/opt/lantiq/bin/dsl_cpe_pipe.sh sics $line_num $vdsl_mode $atm_mode 1 1 3
	link_restart
}

switch_wan_mode_to_VDSL_AUTO ()
{
	echo "Switching WAN mode to VDSL_AUTO"
	/opt/lantiq/bin/dsl_cpe_pipe.sh g997xtusecs $line_num $(get_xTSE) 07
	/opt/lantiq/bin/dsl_cpe_pipe.sh sics $line_num $adsl_mode $atm_mode 1 1 3
	/opt/lantiq/bin/dsl_cpe_pipe.sh sics $line_num $vdsl_mode $auto_mode 1 1 3
	link_restart
}

switch_wan_mode_to_ADSL_PTM ()
{
	echo "Switching WAN mode to ADSL_PTM"
	/opt/lantiq/bin/dsl_cpe_pipe.sh g997xtusecs $line_num $(get_xTSE) 07
	/opt/lantiq/bin/dsl_cpe_pipe.sh sics $line_num $adsl_mode $ptm_mode 1 1 3
	/opt/lantiq/bin/dsl_cpe_pipe.sh sics $line_num $vdsl_mode $ptm_mode 1 1 3
	link_restart
	sleep 8
	/opt/lantiq/bin/dsl_cpe_pipe.sh dms $line_num 1762 0 1 1
}

switch_wan_mode_to_ADSL_ATM ()
{
	echo "Switching WAN mode to ADSL_ATM"
	/opt/lantiq/bin/dsl_cpe_pipe.sh g997xtusecs $line_num $(get_xTSE) 07
	/opt/lantiq/bin/dsl_cpe_pipe.sh sics $line_num $adsl_mode $atm_mode 1 1 3
	/opt/lantiq/bin/dsl_cpe_pipe.sh sics $line_num $vdsl_mode $ptm_mode 1 1 3
	link_restart
}

switch_wan_mode_to_ADSL_AUTO ()
{
	echo "Switching WAN mode to ADSL_AUTO"
	/opt/lantiq/bin/dsl_cpe_pipe.sh g997xtusecs $line_num $(get_xTSE) 07
	/opt/lantiq/bin/dsl_cpe_pipe.sh sics $line_num $adsl_mode $auto_mode 1 1 3
	/opt/lantiq/bin/dsl_cpe_pipe.sh sics $line_num $vdsl_mode $ptm_mode 1 1 3
	link_restart
}

switch_wan_mode_to_FULL_AUTO ()
{
	echo "Switching WAN mode to FULL_AUTO"
	/opt/lantiq/bin/dsl_cpe_pipe.sh g997xtusecs $line_num $(get_xTSE) 07
	/opt/lantiq/bin/dsl_cpe_pipe.sh sics $line_num $adsl_mode $atm_mode 1 1 3
	/opt/lantiq/bin/dsl_cpe_pipe.sh sics $line_num $vdsl_mode $ptm_mode 1 1 3
	link_restart
}

nif_existed()
{
	ifconfig $1 >/dev/null 2>&1
}

br_wannifs()
{
	brctl show $1 | awk '!/bridge/ {print $NF}' | grep "ptm\|nas\|ethwan\|eth0\|eth1"
}
del_br_wan_vifs()
{
	local nif
	ifconfig $1 0.0.0.0 down
	for nif in $(br_wannifs $1); do
		brctl delif $1 $nif
		vconfig rem $nif
	done
}

add_br_wan_vifs()
{
	brctl addif $1 $2
	ifconfig $1 up
}

vlan_set_vif_pri() # $1: vif, $2: pri
{
	local p

	for p in 0 1 2 3 4 5 6 7; do
		vconfig set_ingress_map $1 $p $p
		vconfig set_egress_map $1 $p $2
	done
}

bridge_lan_ports_for_iptv() # $1 iface $2 datavid $3 videovid
{
	# iptv/vlan feature enabled, just return
	[ "x$($CONFIG get enable_vlan)" = "x1" ] && echo "################iptv/vlan setup prior to lan4 setting" && return
	[ "x$($CONFIG get iptv_mask)" = "x0" -o "x$($CONFIG get iptv_mask)" = "x" ] && return
	[ "x$($CONFIG get dsl_wan2_bridge_mode)" = "x1" ] || return

	#this function is for bridging lan 4 port for iptv feature
	. /lib/cfgmgr/enet.sh
	local used_wports=$($CONFIG get iptv_mask) # lan ports bridged
	local lanvid=1 wanvid=4094
	ifconfig br0 down
	ifconfig ethlan down
	brctl delif br0 ethlan
	vconfig rem ethlan || ip link set dev ethlan name $RawEthLan
	ifconfig $RawEthLan up
	vconfig add $RawEthLan $lanvid && ifconfig $RawEthLan.$lanvid down
	ip link set dev $RawEthLan.$lanvid name ethlan
	brctl addif br0 ethlan
	ifconfig ethlan up
	ifconfig br0 up

	if [ "x$3" != "x" -a "x$2" = "x$3" ]; then # iptv mode
		vconfig add $RawEthLan $3 && ifconfig $RawEthLan.$3 up
		brctl addif brwan $RawEthLan.$3
		$CONFIG set i_opmode=iptv
		sw_configvlan "iptv" $used_wports $3
	elif [ "x$3" = "x" ]; then #bridge mode & no vlan id
		nif_existed brwan2 && {
		del_br_wan_vifs brwan2
		brctl delbr brwan2
	}
		brctl addbr brwan2
		brctl setfd brwan2 0
		brctl stp brwan2 0
		echo 0 > /sys/devices/virtual/net/brwan2/bridge/multicast_snooping
		vconfig add $RawEthLan 2 && ifconfig $RawEthLan.2 up
		brctl addif brwan2 $RawEthLan.2
		brctl addif brwan2 $1
		$CONFIG set i_opmode=iptv
		sw_configvlan "iptv" $used_wports
	else # vlan mode
		nif_existed br$vlan && {
		del_br_wan_vifs br$bvlan
		brctl delbr br$vlan
	}
		brctl addbr br$vlan
		brctl setfd br$vlan 0
		brctl stp br$vlan 0
		echo 0 > /sys/devices/virtual/net/br$vlan/bridge/multicast_snooping
		vconfig add $RawEthLan $vlan && ifconfig $RawEthLan.$vlan up
		brctl addif br$vlan $RawEthLan.$vlan
		vlan_set_vif_pri $RawEthLan.$vlan $pri
		brctl addif br$vlan $1
		ifconfig br$vlan hw ether $(get_next_mac) up
		$CONFIG set i_opmode=vlan

		sw_configvlan "vlan" "start"
		sw_configvlan "vlan" "add" "br" $vlan $used_wports $pri
		sw_configvlan "vlan" "add" "lan" "$lanvid" $(($used_wports ^ 0xf)) "0"
		[ "x$ethwan_as_lanport" = "x1" ] && sw_configvlan "vlan" "add" "dsl" "$wanvid" "0" "0"
		sw_configvlan "vlan" "end"
	fi
	$CONFIG commit
}

tcpdump_if_needed() # $1: iface
{
	[ "$(cat /tmp/wanlan_capture)" = "1" ] || return
	tcpdump -i $1 -s 0 -W 1 -w /tmp/connection.pcap -C 1 &
}

start_dot1ag() #$1 iface
{
	if `ifconfig | grep -q $1` ; then
		dot1agd -i $1 &
	fi
}

iptv_is_ipoe()
{
	local country=$($CONFIG get dsl_wan_country)
	local isp=$($CONFIG get dsl_wan_isp)
	local type=$($CONFIG get dsl_wan_type)

	case "$type/$country/$isp" in
		adsl/UK/BT)
			$CONFIG set wan2_ipaddr=10.10.10.10
			$CONFIG set wan2_netmask=255.255.255.0
			$CONFIG set wan2_gateway=10.10.10.1
			$CONFIG set wan2_ether_dns1=10.10.10.1
			$CONFIG set wan2_is_ipoe=1 #for wan2 use ipoe proto
			return 0
			;;
		adsl/Australia/TPG)
			$CONFIG set wan2_ipaddr=192.168.0.250
			$CONFIG set wan2_netmask=255.255.255.0
			$CONFIG set wan2_gateway=192.168.0.1
			$CONFIG set wan2_ether_dns1=192.168.0.1
			$CONFIG set wan2_is_ipoe=1 #for wan2 use ipoe proto
			return 0
			;;
		vdsl/UK/PlusNet)
			$CONFIG set wan2_ipaddr=10.22.22.1
			$CONFIG set wan2_netmask=255.255.255.0
			$CONFIG set wan2_gateway=10.22.22.2
			$CONFIG set wan2_ether_dns1=10.22.22.2
			$CONFIG set wan2_is_ipoe=1 #for wan2 use ipoe proto
			return 1
			;;
		*)
			return 1
			;;
	esac
}

modem_mode_disabled()
{
	if [ "X$($CONFIG get device_mode)" = "Xmodem" ] && [ "$DSL_WAN" = "wan1" ]; then
		brctl delif br0 $1
		/sbin/ledcontrol -n wan -c amber -s on
		return 0
	else
		return 1
	fi
}

modem_mode_enabled()
{
	if [ "X$($CONFIG get device_mode)" = "Xmodem" ] && [ "$DSL_WAN" = "wan1" ]; then
		brctl addif br0 $1
		/sbin/ledcontrol -n wan -c green -s on
		return 0
	else
		return 1
	fi
}

set_dns()
{
	echo "nameserver $($CONFIG get wan_ether_dns1)" > /tmp/resolv.conf
	[ "x$($CONFIG get wan_ether_dns2)" != "x" ] && \
		echo "nameserver $($CONFIG get wan_ether_dns2)" >> /tmp/resolv.conf
	[ "x$($CONFIG get wan_ether_dns3)" != "x" ] && \
		echo "nameserver $($CONFIG get wan_ether_dns3)" >> /tmp/resolv.conf
}

stop_connection_bridged ()
{
	local wan_mode;
	nif_existed br$vlan && {
		del_br_wan_vifs br$vlan
		brctl delbr br$vlan
	}

	[ -z $conf_start ] && return 0;

	wan_mode=$cfg_wan_mode

	if [ "$wan_mode" = "vdsl_ptm" -o "$wan_mode" = "adsl_ptm" ]; then
		## Configuration validate, write and terminate section ##
		verify_and_write_inputs conn_type vlan pri

		if [ -n "$vlan" ]; then
			ifconfig ptm0.$vlan down
			vconfig rem ptm0.$vlan
		fi
		ifconfig ptm0 down

	elif [ "$wan_mode" = "adsl_atm" ]; then
		## Configuration validate, write and terminate section ##
		verify_and_write_inputs conn_type vlan pri vpi vci encaps

		killall oamd;
		if [ -n "$vlan" ]; then
			ifconfig nas22.$vlan down
			vconfig rem nas22.$vlan
		fi
		ifconfig nas22 down
		sleep 1;
		kill -9 `cat /var/run/br2684ctl-nas22.pid`
		rm -rf /var/run/br2684ctl-nas22.pid
		usleep 50000
	fi
}
create_connection_bridged ()
{
	local wan_mode iface pppoe_opt_file pppoe_file;

	wan_mode=$cfg_wan_mode

	if [ "$wan_mode" = "vdsl_ptm" -o "$wan_mode" = "adsl_ptm" ]; then
		## Configuration validate, write and terminate section ##
		verify_and_write_inputs conn_type vlan pri

		## WAN connection creation starts here ##
		ifconfig ptm0 mtu $ptm_mtu $next_mac up || {
			echo "Error: Unable to bringup ptm0 interface."
			exit 1;
		}

		if [ -n "$vlan" ]; then
			vconfig add ptm0 $vlan 2>/dev/null && sleep 1;
			if [ -d /sys/devices/virtual/net/ptm0.$vlan ]; then
				if ifconfig ptm0.$vlan up ; then
					iface=ptm0.$vlan
					[ -n "$pri" ] && vlan_set_vif_pri $iface $pri
				else
					echo "Error: Unable to create a vlan interface on ptm0."
					exit 1;
				fi
			fi
		else
			iface=ptm0
		fi
	elif [ "$wan_mode" = "adsl_atm" -a "x$($CONFIG get dsl_need_double_vpi)" = "x1" -a "$DSL_WAN" = "wan2" ]; then
		## Configuration validate, write and terminate section ##
		verify_and_write_inputs conn_type vlan pri vpi vci encaps qos

		## WAN connection creation starts here ##
		#br2684ctl -b (for background) -c <nas id> -e <llc 0/vc 1> -p <ipoatm 0/eoatm 1> -q <qos params> -a <vpi.vci>
		br2684ctl -b -c 22 \
			-e `([ -n "$encaps" ] && [ "$encaps" = "vc" ]) && echo 1 || echo 0` \
			-p 1 \
			`[ -n "$qos" ] && echo "-q $qos"` \
			-a $vpi.$vci

		sleep 3;

		ifconfig nas22 mtu $atm_mtu $next_mac up || {
			echo "Error: Unable to bringup nas0 interface."
			[ "$DSL_WAN" = "wan1" ] && exit 1;
		}

		# Start OAMd
		[ -z `pidof oamd` ] && oamd &

		if [ -n "$vlan" ]; then
			vconfig add nas22 $vlan 2>/dev/null && sleep 1;
			if [ -d /sys/devices/virtual/net/nas22.$vlan ]; then
				if ifconfig nas22.$vlan up ; then
					iface=nas22.$vlan
					[ -n "$pri" ] && vlan_set_vif_pri $iface $pri
				else
					echo "Error: Unable to create a vlan interface on nas0."
					exit 1;
				fi
			fi
		else
			iface=nas22
		fi
	fi

	bridge_lan_ports_for_iptv $iface $($CONFIG get dsl_wan_data_vid) $vlan
}

stop_connection_pppoe ()
{
	local wan_mode;
	if [ "$DSL_WAN" = "wan1" ]; then
		modem_mode_disabled `$CONFIG get dsl_wan1_name` || del_br_wan_vifs brwan
	else
		nif_existed br$vlan && {
		del_br_wan_vifs br$vlan
		brctl delbr br$vlan
	}
	fi

	[ -z $conf_start ] && return 0;

	wan_mode=$cfg_wan_mode

	if [ "$wan_mode" = "vdsl_ptm" -o "$wan_mode" = "adsl_ptm" ]; then
		## Configuration validate, write and terminate section ##
		verify_and_write_inputs conn_type vlan pri username password

		# Because the ipv6 pppoe may be connecting.
		local ipv4_pppd=`ps | grep "pppd call dial-provider updetach" | grep -v "grep" |awk '{print $1}'`
		if [ "x$ipv4_pppd" != "x" ]; then
			/bin/kill -SIGHUP $ipv4_pppd
			/bin/kill $ipv4_pppd
		fi

		if [ -n "$vlan" ]; then
			ifconfig ptm0.$vlan down
			vconfig rem ptm0.$vlan
		fi
		ifconfig ptm0 down

	elif [ "$wan_mode" = "adsl_atm" ]; then
		## Configuration validate, write and terminate section ##
		verify_and_write_inputs conn_type vlan pri vpi vci encaps username password

		# Because the ipv6 pppoe may be connecting.
		local ipv4_pppd=`ps | grep "pppd call dial-provider updetach" | grep -v "grep" |awk '{print $1}'`
		if [ "x$ipv4_pppd" != "x" ]; then
			/bin/kill -SIGHUP $ipv4_pppd
			/bin/kill $ipv4_pppd
		fi

		killall oamd;
		if [ -n "$vlan" ]; then
			ifconfig nas0.$vlan down
			vconfig rem nas0.$vlan
		fi
		ifconfig nas0 down
		sleep 1;
		killall br2684ctl
	fi
}

create_connection_pppoe ()
{
	local wan_mode iface pppoe_opt_file pppoe_file;

	wan_mode=$cfg_wan_mode

	if [ "$wan_mode" = "vdsl_ptm" -o "$wan_mode" = "adsl_ptm" ]; then
		## Configuration validate, write and terminate section ##
		verify_and_write_inputs conn_type vlan pri username password

		## WAN connection creation starts here ##
		ifconfig ptm0 mtu $ptm_mtu $next_mac up || {
			echo "Error: Unable to bringup ptm0 interface."
			exit 1;
		}

		if [ -n "$vlan" ]; then
			vconfig add ptm0 $vlan 2>/dev/null && sleep 1;
			if [ -d /sys/devices/virtual/net/ptm0.$vlan ]; then
				if ifconfig ptm0.$vlan up ; then
					iface=ptm0.$vlan
					[ -n "$pri" ] && vlan_set_vif_pri $iface $pri
				else
					echo "Error: Unable to create a vlan interface on ptm0."
					exit 1;
				fi
			fi
		else
			iface=ptm0
		fi
	elif [ "$wan_mode" = "adsl_atm" ]; then
		## Configuration validate, write and terminate section ##
		verify_and_write_inputs conn_type vlan pri vpi vci encaps qos username password

		## WAN connection creation starts here ##
		#br2684ctl -b (for background) -c <nas id> -e <llc 0/vc 1> -p <ipoatm 0/eoatm 1> -q <qos params> -a <vpi.vci>
		br2684ctl -b -c 0 \
			-e `([ -n "$encaps" ] && [ "$encaps" = "vc" ]) && echo 1 || echo 0` \
			-p 1 \
			`[ -n "$qos" ] && echo "-q $qos"` \
			-a $vpi.$vci

		sleep 3;

		ifconfig nas0 mtu $atm_mtu $next_mac up || {
			echo "Error: Unable to bringup nas0 interface."
			[ "$DSL_WAN" = "wan1" ] && exit 1;
		}

		# Start OAMd
		[ -z `pidof oamd` ] && oamd &

		if [ -n "$vlan" ]; then
			vconfig add nas0 $vlan 2>/dev/null && sleep 1;
			if [ -d /sys/devices/virtual/net/nas0.$vlan ]; then
				if ifconfig nas0.$vlan up ; then
					iface=nas0.$vlan
					[ -n "$pri" ] && vlan_set_vif_pri $iface $pri
				else
					echo "Error: Unable to create a vlan interface on nas0."
					exit 1;
				fi
			fi
		else
			iface=nas0
		fi
	fi

	$CONFIG set dsl_wan1_name=$iface #saving device name for deleting it from br0 in modem
	modem_mode_enabled $iface && return 0 #DUT works as a modem.

	if [ "$DSL_WAN" = "wan1" ]; then
		add_br_wan_vifs brwan $iface
	else
		# for current ISPs, WAN2 have not ppp dial connection. so code here do not excute
		if nif_existed br$vlan ; then
			add_br_wan_vifs br$vlan $iface
			iface=br$vlan
		else
			# when datavid equals videovid, WAN2 shoul be work on brwan
			[ "x$($CONFIG get dsl_wan_data_vid)" = "x$vlan" ] && iface=brwan
		fi
	fi

	ifconfig brwan hw ether $(get_next_mac) up

	if [ -n $iface ]; then
#		WAN_IF=$iface
		tcpdump_if_needed $iface
		start_dot1ag $iface
		. /lib/network/ppp.sh
		#if traffic meter monthly limit is not reached or don't check "Disconnect and disable the Internet connection".
		if [ "$traffic_month_limit" != "1" -o "$traffic_block_all" != "1" ]; then
			if [ "$($CONFIG get wan_pppoe_intranet_wan_assign)" = "0" ]; then
				# Confiure the PPP parameters firstly, then started PPPD by UDHCPC
				setup_interface_ppp $1
				if [ "$ru_feature" = "1" ]; then
					udhcpc -b -i brwan
					# when intranet dns exists ,then append it
					cat /tmp/dhcpc_resolv.conf >> /tmp/resolv.conf
				fi
			else
				if [ "$($CONFIG get wan_pppoe_intranet_wan_assign)" = "1" -a "$ru_feature" = "1" ]; then
					netmask=$($CONFIG get wan_pppoe_intranet_mask)
					if [ "x$netmask" != "x" -a "x$netmask" != "x0.0.0.0" -a "x$netmask" != "x255.255.255.255" ]; then
						ifconfig brwan $($CONFIG get wan_pppoe_intranet_ip) netmask $netmask
					else
						ifconfig brwan $($CONFIG get wan_pppoe_intranet_ip)
					fi
				fi
				setup_interface_ppp $1
			fi
			[ "$($CONFIG get wan_pppoe_dns_assign)" = "1" ] && set_dns
		fi
	fi

}

stop_connection_pppoa ()
{
	local wan_mode;

	if [ "$wan_mode" = "adsl_atm" ]; then
		## Configuration validate, write and terminate section ##
		verify_and_write_inputs conn_type vpi vci encaps username password

		modem_mode_disabled `$CONFIG get dsl_wan1_name`
		killall oamd;
		killall -9 br2684ctl
		killall pppd && sleep 1
		if [ -f /etc/ppp/peers/pppoa0 ]; then
			rm -f /etc/ppp/peers/pppoa0
		fi
	
	fi
}

create_connection_pppoa ()
{
	local wan_mode iface pppoa_opt_file pppoa_file;

	wan_mode=$cfg_wan_mode

	if [ "$wan_mode" = "adsl_atm" ]; then
		## Configuration validate, write and terminate section ##
		verify_and_write_inputs conn_type vpi vci encaps qos username password

		if [ "X$($CONFIG get device_mode)" = "Xmodem" ]; then
			#br2684ctl -b (for background) -c <nas id> -e <llc 0/vc 1> -p <ipoatm 0/eoatm 1> -q <qos params> -a <vpi.vci>
			br2684ctl -b -c 0 \
				-e `([ -n "$encaps" ] && [ "$encaps" = "vc" ]) && echo 1 || echo 0` \
				-p 1 \
				`[ -n "$qos" ] && echo "-q $qos"` \
				-a $vpi.$vci

			sleep 3;

			ifconfig nas0 mtu $atm_mtu $next_mac up
			# Start OAMd
			oamd &

			$CONFIG set dsl_wan1_name="nas0" #saving device name for deleting it from br0 in modem
			modem_mode_enabled nas0 && return 0 #DUT works as a modem.
		fi


		## WAN connection creation starts here ##
#		mkdir -p /tmp/ppp/peers
#		pppoa_opt_file="/etc/ppp/options"
#		rm -f $pppoa_opt_file
#		echo "maxfail 0" > $pppoa_opt_file
#		echo "persist" >> $pppoa_opt_file

#		pppoa_file="/etc/ppp/peers/pppoa0"
#		rm -f $pppoa_file
#		echo "linkname pppoatm-0" >> $pppoa_file
#		echo "lcp-echo-interval 30" >> $pppoa_file
#		echo "lcp-echo-failure 4" >> $pppoa_file
#		echo "unit 0" >> $pppoa_file
#		echo "maxfail 0" >> $pppoa_file
#		echo "usepeerdns" >> $pppoa_file
#		echo "noipdefault" >> $pppoa_file
#		echo "defaultroute" >> $pppoa_file
#		echo "user $username" >> $pppoa_file
#		echo "password $password" >> $pppoa_file
#		echo "mtu $((atm_mtu-8))" >> $pppoa_file
#		echo "mru $((atm_mtu-8))" >> $pppoa_file
#		echo "holdoff 4" >> $pppoa_file
#		echo "persist" >> $pppoa_file
#		echo "plugin /usr/lib/pppd/2.4.3/pppoatm.so" >> $pppoa_file
#		echo "`([ -n "$encaps" ] && [ "$encaps" = "vc" ]) && echo vc-encaps || echo llc-encaps`" >> $pppoa_file
#		echo "0.$vpi.$vci" >> $pppoa_file
#		[ -n "$qos" ] && echo "qos $qos" >> $pppoa_file

#		/usr/sbin/pppd file /etc/ppp/options call pppoa0
		. /lib/network/ppp.sh
		#if traffic meter monthly limit is not reached or don't check "Disconnect and disable the Internet connection".
		if [ "$traffic_month_limit" != "1" -o "$traffic_block_all" != "1" ]; then
			if [ "$($CONFIG get wan_pppoa_intranet_wan_assign)" = "0" ]; then
				# Confiure the PPP parameters firstly, then started PPPD by UDHCPC
				setup_interface_ppp $1
				if [ "$ru_feature" = "1" ]; then
					udhcpc -b -i brwan
					# when intranet dns exists ,then append it
					cat /tmp/dhcpc_resolv.conf >> /tmp/resolv.conf
				fi
			else
				if [ "$($CONFIG get wan_pppoa_intranet_wan_assign)" = "1" -a "$ru_feature" = "1" ]; then
					netmask=$($CONFIG get wan_pppoa_intranet_mask)
					if [ "x$netmask" != "x" -a "x$netmask" != "x0.0.0.0" -a "x$netmask" != "x255.255.255.255" ]; then
						ifconfig brwan $($CONFIG get wan_pppoa_intranet_ip) netmask $netmask
					else
						ifconfig brwan $($CONFIG get wan_pppoa_intranet_ip)
					fi
				fi
				setup_interface_ppp $1
			fi
			[ "$($CONFIG get wan_pppoa_dns_assign)" = "1" ] && set_dns
		fi
		
		# start OAM
		oamd &
	fi
}

stop_connection_ipoa ()
{
	local wan_mode;
	[ -z $conf_start ] && return 0;
	wan_mode=$cfg_wan_mode
	if [ "$wan_mode" = "adsl_atm" ]; then
		## Configuration validate, write and terminate section ##
		verify_and_write_inputs conn_type vlan pri vpi vci encaps link_type ipaddr netmask gateway dns

		modem_mode_disabled `$CONFIG get dsl_wan1_name`
		killall oamd;
		sleep 1;
		[ "X$($CONFIG get device_mode)" = "Xmodem" ] || ifconfig ppp0 0.0.0.0 down
		sleep 1;
		killall br2684ctl
	fi
}

create_connection_ipoa ()
{
	local wan_mode iface idns;

	wan_mode=$cfg_wan_mode

	[ "$wan_mode" = "adsl_atm" ] || {
		echo "ipoa only supported in adsl_atm mode."
		exit 1;
	}

	## Configuration validate, write and terminate section ##
	verify_and_write_inputs conn_type vlan pri vpi vci encaps link_type qos ipaddr netmask gateway dns

	[ "X$($CONFIG get device_mode)" = "Xmodem" ] && link_type="eoatm" #for modem mode, nas0 need to be brided under br0

	## WAN connection creation starts here ##

	#br2684ctl -b (for background) -c <nas id> -e <llc 0/vc 1> -p <ipoatm 0/eoatm 1> -q <qos params> -a <vpi.vci>
	br2684ctl -b -c 0 \
		-e `([ -n "$encaps" ] && [ "$encaps" = "vc" ]) && echo 1 || echo 0` \
		-p `[ $link_type = "ipoatm" ] && echo 0 || echo 1` \
		`[ -n "$qos" ] && echo "-q $qos"` \
		-a $vpi.$vci

	sleep 3;

	# Start OAMd
	oamd &

	[ "X$($CONFIG get device_mode)" = "Xmodem" ] && ifconfig nas0 mtu $atm_mtu $next_mac up
	$CONFIG set dsl_wan1_name="nas0" #saving device name for deleting from it br0 in modem
	modem_mode_enabled nas0 && return 0 #DUT works as a modem.

	ip link set dev nas0 name ppp0
	iface=ppp0

	ifconfig $iface $ipaddr netmask $netmask pointopoint $gateway up && {
		route add default gw $gateway dev $iface
	}

	touch /etc/resolv.conf; echo -n > /etc/resolv.conf;
	for idns in `echo $dns|sed 's/,/ /g'`; do
		echo "nameserver $idns" >> /etc/resolv.conf
	done

	# for status page ipoa display
	mkdir -p /tmp/ppp
	if ping -c 1 $gateway; then
		echo -n 1 > /etc/ppp/ppp0-status
		echo "1" > "/tmp/ipoa_status"
	else
		echo -n 0 > /etc/ppp/ppp0-status
		echo "0" > "/tmp/ipoa_status"
	fi

	$FIREWALL restart
	# static route & ripd
	/sbin/cmdroute stop
	/usr/bin/killall -SIGINT ripd
	/sbin/cmdroute start
	/usr/etc/functions/ripd_functions start
	cmd_igmp stop
	cmd_igmp start &

	/sbin/ledcontrol -n wan -c green -s on
	mkdir -p /tmp/traffic_meter
	local qos_enable=`$CONFIG get qos_endis_on`
	local qos_bandwidth_enable=`$CONFIG get qos_threshold`
	local qos_bandwidth_type=`$CONFIG get qos_bandwidth_type`
	if [ "x$qos_enable" = "x1" -a "x$qos_bandwidth_enable" = "x1" ]; then
		if [ "x$qos_bandwidth_type" = "x1" ]; then
			/etc/bandcheck/band-check &
		fi
	fi

	# log for static mode when wan gets ip.
	local wan_log="[Internet connected] IP address: "$($CONFIG get wan_ipaddr)","
	/usr/bin/logger "$wan_log"
	set_dns
	# If upgrade FW, need to update stremboost database
	sb_update_database
}

stop_connection_static ()
{
	local wan_mode;

	[ -z $conf_start ] && return 0;

	if [ "$DSL_WAN" = "wan1" ]; then
		modem_mode_disabled `$CONFIG get dsl_wan1_name` || del_br_wan_vifs brwan
	else
		nif_existed br$vlan && {
		del_br_wan_vifs br$vlan
		brctl delbr br$vlan
	}
	fi

	wan_mode=$cfg_wan_mode

	if [ "$wan_mode" = "vdsl_ptm" -o "$wan_mode" = "adsl_ptm" ]; then
		## Configuration validate, write and terminate section ##
		verify_and_write_inputs conn_type vlan pri ipaddr netmask gateway dns

		if [ -n "$vlan" ]; then
			ifconfig ptm0.$vlan down
			vconfig rem ptm0.$vlan
		fi
		ifconfig ptm0 down

	elif [ "$wan_mode" = "adsl_atm" ]; then
		## Configuration validate, write and terminate section ##
		verify_and_write_inputs conn_type vlan pri vpi vci encaps link_type ipaddr netmask gateway dns

		killall oamd;
		if [ -n "$vlan" ]; then
			ifconfig nas0.$vlan down
			vconfig rem nas0.$vlan
		fi
		sleep 1;
		ifconfig nas0 down
		sleep 1;
		killall br2684ctl
	fi
}

create_connection_static ()
{
	local wan_mode iface idns;

	wan_mode=$cfg_wan_mode

	if [ "$wan_mode" = "vdsl_ptm" -o "$wan_mode" = "adsl_ptm" ]; then

		## Configuration validate, write and terminate section ##
		verify_and_write_inputs conn_type vlan pri ipaddr netmask gateway dns

		ifconfig ptm0 mtu $ptm_mtu $next_mac up || {
			echo "Error: Unable to bringup ptm0 interface."
			exit 1;
		}

		if [ -n "$vlan" ] && [ "$vlan" != "-1" ]; then
			vconfig add ptm0 $vlan 2>/dev/null && sleep 1;
			if [ -d /sys/devices/virtual/net/ptm0.$vlan ]; then
				if ifconfig ptm0.$vlan up ; then
					iface=ptm0.$vlan
					[ -n "$pri" ] && vlan_set_vif_pri $iface $pri
				else
					echo "Error: Unable to create a vlan interface on ptm0."
					exit 1;
				fi
			fi
		else
			iface=ptm0
		fi

		$CONFIG set dsl_wan1_name=$iface #saving device name for deleting it from br0 in modem
		modem_mode_enabled $iface && return 0 #DUT works as a modem.

		if [ "$DSL_WAN" = "wan2" ]; then
			if nif_existed br$vlan ; then
				add_br_wan_vifs br$vlan $iface
				ifconfig br$vlan $ipaddr hw ether $(get_next_mac) netmask $netmask up
			else
				# when datavid equals videovid, WAN2 shoul be work on brwan
				[ "x$($CONFIG get dsl_wan_data_vid)" = "x$vlan" ] && iface=brwan
				ifconfig $iface $ipaddr hw ether $(get_next_mac) netmask $netmask up
			fi
		else
			add_br_wan_vifs brwan $iface
			ifconfig brwan $ipaddr hw ether $(get_next_mac) netmask $netmask up && {
				route add default gw $gateway dev brwan
			}

			touch /etc/resolv.conf; echo -n > /etc/resolv.conf;
			for idns in `echo $dns|sed 's/,/ /g'`; do
				echo "nameserver $idns" >> /etc/resolv.conf
			done
		fi

	elif [ "$wan_mode" = "adsl_atm" ]; then

		## Configuration validate, write and terminate section ##
		verify_and_write_inputs conn_type vlan pri vpi vci encaps link_type qos ipaddr netmask gateway dns

		## WAN connection creation starts here ##

		#br2684ctl -b (for background) -c <nas id> -e <llc 0/vc 1> -p <ipoatm 0/eoatm 1> -q <qos params> -a <vpi.vci>
		br2684ctl -b -c 0 \
			-e `([ -n "$encaps" ] && [ "$encaps" = "vc" ]) && echo 1 || echo 0` \
			-p `[ $link_type = "ipoatm" ] && echo 0 || echo 1` \
			`[ -n "$qos" ] && echo "-q $qos"` \
			-a $vpi.$vci

		sleep 3;

		ifconfig nas0 mtu $atm_mtu $next_mac up || {
			echo "Error: Unable to bringup nas0 interface."
			[ "$DSL_WAN" = "wan1" ] && exit 1;
		}

		# Start OAMd
		[ -z `pidof oamd` ] && oamd &

		if [ -n "$vlan" ]; then
			vconfig add nas0 $vlan 2>/dev/null && sleep 1;
			if [ -d /sys/devices/virtual/net/nas0.$vlan ]; then
				if ifconfig nas0.$vlan up ; then
					iface=nas0.$vlan
					[ -n "$pri" ] && vlan_set_vif_pri $iface $pri
				else
					echo "Error: Unable to create a vlan interface on nas0."
					exit 1;
				fi
			fi
		else
			iface=nas0
		fi

		$CONFIG set dsl_wan1_name=$iface #saving device name for deleting it from br0 in modem
		modem_mode_enabled $iface && return 0 #DUT works as a modem.

		if [ "$DSL_WAN" = "wan2" ]; then
			if nif_existed br$vlan ; then
				add_br_wan_vifs br$vlan $iface
				ifconfig br$vlan $ipaddr hw ether $(get_next_mac) netmask $netmask up
			else
				# when datavid equals videovid, WAN2 shoul be work on brwan
				[ "x$($CONFIG get dsl_wan_data_vid)" = "x$vlan" ] && iface=brwan
				ifconfig $iface $ipaddr hw ether $(get_next_mac) netmask $netmask up
			fi
		else
			add_br_wan_vifs brwan $iface
			ifconfig brwan $ipaddr hw ether $(get_next_mac) netmask $netmask up && {
				route add default gw $gateway dev brwan
			}

			touch /etc/resolv.conf; echo -n > /etc/resolv.conf;
			for idns in `echo $dns|sed 's/,/ /g'`; do
				echo "nameserver $idns" >> /etc/resolv.conf
			done
		fi

	fi

	if [ "$DSL_WAN" = "wan1" ]; then
		$FIREWALL restart

		start_dot1ag $iface
		# static route & ripd
		/sbin/cmdroute stop
		/usr/bin/killall -SIGINT ripd
		/sbin/cmdroute start
		/usr/etc/functions/ripd_functions start
		cmd_igmp stop
		cmd_igmp start &

		/sbin/ledcontrol -n wan -c green -s on
		mkdir -p /tmp/traffic_meter
		local qos_enable=`$CONFIG get qos_endis_on`
		local qos_bandwidth_enable=`$CONFIG get qos_threshold`
		local qos_bandwidth_type=`$CONFIG get qos_bandwidth_type`
		if [ "x$qos_enable" = "x1" -a "x$qos_bandwidth_enable" = "x1" ]; then
			if [ "x$qos_bandwidth_type" = "x1" ]; then
				/etc/bandcheck/band-check &
			fi
		fi

		# log for static mode when wan gets ip.
		local wan_log="[Internet connected] IP address: "$($CONFIG get wan_ipaddr)","
		/usr/bin/logger "$wan_log"
		set_dns
		# If upgrade FW, need to update stremboost database
		sb_update_database
	fi
}

stop_connection_dhcp ()
{
	local wan_mode iface;

	[ -z $conf_start ] && return 0;

	if [ "$DSL_WAN" = "wan1" ]; then
		modem_mode_disabled `$CONFIG get dsl_wan1_name` || del_br_wan_vifs brwan
	else
		nif_existed br$vlan && {
		del_br_wan_vifs br$vlan
		brctl delbr br$vlan
	}
	fi

	wan_mode=$cfg_wan_mode

	if [ "$wan_mode" = "vdsl_ptm" -o "$wan_mode" = "adsl_ptm" ]; then
		## Configuration validate, write and terminate section ##
		verify_and_write_inputs conn_type vlan

		if [ -n "$vlan" ]; then
			iface=ptm0.$vlan
		else
			iface=ptm0
		fi

		[ "$DSL_WAN" = "wan1" ] && iface=brwan

		if [ -f /var/run/udhcpc-$iface.pid ]; then
			kill `cat /var/run/udhcpc-$iface.pid` && sleep 1;
		fi
		if [ -n "$vlan" ]; then
			ifconfig ptm0.$vlan down
			vconfig rem ptm0.$vlan
		fi
		ifconfig ptm0 down

	elif [ "$wan_mode" = "adsl_atm" ]; then
		## Configuration validate, write and terminate section ##
		verify_and_write_inputs conn_type vlan vpi vci encaps

		local index
		[ "x$($CONFIG get dsl_need_double_vpi)" = "x1" -a "$DSL_WAN" = "wan2" ] && index=22 || index=0 #nas22 for wan2, nas0 for wan1
		if [ -n "$vlan" ]; then
			iface=nas$index.$vlan
		else
			iface=nas$index
		fi

		[ "$DSL_WAN" = "wan1" ] && iface=brwan

		if [ -f /var/run/udhcpc-$iface.pid ]; then
			kill `cat /var/run/udhcpc-$iface.pid` && sleep 1;
		fi

		killall oamd
		if [ -n "$vlan" ]; then
			ifconfig nas$index.$vlan down
			vconfig rem nas$index.$vlan
		fi
		ifconfig nas$index down
		sleep 1;
		killall br2684ctl;
	fi
}

create_connection_dhcp ()
{
	local wan_mode iface;

	wan_mode=$cfg_wan_mode

	if [ "$wan_mode" = "vdsl_ptm" -o "$wan_mode" = "adsl_ptm" ]; then

		## Configuration validate, write and terminate section ##
		verify_and_write_inputs conn_type vlan pri

		## WAN connection creation starts here ##
		ifconfig ptm0 mtu $ptm_mtu $next_mac up || {
			echo "Error: Unable to bringup ptm0 interface."
			exit 1;
		}

		if [ -n "$vlan" ] && [ "$vlan" != "-1" ]; then
			vconfig add ptm0 $vlan 2>/dev/null && sleep 1;
			if [ -d /sys/devices/virtual/net/ptm0.$vlan ]; then
				if ifconfig ptm0.$vlan up ; then
					iface=ptm0.$vlan
					[ -n "$pri" ] && vlan_set_vif_pri $iface $pri
				else
					echo "Error: Unable to create a vlan interface on ptm0."
					exit 1;
				fi
			fi
		else
			iface=ptm0
		fi


	elif [ "$wan_mode" = "adsl_atm" ]; then

		## Configuration validate, write and terminate section ##
		verify_and_write_inputs conn_type vlan pri vpi vci encaps link_type qos

		local index
		[ "$DSL_WAN" = "wan2" -a "x$($CONFIG get dsl_need_double_vpi)" = "x1" ] && index=22 || index=0 #nas22 for wan2, nas0 for wan1
		## WAN connection creation starts here ##
		#br2684ctl -b (for background) -c <nas id> -e <llc 0/vc 1> -p <ipoatm 0/eoatm 1> -q <qos params> -a <vpi.vci>
		br2684ctl -b -c $index \
			-e `([ -n "$encaps" ] && [ "$encaps" = "vc" ]) && echo 1 || echo 0` \
			-p `[ $link_type = "ipoatm" ] && echo 0 || echo 1` \
			`[ -n "$qos" ] && echo "-q $qos"` \
			-a $vpi.$vci

		sleep 3;

		ifconfig nas$index mtu $atm_mtu $next_mac up || {
			echo "Error: Unable to bringup nas$index interface."
			[ "$DSL_WAN" = "wan1" ] && exit 1;
		}

		# Start OAMd
		[ -z `pidof oamd` ] && oamd &

		if [ -n "$vlan" ]; then
			vconfig add nas$index $vlan 2>/dev/null && sleep 1;
			if [ -d /sys/devices/virtual/net/nas0.$vlan ]; then
				if ifconfig nas$index.$vlan up ; then
					iface=nas$index.$vlan
					[ -n "$pri" ] && vlan_set_vif_pri $iface $pri
				else
					echo "Error: Unable to create a vlan interface on nas0."
					exit 1;
				fi
			fi
		else
			iface=nas$index
		fi

	fi

	$CONFIG set dsl_wan1_name=$iface #saving device name for deleting it from br0 in modem
	modem_mode_enabled $iface && return 0 #DUT works as a modem.

	if [ "$DSL_WAN" = "wan1" ]; then
		add_br_wan_vifs brwan $iface
	else
		iptv_is_ipoe && ifconfig $iface `$CONFIG get wan2_ipaddr` netmask `$CONFIG get wan2_netmask` up && return #for wan2 IPOE proto
		if nif_existed br$vlan ; then
			add_br_wan_vifs br$vlan $iface
			iface=br$vlan
		else
			# when datavid equals videovid, WAN2 shoul be work on brwan
			if [ "x$($CONFIG get dsl_wan_data_vid)" = "x$vlan" ] && [ "x$($CONFIG get dsl_wan_enablewan)" = "x1" ] && [ "x$($CONFIG get dsl_wan_enable_vlanidActive)" = "x1" ] ; then
				iface=brwan
				[ "$($CONFIG get dsl_wan_country)" = "UK" ] && [ "$($CONFIG get dsl_wan_isp)" = "BT" -o "$($CONFIG get dsl_wan_isp)" = "PlusNet" ] && return
			fi
		fi
	fi

	[ "$($CONFIG get wan_ether_dns_assign)" = "1" ] && set_dns
	local u_wan_domain=$($CONFIG get wan_domain)
	if [ "$DSL_WAN" = "wan2" ]; then
		ifconfig $iface hw ether $(get_next_mac) up
		tcpdump_if_needed $iface
		dhcpc_option="-b -i $iface -p /var/run/udhcpc-$iface.pid -h \"$($CONFIG get wan_hostname)\" -r $($CONFIG get wan2_dhcp_ipaddr) -N $($CONFIG get wan2_dhcp_oldip) ${u_wan_domain:+-d $u_wan_domain} -s /usr/share/udhcpc/default.script.wan2"
		[ "x$($CONFIG get dsl_wan_ether_dhcp_option60)" != "x" ] && dhcpc_option="$dhcpc_option -V \"$($CONFIG get dsl_wan_ether_dhcp_option60)\""
		[ "x$($CONFIG get dsl_wan_ether_dhcp_option61)" != "x" ] && dhcpc_option="$dhcpc_option -c \"$($CONFIG get dsl_wan_ether_dhcp_option61)\""
		udhcpc $dhcpc_option &
	else
		ifconfig brwan hw ether $(get_next_mac) up
		tcpdump_if_needed $iface
		start_dot1ag $iface
		dhcpc_option="-b -i brwan -p /var/run/udhcpc-$brTmp.pid -h \"$($CONFIG get wan_hostname)\" -r $($CONFIG get wan_dhcp_ipaddr) -N $($CONFIG get wan_dhcp_oldip) ${u_wan_domain:+-d $u_wan_domain} -s /usr/share/udhcpc/default.script"
		[ "x$($CONFIG get dsl_wan_ether_dhcp_option60)" != "x" ] && dhcpc_option="$dhcpc_option -V \"$($CONFIG get dsl_wan_ether_dhcp_option60)\""
		[ "x$($CONFIG get dsl_wan_ether_dhcp_option61)" != "x" ] && dhcpc_option="$dhcpc_option -c \"$($CONFIG get dsl_wan_ether_dhcp_option61)\""
		udhcpc $dhcpc_option &
	fi
	mkdir -p /tmp/traffic_meter
}

func_configure_wan ()
{
	verify_input mode "adsl_atm adsl_ptm vdsl_ptm adsl_auto vdsl_auto auto";

	local cur_mode;

	wan_mode="$mode";

	if [ -f $CFG_FILE ]; then
		conf_read
	fi

	compare_cfg_inputs wan_mode && {
		echo "WAN mode '$wan_mode' already configured."
		echo "To force configure the WAN, execute with option 'start_wan_configure'"
		exit 1;
	}

	if [ -z "$conf_start" ]; then
		cur_mode="$mode";
		func_stop_connection
		conf_start="";
		mode="$cur_mode";
		wan_mode="$cur_mode";
	fi

	## Configuration Write section ##
	conf_write wan_mode $mode

	## Actual WAN Configuration section ##
	case "$mode" in
		"adsl_atm") func_reload_dsl_modules $mode || switch_wan_mode_to_ADSL_ATM;;
		"adsl_ptm") func_reload_dsl_modules $mode || switch_wan_mode_to_ADSL_PTM;;
		"vdsl_ptm") func_reload_dsl_modules $mode || switch_wan_mode_to_VDSL_PTM;;
		"adsl_auto") func_reload_dsl_modules $mode || switch_wan_mode_to_ADSL_AUTO;;
		"vdsl_auto") func_reload_dsl_modules $mode || switch_wan_mode_to_VDSL_AUTO;;
		"auto") func_reload_dsl_modules $mode || switch_wan_mode_to_FULL_AUTO;;
		*) verify_input mode "adsl_atm adsl_ptm vdsl_ptm adsl_auto vdsl_auto auto";;
	esac
}

func_configure_connection ()
{
	if [ -n "$1" ] && [ "$1" = "help" ]; then
		echo "Available arguments:-"
		echo "    conn_type=<pppoe/ipoa/pppoa/dhcp/static/bridged>"
		echo "    vlan=<0-4095/auto>"
		echo "    pri=<0-7>"
		echo "    vpi=<> (Example:- "0-255")"
		echo "    vci=<> (Example:- "0-65535")"
		echo "    link_type=<eoatm/ipoatm/pppoatm>"
		echo "    encaps=<llc/vc>  (Encapsulation mode)"
		echo "    ipaddr=<>  (Example:- "10.10.3.4")"
		echo "    netmask=<> (Example:- "255.0.0.0")"
		echo "    gateway=<> (Example:- "10.10.3.1")"
		echo "    dns=<> (Add multiple dns servers with commas. Example:- "4.3.2.1,10.10.10.3,4.4.4.1")"
		echo "    username=<> (Example:- "user1")"
		echo "    password=<> (Example:- "12345678")"
		echo "    service_name=<> (Example:- "oper_serv1")"
		echo "    ac_name=<> (Access Concentrator Name, Example:- "con_oper1")"
		echo "    mtu=<0-1500> (Default: 1500)"
		echo "    pppoe_relay=<enable/disable>"
		echo "    ppp_connetion_type=<auto / Dial-on-Demand / Manual connect>"
		echo "    bridge_stp=<enable/disable> (spanning tree protocol)"
		exit 0;
	fi

	conf_read;

	if [ "$cfg_wan_mode" = "vdsl_ptm" ]; then
		verify_input conn_type "pppoe dhcp static bridged"
	elif [ "$cfg_wan_mode" = "adsl_atm" ]; then
		verify_input conn_type "pppoe ipoa pppoa dhcp static bridged"
	elif [ "$cfg_wan_mode" = "adsl_ptm" ]; then
		verify_input conn_type "pppoe dhcp static bridged"
	else
		echo "Wrong WAN mode/Un-supported WAN mode is configured. Please configure a wan mode with option 'configure_wan'"
		exit 1;
	fi

	## Trigger point to start/stop connection ##
	if [ -n "$1" ] && [ "$1" = "stop" ]; then
		stop_connection_$conn_type
	else
		create_connection_$conn_type $1

		# Save currently WAN IF name
		$CONFIG set dsl_wan_ifname=$iface
	fi
}

func_show_connection ()
{
	if [ -f "$CFG_FILE" ]; then
		conf_export;
		if [ -n "$conn_type" ]; then
			grep ^cfg_.*= $CFG_FILE | sed -e 's/^cfg_//g' -e 's/^password.*/password=****/g'
			exit 0;
		fi
	fi
	echo "No WAN connection configured."
}

func_start_wan_configure ()
{
	# Export all configured values
	conf_export

	# Start variable for all connection functions and validation functions
	conf_start=1

	mode="$wan_mode"
	func_configure_wan
}

func_start_connection ()
{
	if [ -n "$1" ] && [ "$1" = "help" ]; then
		echo "Starts the WAN connection based on the configuration file."
		exit 0;
	fi

	# Export all configured values
	conf_export

	# Start variable for all connection functions and validation functions
	conf_start=1

	if [ -n "$wan_mode" -a -n "$conn_type" ]; then
		echo "Creating connection.."
		mode="$wan_mode"
		func_configure_connection $1

		if [ "$wan_mode" = "vdsl_ptm" ]; then
			echo 0 > /proc/vrx320/nss_path
			sleep 1
			echo 1 > /proc/vrx320/nss_path
		fi
	else
		echo "No connection type is configured to start a connection!"
		echo "Configure a WAN connection with 'configure_connection' or edit config file '$CFG_FILE'"
		exit 1;
	fi
}

func_stop_connection ()
{
	# Export all configured values
	conf_export

	# Start variable for all connection functions and validation functions
	conf_start=1

	if [ -n "$wan_mode" -a -n "$conn_type" ]; then
		echo "Stopping connection.."
		mode="$wan_mode"
		func_configure_connection stop
	else
		echo "No connection type is configured to stop a connection!"
	fi
}

func_delete_connection ()
{
	func_stop_connection;
	if [ -f $CFG_FILE ]; then
		sed -i '/^cfg_conn_type.*/d' $CFG_FILE
	fi
}

func_load_driver_module ()
{
	conf_export
	mode="$wan_mode"
	conf_start=1
	if [ -z "$wan_mode" ]; then
		echo "Please configure a WAN mode via 'configure_wan' or provide input to 'wan_mode=' in config file".
		exit 1;
	fi
	verify_input mode "adsl_atm adsl_ptm vdsl_ptm adsl_auto vdsl_auto auto";

	if [ "$wan_mode" = "adsl_atm" -o "$wan_mode" = "adsl_auto" ]; then
		l_rmmod lantiq_vrx320_e1
		[ "$1" = "1" ] && l_rmmod lantiq_vrx320_a1 || true
		if [ -f /lib/modules/*/lantiq_vrx320_vectoring.ko ]; then
			l_rmmod lantiq_vrx320_vectoring
			l_insmod lantiq_vrx320_vectoring
		fi
		l_insmod lantiq_vrx320_a1
	elif [ "$wan_mode" = "vdsl_atm" -o "$wan_mode" = "vdsl_ptm" -o "$wan_mode" = "adsl_ptm" -o "$wan_mode" = "vdsl_auto" ]; then
		l_rmmod lantiq_vrx320_a1
		[ "$1" = "1" ] && l_rmmod lantiq_vrx320_e1 || true
		if [ -f /lib/modules/*/lantiq_vrx320_vectoring.ko ]; then
			l_rmmod lantiq_vrx320_vectoring
			l_insmod lantiq_vrx320_vectoring
		fi
		l_insmod lantiq_vrx320_e1
	fi

	# Dev node for PTM qos control tool.
	mknod /dev/ltq_ppa c 181 0 2>/dev/null;

	# Make DSL driver/app symlinks corresponding to the line_mode.
	# symlink change is needed only if "nonbond" dir is present (indicates that the dsl packages are compiled twice to copy bonded and nonbonded binaries)
	local dslbin line_mode;
	[ -n "$line_num" ] && line_mode="bonded" || line_mode="nonbond";
	if [ -d "/opt/lantiq/bin/nonbond" ]; then
		cd /opt/lantiq/bin/ && {
			for dslbin in drv_dsl_cpe_api.ko drv_mei_cpe.ko dsl_auto_mei.cfg dsl_cpe_control; do
				rm -f $dslbin;
				ln -snf $line_mode/$dslbin;
			done
			cd - >/dev/null;
		} || true
	fi
}

func_reload_dsl_modules ()
{
	if [ -n "$cfg_wan_mode" ] && [ "$1" = "$cfg_wan_mode" ]; then
		return 1
	else
		/etc/init.d/ltq_cpe_control_init.sh stop
		sleep 2
		/etc/init.d/ltq_load_dsl_cpe_api.sh stop
		sleep 2
		/etc/init.d/ltq_load_cpe_mei_drv.sh stop
		sleep 2
		func_load_driver_module 1
		/etc/init.d/ltq_load_cpe_mei_drv.sh start
		sleep 2
		/etc/init.d/ltq_load_dsl_cpe_api.sh start
		sleep 2
		/etc/init.d/ltq_cpe_control_init.sh start
		sleep 2
		func_start_wan_configure
		echo "Please re-configure the WAN connection for the current WAN mode '`[ -n "$1" ] && echo $1 || echo $wan_mode`'"
		return 0
	fi
}

func_help () {
	local opt hlp="";
	echo "Usage: $0 <option> [ARGS=XXX]"
	echo "  Options:"
	for opt in $OPTIONS; do
		case "${opt}" in
			"conf*") hlp="(To write in configuration file)";;
			"star*") hlp="(start service based on configuration)";;
			"stop*") hlp="(stop service)";;
			"dele*") hlp="(stop service and delete from configuration)";;
			*) hlp="";;
		esac
		echo "     $opt  $hlp";
	done
	echo "  Arguments:"
	echo "     give '$0 <option> help' to see available arguments"
	exit 1;
}

help () { __hlp=1; }

for opt in $OPTIONS; do
	if [ -n "$1" ] && [ "$1" = "$opt" ]; then
		if [ "$2" = "help" -o "$2" = "-h" ]; then
			func_$opt help;
		else
			shift
			for par in $@; do
				variable=${par%%=*}
				value=${par#*=}
				eval $variable=\'$value\'
			done
			func_$opt $1
		fi
		exit 0;
	fi;
done
func_help

