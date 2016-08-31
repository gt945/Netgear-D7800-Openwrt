#the following line combines the last line to prevent this file from being sourced twice
if [ "x$enet_sh" = "x" ]; then enet_sh="sourced"
. /lib/cfgmgr/cfgmgr.sh

# this file is target depedent, it provids
# 1. following variables :
#      RawEth=         # name of raw eth NIF. not assigned means 2 eth NIFs, otherwise 1 eth NIF.
#      RawEthLan=      # name of raw eth NIF for lan.
#      RawEthWan=      # name of raw eth NIF for wan.
#      WanIndepPhy=    # 0 means RawEthWan doesn't have independent phy (ie. connects to switch).
#                      # 1 means RawEthWan has independent phy (ie. doesn't connects to switch).
# 2. following functions :
#      et_init()       # initialize ethernet & switch.
#      sw_configvlan() # configure switch vlan for all kind of opmode.
#

dsl_or_eth=$($CONFIG get dsl_wan_preference)
dsl_wan_type=$($CONFIG get dsl_wan_type)
dsl_data_vid=$($CONFIG get dsl_wan_data_vid)
dsl_video_vid=$($CONFIG get dsl_wan_video_vid)
dsl_wan_pri=$($CONFIG get dsl_wan_priority)
ethwan_as_lanport=$($CONFIG get ethwan_as_lan_port)
RawEth=
RawEthLan=eth1
RawEthWan=eth0

if [ "$dsl_or_eth" = "1" ]; then
	if [ "$dsl_wan_type" = "vdsl" ]; then
		RawDslWan=$($CONFIG get vdsl_wan_ifname)
		[ "X$dsl_data_vid" = "X" ] && dsl_wan_ifname=$RawDslWan || dsl_wan_ifname=$RawDslWan.$dsl_data_vid
	else
		RawDslWan=$($CONFIG get adsl_wan_ifname)
		[ "X$dsl_data_vid" = "X" ] && dsl_wan_ifname=$RawDslWan || dsl_wan_ifname=$RawDslWan.$dsl_data_vid 
	fi
	WanIndepPhy=1
	$CONFIG set vlan_tag_1="1 Internet ${dsl_data_vid:-0} ${dsl_wan_pri:-0} 0 0"
else
	WanIndepPhy=0
	$CONFIG set vlan_tag_1="1 Internet ${dsl_data_vid:-10} ${dsl_wan_pri:-0} 0 0"
fi

et_landefmac()
{
	[ -f /tmp/lan_mac ] && cat /tmp/lan_mac || \
	echo "00:03:7f:$(hexdump -n 4 /dev/urandom | awk 'NR==1 {print $2$3}' \
	                 | sed 's/../&:/g' | cut -c 1-8)"
}

et_wandefmac()
{
	[ -f /tmp/wan_mac ] && cat /tmp/wan_mac || \
	echo "00:03:7f:$(hexdump -n 4 /dev/urandom | awk 'NR==1 {print $2$3}' \
	                 | sed 's/../&:/g' | cut -c 1-8)"
}

get_reg() # $1: reg_addr
{
	ssdk_sh debug reg get $1 4 | grep -v "^$" | awk -F ':' '{print $2}'
}

