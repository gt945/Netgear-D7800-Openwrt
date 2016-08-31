#!/bin/sh
# Script to create/manage Lantiq VRX320 based DSL WAN connections.
# Copyright(c) Lantiq Deutschland GmbH 2014
# Added UCI commands to configure WAN.

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

# Default settings (MTU)
atm_mtu=1500
[ -n "$line_num" ] && ptm_mtu=1498 || ptm_mtu=1500

########## Supporting user input/config write functions #############
CFG_FILE="/etc/lantiq_dsl_wan.conf"
#CFG_FILE="./lantiq_dsl_wan.conf"

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
		for val in `grep ^cfg_.*= $CFG_FILE`; do eval ${val:4}; done
	else
		echo "Unable to open config file: $CFG_FILE or WAN is not configured. Please verify!!"
	fi
}

get_next_mac ()
{
	local ref_i="eth1";
	local _ia _tmp c_mac n_mac;
	c_mac=`/sbin/ifconfig $ref_i 2>/dev/null|awk '/HWaddr/ { print $5 }'|sed 's/://g'`;
	[ -n $c_mac ] || return 1
	_tmp=`echo $(printf "%.12X\n" $((0x$c_mac+1)))`
	_ia=0;
	while [ $_ia -lt 12 ]; do
		n_mac=$n_mac`echo ${_tmp:$_ia:2}:`
		_ia=$((_ia+2))
	done
	echo ${n_mac::17}
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

	uci delete network.wan 2>/dev/null;
	uci delete network.atm 2>/dev/null;
	uci set network.wan=interface;
	if [ "$wan_mode" = "adsl_atm" -o "$wan_mode" = "adsl_auto" ]; then
		uci set network.wan.ifname=nas0;
		uci set network.wan.mtu=$atm_mtu;
		uci set network.atm=atm-bridge;
		uci set network.atm.unit=0;
		uci set network.atm.payload=bridge;
	else
		uci delete network.atm 2>/dev/null;
		uci set network.wan.ifname=ptm0;
		uci set network.wan.mtu=$ptm_mtu;
	fi

	for opt in $@; do
		case "$opt" in
			"conn_type") eval uci set network.wan.proto='$'$opt;;
			"vlan") if [ -n "$vlan" ]; then
					if [ "$wan_mode" = "adsl_atm" -o "$wan_mode" = "adsl_auto" ]; then
						eval uci set network.wan.enable_vlan=1;
						eval uci set network.wan.ifname=nas0.'$'$opt;
					#else
					#	eval uci set network.wan.enable_vlan=1;
					#	eval uci set network.wan.ifname=ptm0.'$'$opt;
					fi
				fi;;
			"dns")
				if [ -n "$dns" ]; then
					uci set network.wan.dns="`echo "$dns"|sed 's/,/ /g'`";
				fi;;
			"vpi"|"vci"|"encaps") eval uci set network.atm.$opt='$'$opt;;
			"link_type")
				if [ "$link_type" = "pppoatm" ]; then
					uci delete network.wan.ifname 2>/dev/null;
					uci set network.atm.atmdev=0;
				fi;;
			*) eval uci set network.wan.$opt='$'$opt;;
		esac;
	done
	uci commit network;

	# Start WAN connection only if start is called.
	if [ -z "$conf_start" ]; then
		echo "To start the WAN with these values, execute with the option 'start_connection'."
		exit 0
	else
		# Globally export next mac 'next_mac'
		next_mac=`get_next_mac`;
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

switch_wan_mode_to_VDSL_PTM ()
{
	echo "Switching WAN mode to VDSL_PTM"
	/opt/lantiq/bin/dsl_cpe_pipe.sh g997xtusecs $line_num 00 00 00 00 00 00 00 07
	/opt/lantiq/bin/dsl_cpe_pipe.sh sics $line_num $adsl_mode $atm_mode 1 1 3
	/opt/lantiq/bin/dsl_cpe_pipe.sh sics $line_num $vdsl_mode $ptm_mode 1 1 3
	link_restart
	#next_mac=`get_next_mac`;
	#/opt/lantiq/bin/dsl_cpe_pipe.sh dsmmcs $line_num $next_mac
}

