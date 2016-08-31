#the following line combines the last line to prevent this file from being sourced twice
if [ "x$opmode_sh" = "x" ]; then opmode_sh="sourced"
. /lib/cfgmgr/cfgmgr.sh
. /lib/cfgmgr/enet.sh

# name of NIF :
#   Eth Lan NIF will always be "ethlan"
#   Eth Wan NIF will always be "ethwan"
#   Lan NIF will always be "br0"
#   Wan NIF will be "brwan" or "ppp0"

# vlan-iptv related configs :
#
#   enable_vlan (1/0) : enable / disable
#     vlan_type (1/0) : vlan group / bridge group (iptv)
#
#   vlan group configs :
#     vlan_tag_1 ~ vlan_tag_10 :
#         Enable   Name      VID     Priority   lan-ports    wireless
#          1/0    xxxxxx    1-4094     0-7      x (4bits)    x (4bits)
#        lan-ports : 
#            bit0 -> lan1       belongs to vlan group or not
#            bit1 -> lan2       belongs to vlan group or not
#            bit2 -> lan3       belongs to vlan group or not
#            bit3 -> lan4       belongs to vlan group or not
#        wireless :
#            bit0 -> 2.4G       belongs to vlan group or not
#            bit1 -> 5G         belongs to vlan group or not
#            bit3 -> 2.4G-Guest belongs to vlan group or not
#            bit4 -> 5G-Guest   belongs to vlan group or not
#
#   bridge group (iptv) configs :
#     wan_brig_ssid1 (1/0)       : 2.4G       belongs to bridge group or not
#     wan_brig_ssid2 (1/0)       : 5G         belongs to bridge group or not
#     wan_brig_guest_ssid1 (1/0) : 2.4G-Guest belongs to bridge group or not
#     wan_brig_guest_ssid2 (1/0) : 5G-Guest   belongs to bridge group or not
#     iptv_mask (4 bits) : 
#            bit0 -> lan1                     belongs to bridge group or not
#            bit1 -> lan2                     belongs to bridge group or not
#            bit2 -> lan3                     belongs to bridge group or not
#            bit3 -> lan4                     belongs to bridge group or not
#     iptv_mask_change :
#
#   wlg1_endis_guestNet (1/0) : 2.4G-Guest enable or not
#   wla1_endis_guestNet (1/0) :   5G-Guest enable or not
#
#   opmode related induced configs : 
#     i_opmode (normal/iptv/vlan/apmode/brmode) : device operation mode
#     i_wlg_br                                  : the bridge wlg belongs to
#     i_wla_br                                  : the bridge wla belongs to
#     i_wlg_guest_br                            : the bridge wlg_guest belongs to
#     i_wla_guest_br                            : the bridge wla_guest belongs to
#     i_wlg_pri                                 : the priority of wlg
#     i_wla_pri                                 : the priority of wla
#     i_wlg_guest_pri                           : the priority of wlg_guest
#     i_wla_guest_pri                           : the priority of wla_guest
#

op_opmode() # ret: factory / brmode / apmode / extmode / normal / vlan / iptv
{
	[ "$($CONFIG get factory_mode)" = "1" ] && echo "factory" && return
	[ "$($CONFIG get extender_mode)" = "1" ] && echo "extmode" && return
	[ $($CONFIG get bridge_mode) = "1" ] && echo "brmode" && return
	[ $($CONFIG get ap_mode) = "1" ] && echo "apmode" && return
	! [ $($CONFIG get enable_vlan) = "1" ] && echo "normal" && return
	[ $($CONFIG get vlan_type) = "1" ] && echo "vlan" || echo "iptv"
}