set_reg() # $1: reg_addr, $2: value, $3: mask
{
	if [ $# == 2 ]; then
		ssdk_sh debug reg set $1 $2 4
		return
	fi

	local v0=$(get_reg $1)
	local v_value=$(($2 & $3))
	local v_clear=$(($3 ^ 0xffffffff))
	local real_value=$(($v0 & $v_clear | $v_value))
	ssdk_sh debug reg set $1 $real_value 4
}

# Add static ARL entry for SSDP packets
set_ssdp_bypass()
{
	# Parameter after command "add"
	# 1. mac addr
	# 2. fid
	# 3. dacmd			< forward >
	# 4. sacmd			< forward >
	# 5. dest port 		< set to 6 which attachs to ethlan >
	# 6. static 		< yes, never time aging>
	# 7. leaky			< yes, make this entry take effect across VLANs >
	# 8.9.10.11.12		mirror, clone, da_pri, queue, cross_pt_state
	# 13.14				white_list_en, load_balance_en
	ssdk_sh fdb entry add 01-00-5e-7f-ff-fa 1 forward forward 6 yes yes no no no no no no no
	[ "x$?" != "x0" ] && echo "### Set SSDP bypass failed! Need adjust!"
}

# Enable IGMP SNOOPING on LAN (0,2,3,4,5) ports
sw_enable_igmp_snooping() #
{
	set_reg 0x624 0x7f000000 0x7f000000  # IGMP_JOIN_LEAVE_DP : flood IGMP/MLD
	set_reg 0x210 0x06060606 0x06060606  # IGMP_LEAVE_EN & IGMP_JOIN_EN (0,1,2,3 ports)
	set_reg 0x214 0x01000006 0x01000006  # IGMP_V3_EN,
	                                     # IGMP_LEAVE_EN & IGMP_JOIN_EN (4 port)
	set_reg 0x618 0x10000000 0x10000000  # IGMP_JOIN_NEW_EN

	# This is only need when enable snooping
	# So I put it in this func.
	set_ssdp_bypass
}

sw_disable_igmp_snooping() #
{
	set_reg 0x624 0x7f000000 0x7f000000  # IGMP_JOIN_LEAVE_DP : flood IGMP/MLD
	set_reg 0x210 0x00000000 0x06060606  # IGMP_LEAVE_EN & IGMP_JOIN_EN (0,1,2,3 ports)
	set_reg 0x214 0x00000000 0x01000006  # IGMP_V3_EN,
	                                     # IGMP_LEAVE_EN & IGMP_JOIN_EN (4 port)
	set_reg 0x618 0x00000000 0x10000000  # IGMP_JOIN_NEW_EN
}

et_init()
{
	sw_init
	$CONFIG set lan_factory_mac="$(et_landefmac)"
	$CONFIG set wan_factory_mac="$(et_wandefmac)"
}

# for ap148-r7500 (8327 switch) : 
#    sw port0 -> CPU (RawEthWan)
#    sw port6 -> CPU (RawEthLan) 
#    sw port1 -> LAN4 
#    sw port2 -> LAN3 
#    sw port3 -> LAN2 
#    sw port4 -> LAN1 
#    sw port5 -> WAN 

ssdk_sh=$(which ssdk_sh)
swconfig=$(which swconfig)
swconf=/tmp/sw.conf
ssdk_cmds_file=/tmp/ssdk.sh

sw_init()                                                                                            
{                                                                                                    
	# workaround of switch hw issue on r7500                                                      
	$ssdk_sh debug reg set 0x04 0x07700000 4 >/dev/null                                           
	$ssdk_sh debug reg set 0xe4 0x0006a545 4 >/dev/null                                           
	sw_enable_igmp_snooping #enable ethernet lan snoop feature
}                                                                                                    

sw_printconf_add_switch()
{
	cat <<EOF
config switch
	option name 'switch0'
	option reset '1'
	option enable_vlan '1'

EOF
}

sw_printconf_add_vlan() # $1: device, $2: vlan, $3: vid, $4: ports
{
	cat <<EOF
config switch_vlan
	option device '$1'
	option vlan '$2'
	option vid '$3'
	option ports '$4'

EOF
}

sw_tmpconf_start()
{
	rm -f $swconf.tmp*
}

sw_tmpconf_add_vlan() # $1: vlanindex, $2: vid, $3: ports
{
	cat <<EOF > "$swconf.tmp$1"
vid="$2"
ports="$3"
EOF
}

sw_tmpconf_adjust_vlan() # $1: vlanindex, $2: vid, $3: ports
{
	local vid ports i=1

	while [ $i -le $1 ]; do
		. "$swconf.tmp$i"
		if [ "$vid" = "$2" ]; then
			for p in $3; do
				echo $ports | grep -q '\<'$p'\>' && continue
				ports="$ports $p"
			done
			sw_tmpconf_add_vlan "$i" "$vid" "$ports"
			return 0
		fi
		i=$(($i + 1))
	done

	return 1
}

sw_tmpconf_generate_swconf() # $1: vlanindex
{
	local vid ports i=1

	sw_printconf_add_switch
	while [ $i -le $1 ]; do
		. "$swconf.tmp$i"
		sw_printconf_add_vlan "switch0" "$i" "$vid" "$ports"
		i=$(($i + 1))
	done
}

sw_print_ssdk_cmds_start()
{
	echo -n
}

sw_print_ssdk_cmds_set_ports_pri() # $1: ports, $2: pri
{
	local p

	for p in $ports; do
		echo $p | grep -q "t" && continue

		cat <<EOF
$ssdk_sh qos ptDefaultCpri set $p $2
EOF
	done
}

sw_configvlan_factory()
{
	sw_printconf_add_switch > $swconf
	if [ "x$($CONFIG get factory_tt3)" = "x1" ]; then
		sw_printconf_add_vlan "switch0" "1" "1" "1 2 3 4 5" >> $swconf

		# This LED will be shut down later by other modules,
	    # so I run this again in init.d/done to make sure it's on
		ledcontrol -n usb1 -c amber -s on
	else
		sw_printconf_add_vlan "switch0" "1" "1" "6 1 2 3 4 5" >> $swconf
	fi
	$swconfig dev switch0 load $swconf
	sw_enable_igmp_snooping
}

sw_configvlan_normal()
{
	sw_printconf_add_switch > $swconf
	sw_printconf_add_vlan "switch0" "1" "1" "6 1 2 3 4" >> $swconf
	sw_printconf_add_vlan "switch0" "2" "2" "0 5" >> $swconf

	$swconfig dev switch0 load $swconf
	sw_enable_igmp_snooping
}

i_mask() # $1: 1 / 2 / 3 / 4
{
	case $1 in
	1) echo 8 ;;
	2) echo 4 ;;
	3) echo 2 ;;
	4) echo 1 ;;
	esac
}

