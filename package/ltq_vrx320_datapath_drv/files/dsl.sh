#! /bin/sh

OPTIONS=`for opt in $(grep '^func_.*()' $0 | cut -d_ -f2- | cut -d' ' -f1); do echo $opt; done`;
CONFIG=/bin/config

func_switch_wan_vlan_or_normal () { #$1 wan_vid $2 wan_pri
	local p
	local wan_vid_enable=$($CONFIG get dsl_wan_enable_vlanidActive)

	brctl delif brwan ethwan
	ifconfig ethwan down
	vconfig rem ethwan || ip link set dev ethwan name eth0
	ifconfig eth0 down

	. /lib/cfgmgr/enet.sh
	if [ "x$wan_vid" != "x" -a "x$wan_vid_enable" = "x1" ]; then
		ifconfig eth0 up
		vconfig add eth0 $wan_vid
		ifconfig eth0.$wan_vid down
		ip link set dev eth0.$wan_vid name ethwan
		if [ -n "$wan_pri" ]; then
			for p in 0 1 2 3 4 5 6 7; do
				vconfig set_ingress_map ethwan $p $p
				vconfig set_egress_map ethwan $p $wan_pri
			done
		fi
		sw_configvlan "vlan" "start"
		sw_configvlan "vlan" "add" "br" "$wan_vid" "0" "${wan_pri:-0}"
		sw_configvlan "vlan" "add" "lan" $(($wan_vid + 1)) "0xf" "0"
		sw_configvlan "vlan" "end"
	else
		ip link set dev eth0 name ethwan
		sw_configvlan normal
	fi
	brctl addif brwan ethwan
}