switch_wan_mode_to_VDSL_ATM ()
{
	echo "Switching WAN mode to VDSL_ATM"
	/opt/lantiq/bin/dsl_cpe_pipe.sh g997xtusecs $line_num 00 00 00 00 00 00 00 07
	/opt/lantiq/bin/dsl_cpe_pipe.sh sics $line_num $adsl_mode $atm_mode 1 1 3
	/opt/lantiq/bin/dsl_cpe_pipe.sh sics $line_num $vdsl_mode $atm_mode 1 1 3
	link_restart
}

switch_wan_mode_to_VDSL_AUTO ()
{
	echo "Switching WAN mode to VDSL_AUTO"
	/opt/lantiq/bin/dsl_cpe_pipe.sh g997xtusecs $line_num 00 00 00 00 00 00 00 07
	/opt/lantiq/bin/dsl_cpe_pipe.sh sics $line_num $adsl_mode $atm_mode 1 1 3
	/opt/lantiq/bin/dsl_cpe_pipe.sh sics $line_num $vdsl_mode $auto_mode 1 1 3
	link_restart
}

switch_wan_mode_to_ADSL_PTM ()
{
	echo "Switching WAN mode to ADSL_PTM"
	/opt/lantiq/bin/dsl_cpe_pipe.sh g997xtusecs $line_num 05 00 04 00 0C 01 00 00
	/opt/lantiq/bin/dsl_cpe_pipe.sh sics $line_num $adsl_mode $ptm_mode 1 1 3
	/opt/lantiq/bin/dsl_cpe_pipe.sh sics $line_num $vdsl_mode $ptm_mode 1 1 3
	link_restart
	sleep 8
	/opt/lantiq/bin/dsl_cpe_pipe.sh dms $line_num 1762 0 1 1
}

switch_wan_mode_to_ADSL_ATM ()
{
	echo "Switching WAN mode to ADSL_ATM"
	/opt/lantiq/bin/dsl_cpe_pipe.sh g997xtusecs $line_num 05 00 04 00 0C 01 00 00
	/opt/lantiq/bin/dsl_cpe_pipe.sh sics $line_num $adsl_mode $atm_mode 1 1 3
	/opt/lantiq/bin/dsl_cpe_pipe.sh sics $line_num $vdsl_mode $ptm_mode 1 1 3
	link_restart
}

switch_wan_mode_to_ADSL_AUTO ()
{
	echo "Switching WAN mode to ADSL_AUTO"
	/opt/lantiq/bin/dsl_cpe_pipe.sh g997xtusecs $line_num 05 00 04 00 0C 01 00 00
	/opt/lantiq/bin/dsl_cpe_pipe.sh sics $line_num $adsl_mode $auto_mode 1 1 3
	/opt/lantiq/bin/dsl_cpe_pipe.sh sics $line_num $vdsl_mode $ptm_mode 1 1 3
	link_restart
}

switch_wan_mode_to_FULL_AUTO ()
{
	echo "Switching WAN mode to FULL_AUTO"
	/opt/lantiq/bin/dsl_cpe_pipe.sh g997xtusecs $line_num 05 00 04 00 0C 01 00 07
	/opt/lantiq/bin/dsl_cpe_pipe.sh sics $line_num $adsl_mode $atm_mode 1 1 3
	/opt/lantiq/bin/dsl_cpe_pipe.sh sics $line_num $vdsl_mode $ptm_mode 1 1 3
	link_restart
}

stop_connection_pppoe ()
{
	local wan_mode;

	[ -z $conf_start ] && return 0;

	wan_mode=$cfg_wan_mode

	if [ "$wan_mode" = "vdsl_ptm" -o "$wan_mode" = "adsl_ptm" ]; then
		## Configuration validate, write and terminate section ##
		verify_and_write_inputs conn_type vlan username password

		ifdown wan;
		if [ -n "$vlan" ]; then
			if [ -f "/sys/module/lantiq_vrx320_e1/parameters/g_vlanid" ]; then
				echo -1 > /sys/module/lantiq_vrx320_e1/parameters/g_vlanid
			fi
		fi

	elif [ "$wan_mode" = "adsl_atm" ]; then
		## Configuration validate, write and terminate section ##
		verify_and_write_inputs conn_type vlan vpi vci encaps username password

		killall oamd;
		ifdown wan;
		/etc/init.d/br2684ctl stop
	fi
}