op_set_induced_configs()
{
	local opmode=$(op_opmode)
	local i_wlg_br="br0" i_wla_br="br0" i_wlg_guest_br="br0" i_wla_guest_br="br0"
	local i_wlg_pri="" i_wla_pri="" i_wlg_guest_pri="" i_wla_guest_pri=""
	local i tv i_vid

	oc echo "opmode = $opmode"
	$CONFIG set i_opmode=$opmode

	case "$opmode" in
	iptv)
		[ "$($CONFIG get wan_brig_ssid1)" = "1" ] && i_wlg_br="brwan"
		[ "$($CONFIG get wan_brig_ssid2)" = "1" ] && i_wla_br="brwan"
		[ "$($CONFIG get wan_brig_guest_ssid1)" = "1" ] && i_wlg_guest_br="brwan"
		[ "$($CONFIG get wan_brig_guest_ssid2)" = "1" ] && i_wla_guest_br="brwan"
		;;

	vlan)
		for i in 1 2 3 4 5 6 7 8 9 10; do
			tv=$($CONFIG get vlan_tag_$i)
			[ -n "$tv" ] || continue
			set - $(echo $tv)
			# $1: enable, $2: name, $3: vid, $4: pri, $5:wports, $6:wlports
			[ "$1" = "1" ] || continue
			[ "$2" = "Internet" ] && i_vid=$3 && continue
			[ $(( 1 & $6 )) -ne 0 ] && i_wlg_br="br$3" && i_wlg_pri="$4"
			[ $(( 2 & $6 )) -ne 0 ] && i_wla_br="br$3" && i_wla_pri="$4"
			[ $(( 4 & $6 )) -ne 0 ] && i_wlg_guest_br="br$3" && i_wlg_guest_pri="$4"
			[ $(( 8 & $6 )) -ne 0 ] && i_wla_guest_br="br$3" && i_wla_guest_pri="$4"
		done
		[ "$i_vid" != "0" ] && {
			[ "$i_wlg_br" = "br$i_vid" ] && i_wlg_br="brwan"
			[ "$i_wla_br" = "br$i_vid" ] && i_wla_br="brwan"
			[ "$i_wlg_guest_br" = "br$i_vid" ] && i_wlg_guest_br="brwan"
			[ "$i_wla_guest_br" = "br$i_vid" ] && i_wla_guest_br="brwan"
		}
		;;
	esac

	$CONFIG set i_wlg_br="$i_wlg_br"
	$CONFIG set i_wla_br="$i_wla_br"
	$CONFIG set i_wlg_guest_br="$i_wlg_guest_br"
	$CONFIG set i_wla_guest_br="$i_wla_guest_br"
	$CONFIG set i_wlg_pri="$i_wlg_pri"
	$CONFIG set i_wla_pri="$i_wla_pri"
	$CONFIG set i_wlg_guest_pri="$i_wlg_guest_pri"
	$CONFIG set i_wla_guest_pri="$i_wla_guest_pri"
}

br_create() # $1: brname
{
	brctl addbr $1
	brctl setfd $1 0
	brctl stp $1 0
	echo 0 > /sys/devices/virtual/net/$1/bridge/multicast_snooping
}

br_allbrs()
{
	awk '/br[0-9w]/ {print $1}' /proc/net/dev |sed 's/://g'
}

br_allnifs() # $1: brx
{
	brctl show $1 | awk '!/bridge/ {print $NF}' | grep "eth\|ath\|nas\|ptm\|host0."
}

op_del_all_brs_vifs()
{
	local brx nif

	for brx in $(br_allbrs); do
		ifconfig $brx down
		for nif in $(br_allnifs $brx); do 
			ifconfig $nif down
			brctl delif $brx $nif
			case "$nif" in
			ethlan|ethwan)
				;;
			eth*)
				vconfig rem $nif
				;;
			esac
		done
		[ "$brx" != br0 -a "$brx" != "brwan" ] && brctl delbr $brx
	done

	ifconfig ethlan down
	vconfig rem ethlan || ip link set dev ethlan name $RawEthLan
	ifconfig ethwan down
	vconfig rem ethwan || ip link set dev ethwan name $RawEthWan
	[ -n "$RawEth" ] && ifconfig $RawEth down || {
		ifconfig $RawEthLan down
		ifconfig $RawEthWan down
	}
}

op_create_br0_brwan()
{
	br_create br0
	br_create brwan
}

create_brs_and_vifs() # $1: noraml / apmode / factory
{
	local landefmac=$($CONFIG get lan_factory_mac)
	local wandefmac=$($CONFIG get wan_factory_mac)

	if [ -n "$RawEth" ]; then
		ifconfig $RawEth hw ether $landefmac
		ifconfig $RawEth up
		vconfig add $RawEth 0 && ifconfig $RawEth.0 down
		vconfig add $RawEth 1 && ifconfig $RawEth.1 down
		ip link set dev $RawEth.0 name ethlan
		ip link set dev $RawEth.1 name ethwan
	else
		ifconfig $RawEthLan hw ether $landefmac
		ifconfig $RawEthWan hw ether $wandefmac
		ip link set dev $RawEthLan name ethlan
		ip link set dev $RawEthWan name ethwan
	fi

	brctl addif br0 ethlan
	ifconfig br0 hw ether $landefmac
	case "$1" in
	normal)
		if [ "x$WanIndepPhy" = "x1" ]; then
			[ "x$ethwan_as_lanport" = "x1" ] && brctl addif br0 ethwan
		else
			brctl addif brwan ethwan
		fi
		sw_configvlan "normal"
		;;
	apmode)
		brctl addif br0 ethwan
		sw_configvlan "apmode"
		;;
	factory)
		sw_configvlan "factory"
		;;
	esac
}