# switch wan cable type
func_reset_wan_dsl_or_eth () {
	local nif vid pri opmode_tmp brx br_s
	opmode_tmp=$($CONFIG get i_opmode)
	echo "switch to `[ "x$WanIndepPhy" = "x1" ] && echo xdsl || echo ether` #################" > /dev/console

	sleep 2 #give time to httpd return web page
	ifconfig br0 down
	for nif in $(br_allnifs br0); do
		case "$nif" in
			ethwan)
				ifconfig $nif down
				brctl delif br0 $nif
				vconfig rem ethwan || ip link set dev ethwan name $RawEthWan
				ifconfig $RawEthWan down
				;;
			ethlan)
				ifconfig $nif down
				brctl delif br0 $nif
				vconfig rem ethlan || ip link set dev ethlan name $RawEthLan
				ifconfig $RawEthLan down
				;;
		esac
	done

	br_s=`awk '/br[1-9w]|brwan2/ {print $1}' /proc/net/dev |sed 's/://g'` #brwan2 is for WAN2 IPTV that have no vid
	for brx in $br_s; do
		ifconfig $brx down
		for nif in $(br_allnifs $brx); do
			ifconfig $nif down
			brctl delif $brx $nif
			case "$nif" in
				ethwan)
					vconfig rem ethwan || ip link set dev ethwan name $RawEthWan
					ifconfig $RawEthWan down
					;;
				eth*|ptm*|nas*)
					vconfig rem $nif
					;;
			esac
		done
		[ "$brx" != "brwan" ] && brctl delbr $brx
	done

	/etc/init.d/ntpclient stop
	case "$opmode_tmp" in
		normal|factory)
			[ "$opmode_tmp" = "factory" ] && /etc/init.d/net-br stop
			ip link set dev $RawEthLan name ethlan
			ip link set dev $RawEthWan name ethwan
			if [ "$WanIndepPhy" = "1" ]; then
				[ "$opmode_tmp" = "normal" -a "x$ethwan_as_lanport" = "x1" ] && brctl addif br0 ethwan
				brctl addif brwan $RawDslWan
				ifconfig $RawDslWan up
			else
				[ "$opmode_tmp" = "normal" ] && brctl addif brwan ethwan
				$CONFIG set vlan_tag_1="1 Internet 10 0 0 0"
			fi
			brctl addif br0 ethlan
			sw_configvlan "$opmode_tmp"
			ifconfig ethlan up
			ifconfig ethwan up
			ifconfig brwan up
			ifconfig br0 up
			[ "$opmode_tmp" = "factory" ] && /etc/init.d/net-br start
			;;
		iptv)
			/etc/init.d/init6 stop
			/etc/init.d/net-lan stop
			if [ "$WanIndepPhy" = "0" ]; then
				ip link set dev $RawEthLan name ethlan
				ip link set dev $RawEthWan name ethwan
				brctl addif brwan ethwan
				$CONFIG set vlan_tag_1="1 Internet 10 0 0 0"
			else
				ifconfig $RawEthLan up
				vconfig add $RawEthLan 1 && ifconfig $RawEthLan.1 down
				vconfig add $RawEthLan 2 && ifconfig $RawEthLan.2 up
				brctl addif brwan $RawEthLan.2
				ip link set dev $RawEthLan.1 name ethlan
				ip link set dev $RawEthWan name ethwan
				[ "x$ethwan_as_lanport" = "x1" ] && brctl addif br0 ethwan
				ifconfig $RawDslWan up
				brctl addif brwan $RawDslWan
			fi
			brctl addif br0 ethlan
			sw_configvlan "iptv" $($CONFIG get iptv_mask)
			ifconfig ethlan up
			ifconfig ethwan up
			ifconfig brwan up
			ifconfig br0 up
			/etc/init.d/net-lan start
			/etc/init.d/init6 start
			;;
		vlan)
			/etc/init.d/init6 stop
			/etc/init.d/net-lan stop
			local lanvid=$(vlan_get_lanvid)
			local used_wports=0
			if [ "$WanIndepPhy" = "0" ]; then
				ip link set dev $RawEthLan name ethlan
				ifconfig $RawEthWan up
			else
				ifconfig $RawEthLan up
				vconfig add $RawEthLan $lanvid && ifconfig $RawEthLan.$lanvid down
				ip link set dev $RawEthLan.$lanvid name ethlan
				ip link set dev $RawEthWan name ethwan
				[ "x$ethwan_as_lanport" = "x1" ] && brctl addif br0 ethwan
				ifconfig ethwan up
			fi
			brctl addif br0 ethlan

			sw_configvlan "vlan" "start"
			for i in 1 2 3 4 5 6 7 8 9 10; do
				tv=$($CONFIG get vlan_tag_$i)
				[ -n "$tv" ] || continue
				set - $(echo $tv)
				# $1: enable, $2: name, $3: vid, $4: pri, $5:wports, $6:wlports
				[ "$1" = "1" ] || continue
				if [ "$2" = "Internet" ]; then
					vid=$3
					pri=$4
				else
					used_wports=$(($used_wports | $5))
					if [ "$WanIndepPhy" = "1" ] && [ "$dsl_video_vid" = "$3" ]; then
						local iptv_flag=1
					fi
					vlan_create_br_and_vif $3 $4 $iptv_flag
					sw_configvlan "vlan" "add" "br" $3 $5 $4
				fi
			done
			if [ "$WanIndepPhy" = "0" ]; then
				if [ "$vid" = "0" ]; then
					vid=$(vlan_get_wanvid) && pri=0
					vlan_create_internet_vif $vid $pri
					sw_configvlan "vlan" "add" "wan" "$vid" "0" "$pri"
				else
					vlan_create_internet_vif $vid $pri
					sw_configvlan "vlan" "add" "br" "$vid" "0" "$pri"
				fi
			else
				eth_vid=$(vlan_get_wanvid) && eth_pri=0
				[ "x$ethwan_as_lanport" = "x1" ] && sw_configvlan "vlan" "add" "dsl" "$eth_vid" "0" "$eth_pri"
				ifconfig $RawDslWan up
				if [ "x$vid" != "x" ]; then
					vconfig add $RawDslWan $vid
					ifconfig $RawDslWan.$vid up
					vlan_set_vif_pri $RawDslWan.$vid $pri
					brctl addif brwan $RawDslWan.$vid
				else
					brctl addif brwan $RawDslWan
				fi
			fi

			sw_configvlan "vlan" "add" "lan" "$lanvid" $(($used_wports ^ 0xf)) "0"
			sw_configvlan "vlan" "end"
			ifconfig ethlan up
			ifconfig ethwan up
			ifconfig brwan up
			ifconfig br0 up
			/etc/init.d/net-lan start
			/etc/init.d/init6 start
			;;
		*)
			/etc/init.d/net-br stop
			ip link set dev $RawEthLan name ethlan
			ip link set dev $RawEthWan name ethwan
			brctl addif br0 ethlan
			brctl addif br0 ethwan
			sw_configvlan "$opmode_tmp"
			ifconfig ethlan up
			ifconfig ethwan up
			ifconfig br0 up
			/etc/init.d/net-br start
			;;
	esac
	/etc/init.d/ntpclient start
}

func_dsl_net_wan () {
	[ "x$ctl_cmd" = "xstart" ] && dni_dsl_net_wan.sh $ctl_cmd $ctl_opt
	[ "x$ctl_cmd" = "xstop" ] && dni_dsl_net_wan.sh $ctl_cmd $ctl_opt
}

func_help () {
	echo "Usage: $0 <option> [ARGS=XXX]"
	echo "  Options:"
	for opt in $OPTIONS; do
		echo "     $opt"
	done
	exit 1
}

for opt in $OPTIONS; do
	if [ -n "$1" ] && [ "$1" = "$opt" ]; then
		if [ "$2" = "help" -o "$2" = "-h" ]; then
			func_$opt help;
		else
			shift
			eval $@
			func_$opt $1
		fi
		exit 0;
	fi
done
func_help