sw_configvlan_iptv() # $1: iptv_mask $2 vlan id for wan
{
	local i mask=$(($1 & 0xf))
	local vid
	if [ "$WanIndepPhy" = "0" ]; then
		local ports1="6" ports2="0 5"
	else
		local ports1="6t" ports2="6t" ports3="0 5"
	fi

	[ "x$2" != "x" ] && vid=$2 || vid=2
	for i in 1 2 3 4; do
		[ $(( $(i_mask $i) & $mask )) -eq 0 ] && ports1="$ports1 $i" || ports2="$ports2 $i"
	done

	sw_printconf_add_switch > $swconf
	sw_printconf_add_vlan "switch0" "1" "1" "$ports1" >> $swconf
	sw_printconf_add_vlan "switch0" "2" "$vid" "$ports2" >> $swconf
	[ "$WanIndepPhy" = "1" -a "x$ethwan_as_lanport" = "x1" ] && sw_printconf_add_vlan "switch0" "3" "3" "$ports3" >> $swconf

	$swconfig dev switch0 load $swconf
	sw_enable_igmp_snooping
}

sw_configvlan_vlan()
# $1: start
#     add -> $2: br/wan/lan, $3: vid, $4: mask, $5: pri
#     end
{
	case "$1" in
	start)
		sw_tmpconf_start
		sw_print_ssdk_cmds_start > $ssdk_cmds_file
		g_vlanindex=0
		;;
	add)
		local vid=$3 mask=$(($4 & 0xf)) pri=$5
		local i ports

		case "$2" in
			br) [ "$WanIndepPhy" = "0" ] && ports="0t 5t" || ports="6t" ;;
			lan) [ "$WanIndepPhy" = "0" ] && ports="6" || ports="6t" ;;
			wan) ports="0t 5" ;;
			dsl) [ "x$ethwan_as_lanport" = "x1" ] && ports="0 5" || return ;;
		esac
		for i in 1 2 3 4; do
			[ $(( $(i_mask $i) & $mask )) -eq 0 ] || ports="$ports $i"
		done
		sw_tmpconf_adjust_vlan "$g_vlanindex" "$vid" "$ports" || {
			g_vlanindex=$(($g_vlanindex + 1))
			sw_tmpconf_add_vlan "$g_vlanindex" "$vid" "$ports"
		}
		sw_print_ssdk_cmds_set_ports_pri "$ports" "$pri" >> $ssdk_cmds_file

		;;
	end)
		sw_tmpconf_generate_swconf $g_vlanindex > $swconf
		$swconfig dev switch0 load $swconf
		qt sh $ssdk_cmds_file
		sw_enable_igmp_snooping
		;;
	esac
}

sw_configvlan() # $1 : normal/iptv/vlan/apmode/brmode
{
	local opmode=$1

	shift
	case "$opmode" in
	normal) sw_configvlan_normal "$@" ;;
	iptv) sw_configvlan_iptv "$@" ;;
	vlan) sw_configvlan_vlan "$@" ;;
	factory) sw_configvlan_factory "$@" ;;
	*) sw_configvlan_normal "$@" ;;
	esac
}

fi #-------------------- this must be the last line -----------------------------