iptv_create_brs_and_vifs()
{
	local landefmac=$($CONFIG get lan_factory_mac)
	local wandefmac=$($CONFIG get wan_factory_mac)

	if [ -n "$RawEth" ]; then
		ifconfig $RawEth hw ether $landefmac
		ifconfig $RawEth up
		vconfig add $RawEth 0 && ifconfig $RawEth.0 down
		vconfig add $RawEth 1 && ifconfig $RawEth.1 down
		ip link set dev $RawEth.0 name ethlan
		ip link set dev $RawEth.1 name ethwan
	else
		ifconfig $RawEthLan hw ether $landefmac
		ifconfig $RawEthWan hw ether $wandefmac
		if [ "$WanIndepPhy" = "0" ]; then
			ip link set dev $RawEthLan name ethlan
			ip link set dev $RawEthWan name ethwan
		else
			ifconfig $RawEthLan up
			vconfig add $RawEthLan 1 && ifconfig $RawEthLan.1 down
			vconfig add $RawEthLan 2 && ifconfig $RawEthLan.2 up
			brctl addif brwan $RawEthLan.2
			ip link set dev $RawEthLan.1 name ethlan
			ip link set dev $RawEthWan name ethwan
		fi
	fi

	brctl addif br0 ethlan
	ifconfig br0 hw ether $landefmac
	if [ "x$WanIndepPhy" = "x1" ]; then
		[ "x$ethwan_as_lanport" = "x1" ] && brctl addif br0 ethwan
	else
		brctl addif brwan ethwan
	fi
	sw_configvlan "iptv" $($CONFIG get iptv_mask)
}

vlan_set_vif_pri() # $1: vif, $2: pri
{
	local p

	for p in 0 1 2 3 4 5 6 7; do
		vconfig set_ingress_map $1 $p $p
		vconfig set_egress_map $1 $p $2
	done
}

nif_existed() # $1: nif
{
	ifconfig $1 >/dev/null 2>&1
}

vlan_create_br_and_vif() # $1: vid, $2: pri
{
	local brx="br$1"

	[ "x$WanIndepPhy" = "x1" ] && [ $dsl_data_vid = $1 ] && return
#	[ "x$WanIndepPhy" = "x1" ] && [ $dsl_video_vid = $1 ] && return

	nif_existed $brx && return

	br_create $brx
	if [ -n "$RawEth" ]; then
		vconfig add $RawEth $1 && ifconfig $RawEth.$1 up
		brctl addif $brx $RawEth.$1
		vlan_set_vif_pri $RawEth.$1 $2
	else
		if [ "$WanIndepPhy" = "0" ]; then
			vconfig add $RawEthWan $1 && ifconfig $RawEthWan.$1 up
			brctl addif $brx $RawEthWan.$1
			vlan_set_vif_pri $RawEthWan.$1 $2
		else
			vconfig add $RawEthLan $1 && ifconfig $RawEthLan.$1 up
			brctl addif $brx $RawEthLan.$1
	#		if [ $dsl_video_vid = $1 -a -z "$3" ]; then
	#			ifconfig $brx up
	#			return
	#		fi
			vconfig add $RawDslWan $1 && ifconfig $RawDslWan.$1 up
			brctl addif $brx $RawDslWan.$1
			vlan_set_vif_pri $RawDslWan.$1 $2
		fi
	fi
	ifconfig $brx up
}

vlan_create_internet_vif() # $1: vid, $2: pri
{
	local brx="br$1"

	if nif_existed $brx; then
		ifconfig $brx down
		if [ -n "$RawEth" ]; then
			ifconfig $RawEth.$1 down && brctl delif $brx $RawEth.$1
			ip link set dev $RawEth.$1 name ethwan
		else
			if [ "$WanIndepPhy" = "0" ]; then
				ifconfig $RawEthWan.$1 down && brctl delif $brx $RawEthWan.$1
			else
				ifconfig $RawEthLan.$1 down && brctl delif $brx $RawEthLan.$1
				ifconfig $RawEthWan.$1 down && brctl delif $brx $RawEthWan.$1
				brctl addif brwan $RawEthLan.$1
			fi
			ip link set dev $RawEthWan.$1 name ethwan
		fi
		brctl delbr $brx
	else
		if [ -n "$RawEth" ]; then
			vconfig add $RawEth $1 && ifconfig $RawEth.$1 down
			ip link set dev $RawEth.$1 name ethwan
		else
			vconfig add $RawEthWan $1 && ifconfig $RawEthWan.$1 down
			ip link set dev $RawEthWan.$1 name ethwan
		fi
	fi
	vlan_set_vif_pri ethwan $2
	brctl addif brwan ethwan
}