create_connection_pppoe ()
{
	local wan_mode iface pppoe_opt_file pppoe_file;

	wan_mode=$cfg_wan_mode

	if [ "$wan_mode" = "vdsl_ptm" -o "$wan_mode" = "adsl_ptm" ]; then
		## Configuration validate, write and terminate section ##
		verify_and_write_inputs conn_type vlan username password

		## WAN connection creation starts here ##
		uci set network.wan.macaddr=$next_mac;
		uci set network.wan.mtu=$ptm_mtu;
		uci commit network;

		if [ -f "/sys/module/lantiq_vrx320_e1/parameters/g_vlanid" ]; then
			[ -n "$vlan" ] && echo $vlan > /sys/module/lantiq_vrx320_e1/parameters/g_vlanid \
				|| echo -1 > /sys/module/lantiq_vrx320_e1/parameters/g_vlanid
		fi

		/etc/init.d/network reload
		# Workaround as uci doesnot support changing pppoe mtu
		sleep 1
		ifconfig pppoe-wan mtu $((ptm_mtu-8))

	elif [ "$wan_mode" = "adsl_atm" ]; then
		## Configuration validate, write and terminate section ##
		verify_and_write_inputs conn_type vlan vpi vci encaps qos username password

		## WAN connection creation starts here ##
		uci set network.wan.macaddr=$next_mac;
		uci commit network;
		/etc/init.d/br2684ctl start
		/etc/init.d/network reload

		# Start OAMd
		oamd &
	fi
}

stop_connection_pppoa ()
{
	local wan_mode;

	if [ "$wan_mode" = "adsl_atm" ]; then
		## Configuration validate, write and terminate section ##
		verify_and_write_inputs conn_type vpi vci encaps username password

		killall oamd;
		ifdown wan;
		/etc/init.d/br2684ctl stop
	fi
}

create_connection_pppoa ()
{
	local wan_mode iface pppoa_opt_file pppoa_file;

	wan_mode=$cfg_wan_mode

	if [ "$wan_mode" = "adsl_atm" ]; then
		## Configuration validate, write and terminate section ##
		verify_and_write_inputs conn_type vpi vci encaps qos username password

		## WAN connection creation starts here ##
		uci set network.wan.macaddr=$next_mac;
		uci commit network;
		/etc/init.d/br2684ctl start
		/etc/init.d/network reload

		# start OAM
		oamd &
	fi
}

stop_connection_static ()
{
	local wan_mode;

	[ -z $conf_start ] && return 0;

	wan_mode=$cfg_wan_mode

	if [ "$wan_mode" = "vdsl_ptm" -o "$wan_mode" = "adsl_ptm" ]; then
		## Configuration validate, write and terminate section ##
		verify_and_write_inputs conn_type vlan ipaddr netmask gateway dns

		ifdown wan;
		if [ -n "$vlan" ]; then
			if [ -f "/sys/module/lantiq_vrx320_e1/parameters/g_vlanid" ]; then
				echo -1 > /sys/module/lantiq_vrx320_e1/parameters/g_vlanid
			fi
		fi

	elif [ "$wan_mode" = "adsl_atm" ]; then
		## Configuration validate, write and terminate section ##
		verify_and_write_inputs conn_type vlan vpi vci encaps link_type ipaddr netmask gateway dns

		killall oamd;
		ifdown wan;
		/etc/init.d/br2684ctl stop
	fi
}

create_connection_static ()
{
	local wan_mode iface idns;

	wan_mode=$cfg_wan_mode

	if [ "$wan_mode" = "vdsl_ptm" -o "$wan_mode" = "adsl_ptm" ]; then

		## Configuration validate, write and terminate section ##
		verify_and_write_inputs conn_type vlan ipaddr netmask gateway dns

		## WAN connection creation starts here ##
		uci set network.wan.macaddr=$next_mac;
		uci set network.wan.mtu=$ptm_mtu;
		uci commit network;

		if [ -f "/sys/module/lantiq_vrx320_e1/parameters/g_vlanid" ]; then
			[ -n "$vlan" ] && echo $vlan > /sys/module/lantiq_vrx320_e1/parameters/g_vlanid \
				|| echo -1 > /sys/module/lantiq_vrx320_e1/parameters/g_vlanid
		fi

		/etc/init.d/network reload

	elif [ "$wan_mode" = "adsl_atm" ]; then

		## Configuration validate, write and terminate section ##
		verify_and_write_inputs conn_type vlan vpi vci encaps link_type qos ipaddr netmask gateway dns

		## WAN connection creation starts here ##
		uci set network.wan.macaddr=$next_mac;
		uci commit network;
		/etc/init.d/br2684ctl start
		/etc/init.d/network reload

		# Start OAMd
		oamd &
	fi
}