vlan_get_freevid() # $1: up / down
{
	local updown=$1
	local i tv vids
	local freevid

	for i in 1 2 3 4 5 6 7 8 9 10; do
		tv=$($CONFIG get vlan_tag_$i)
		[ -n "$tv" ] || continue
		set - $(echo $tv)
		# $1: enable, $2: name, $3: vid, $4: pri, $5:wports, $6:wlports
		[ "$1" = "1" ] || continue
		[ "$2" = "Internet" ] && continue
		[ "$vids" = "" ] && vids="x${3}x" || vids="$vids x${3}x"
	done

	[ "$updown" = "up" ] && freevid=1 || freevid=4094
	while true; do
		echo $vids | grep -q "x${freevid}x" || break
		[ "$updown" = "up" ] && freevid=$(($freevid + 1)) || freevid=$(($freevid - 1))
	done
	echo $freevid
}

vlan_get_lanvid()
{
	vlan_get_freevid up
}

vlan_get_wanvid()
{
	vlan_get_freevid down
}

vlan_create_brs_and_vifs()
{
	local landefmac=$($CONFIG get lan_factory_mac)
	local wandefmac=$($CONFIG get wan_factory_mac)
	local lanvid=$(vlan_get_lanvid)

	local i tv used_wports=0
	local i_vid i_pri

	if [ -n "$RawEth" ]; then
		ifconfig $RawEth hw ether $landefmac
		ifconfig $RawEth up
		vconfig add $RawEth 0 && ifconfig $RawEth.0 down
		ip link set dev $RawEth.0 name ethlan
	else
		ifconfig $RawEthLan hw ether $landefmac
		ifconfig $RawEthWan hw ether $wandefmac
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
	fi
	brctl addif br0 ethlan
	ifconfig br0 hw ether $landefmac

	sw_configvlan "vlan" "start"
	for i in 1 2 3 4 5 6 7 8 9 10; do
		tv=$($CONFIG get vlan_tag_$i)
		[ -n "$tv" ] || continue
		set - $(echo $tv)
		# $1: enable, $2: name, $3: vid, $4: pri, $5:wports, $6:wlports
		[ "$1" = "1" ] || continue
		if [ "$2" = "Internet" ]; then 
			i_vid=$3
			i_pri=$4
		else
			used_wports=$(($used_wports | $5))
			vlan_create_br_and_vif $3 $4
			sw_configvlan "vlan" "add" "br" $3 $5 $4
		fi
	done
	if [ "x$WanIndepPhy" = "x0" ]; then
		if [ "$i_vid" = "0" ]; then
			i_vid=$(vlan_get_wanvid) && i_pri=0
			vlan_create_internet_vif $i_vid $i_pri
			sw_configvlan "vlan" "add" "wan" "$i_vid" "0" "$i_pri"
		else
			vlan_create_internet_vif $i_vid $i_pri
			sw_configvlan "vlan" "add" "br" "$i_vid" "0" "$i_pri"
		fi
	else
		if [ "x$ethwan_as_lanport" = "x1" ]; then
			i_vid=$(vlan_get_wanvid) && i_pri=0
			sw_configvlan "vlan" "add" "dsl" "$i_vid" "0" "$i_pri"
		fi
	fi

	sw_configvlan "vlan" "add" "lan" "$lanvid" $(($used_wports ^ 0xf)) "0"
	sw_configvlan "vlan" "end"
}

op_create_brs_and_vifs()
{
	local opmode=$($CONFIG get i_opmode)
	echo "dsl_wan_ifname=$dsl_wan_ifname"

	#for vlan mode, xdsl WAN1 vlan should be enabled
	if [ "$opmode" = "vlan" ]; then
		$CONFIG set dsl_wan_enable_vlanidActive=1
	fi

	case "$opmode" in
	normal) create_brs_and_vifs normal ;;
	iptv) iptv_create_brs_and_vifs ;;
	vlan) vlan_create_brs_and_vifs ;;
	factory) create_brs_and_vifs factory ;;
	*) create_brs_and_vifs apmode ;;
	esac
}

fi #-------------------- this must be the last line -----------------------------