stop_connection_dhcp ()
{
	local wan_mode iface;

	[ -z $conf_start ] && return 0;

	wan_mode=$cfg_wan_mode

	if [ "$wan_mode" = "vdsl_ptm" -o "$wan_mode" = "adsl_ptm" ]; then
		## Configuration validate, write and terminate section ##
		verify_and_write_inputs conn_type vlan

		ifdown wan;
		if [ -n "$vlan" ]; then
			if [ -f "/sys/module/lantiq_vrx320_e1/parameters/g_vlanid" ]; then
				echo -1 > /sys/module/lantiq_vrx320_e1/parameters/g_vlanid
			fi
		fi

	elif [ "$wan_mode" = "adsl_atm" ]; then
		## Configuration validate, write and terminate section ##
		verify_and_write_inputs conn_type vlan vpi vci encaps

		killall oamd;
		ifdown wan;
		/etc/init.d/br2684ctl stop
	fi
}

create_connection_dhcp ()
{
	local wan_mode iface;

	wan_mode=$cfg_wan_mode

	if [ "$wan_mode" = "vdsl_ptm" -o "$wan_mode" = "adsl_ptm" ]; then

		## Configuration validate, write and terminate section ##
		verify_and_write_inputs conn_type vlan

		## WAN connection creation starts here ##
		uci set network.wan.macaddr=$next_mac;
		uci set network.wan.mtu=$ptm_mtu;
		uci commit network;

		if [ -f "/sys/module/lantiq_vrx320_e1/parameters/g_vlanid" ]; then
			[ -n "$vlan" ] && echo $vlan > /sys/module/lantiq_vrx320_e1/parameters/g_vlanid \
				|| echo -1 > /sys/module/lantiq_vrx320_e1/parameters/g_vlanid
		fi

		/etc/init.d/network reload

	elif [ "$wan_mode" = "adsl_atm" ]; then

		## Configuration validate, write and terminate section ##
		verify_and_write_inputs conn_type vlan vpi vci encaps link_type qos

		## WAN connection creation starts here ##
		uci set network.wan.macaddr=$next_mac;
		uci commit network;
		/etc/init.d/br2684ctl start
		/etc/init.d/network reload

		# Start OAMd
		oamd &
	fi
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
		echo "    conn_type=<pppoe/pppoa/dhcp/static/bridged>"
		echo "    vlan=<0-4095/auto>"
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
		verify_input conn_type "pppoe pppoa dhcp static bridged"
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
		create_connection_$conn_type
	fi
}

func_show_connection ()
{
	if [ -f "$CFG_FILE" ]; then
		conf_export;
		if [ -n "$conn_type" ]; then
			grep ^cfg_.*= $CFG_FILE | sed -e 's/^cfg_//g' -e 's/^password.*/password=****/g'
			uci show network.wan
			([ -n "$wan_mode" ] && [ "$wan_mode" = "adsl_atm" -o "$wan_mode" = "adsl_auto" ]) && uci show network.atm
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
		func_configure_connection

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
	uci delete network.atm 2>/dev/null
	uci delete network.wan 2>/dev/null
	uci commit network
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
		/etc/rc.d/S22ltq_cpe_control_init.sh stop
		sleep 2
		/etc/rc.d/S18ltq_load_dsl_cpe_api.sh stop
		sleep 2
		/etc/rc.d/S17ltq_load_cpe_mei_drv.sh stop
		sleep 2
		func_load_driver_module 1
		/etc/rc.d/S17ltq_load_cpe_mei_drv.sh start
		sleep 2
		/etc/rc.d/S18ltq_load_dsl_cpe_api.sh start
		sleep 2
		/etc/rc.d/S22ltq_cpe_control_init.sh start
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
		case "${opt::4}" in
			"conf") hlp="(To write in configuration file)";;
			"star") hlp="(start service based on configuration)";;
			"stop") hlp="(stop service)";;
			"dele") hlp="(stop service and delete from configuration)";;
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
			eval $@
			func_$opt
		fi
		exit 0;
	fi;
done
func_help

