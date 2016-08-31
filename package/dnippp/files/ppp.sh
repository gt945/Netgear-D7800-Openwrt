. /dni-gconfig

DIAL_PRVD="dial-provider"
DIAL_PRVD_FILE="/etc/ppp/peers/$DIAL_PRVD"

# To remove files/config.h, add below options
#
# General option:
#	dni_ip_conflict_cmd		-str
#	dni_firewall_cmd		-str
#	dni_dns_setup_cmd		-str
#	wan_eth_if				-str
# dni-pptp option:
#	pptp_hostname			-str
#	pptp_vendor				-str
# rp-pppoe option:
#	dni_add_sn				-bool

print_pppoe_options(){
cat <<EOF
noipdefault
defaultroute
hide-password
$2
noauth
noaccomp
default-asyncmap
connect /bin/true
mtu $3
mru $3
$4
$5
lcp-echo-interval 10
lcp-echo-failure 3
user $1
plugin rp-pppoe.so $8
$6
$7
EOF
}

print_pppoe_options_v6(){
cat <<EOF
+ipv6
ipv6cp-accept-local
ipv6cp-use-persistent
noipdefault
defaultroute
hide-password
$2
noauth
noaccomp
default-asyncmap
connect /bin/true
mtu $3
mru $3
$4
$5
lcp-echo-interval 10
lcp-echo-failure 3
user $1
plugin rp-pppoe.so $8
$6
$7
EOF
}


print_pptp_options(){
    cat <<EOF
noauth
noipdefault
defaultroute
ipparam pptp
refuse-eap
mtu $2
mru $2
$3
$4
$6
lcp-echo-interval 10
lcp-echo-failure 3
user $1
plugin dni-pptp.so $5
$7
pptp_iface $8
EOF
}

# 1.$user 2.$mtu 3.$idle 4.$demand 5.$ip 6.$dns 7.$gw 8.brwan
print_l2tp_options(){
    cat <<EOF
noauth
noipdefault
defaultroute
ipparam l2tp
refuse-eap
mtu $2
mru $2
$3
$4
$6
lcp-echo-interval 10
lcp-echo-failure 3
user $1
plugin dni-l2tp.so $5
$7
l2tp_iface $8
EOF
}

print_pppoa_options(){
	cat <<EOF
linkname pppoatm-0
lcp-echo-interval 30
lcp-echo-failure 4
unit 0
maxfail 0
usepeerdns
noipdefault
defaultroute
user $1
password $2
mtu $3
mru $3
holdoff 4
$4
$5
plugin pppoatm.so
$6
0.$7.$8
EOF
}

append_general_options(){
	cat <<EOF
dni_ip_conflict_cmd "/sbin/ipconflict"
dni_firewall_cmd "firewall.sh start"
dni_dns_setup_cmd "/bin/echo \"nameserver 10.112.112.112\" > /tmp/resolv.conf"
wan_eth_if $1
EOF
}

append_rp_pppoe_options(){
	cat <<EOF
dni_add_sn
EOF
}

# $1.hostname 2.vendor
append_pptp_options(){
	cat <<EOF
pptp_hostname $1
pptp_vendor $2
EOF
}

insert_modules(){
	if [ "$1" = "pptp" ]; then
		load_modules /etc/modules.d/60-pptp-mod
	elif [ "$1" = "3g" ]; then
		load_modules /etc/modules.d/60-3g-mod
	elif [ "$1" = "l2tp" ]; then
		load_modules /etc/modules.d/60-l2tp-mod
	elif [ "$1" = "pppoa" ]; then
	load_modules /etc/modules.d/60-pppoa-mod
	else
		load_modules /etc/modules.d/60-pppoe-mod
	fi
}

print_ip_up() 
{
    cat <<EOF
#!/bin/sh
firewall.sh start
/sbin/cmdroute stop
/sbin/cmdroute start
/usr/etc/functions/ripd_functions restart
echo -n 1 > /etc/ppp/ppp0-status
cat /proc/uptime | awk '{print\$1}' > /tmp/ppp/ppp_last_conn_time
#cmd_traffic_meter config_update
/sbin/ledcontrol -n wan -c green -s on
staticdns1="\$(config get wan_ether_dns1)"
staticdns2="\$(config get wan_ether_dns2)"
if [ "\$(config get wan_proto)" = "pptp" -a "\$(config get wan_pptp_dns_assign)" = "1" ]; then
        echo nameserver "\$staticdns1" > /tmp/resolv.conf
        echo nameserver "\$staticdns2" >> /tmp/resolv.conf
        if [ "x\$staticdns1" != "x" ]; then
                /sbin/route del \$staticdns1
        elif [ "x\$staticdns2" != "x" ]; then
                /sbin/route del \$staticdns2
        fi
elif [ "\$(config get wan_proto)" = "l2tp" -a "\$(config get wan_l2tp_dns_assign)" = "1" ]; then
        echo nameserver "\$staticdns1" > /tmp/resolv.conf
        echo nameserver "\$staticdns2" >> /tmp/resolv.conf
        if [ "x\$staticdns1" != "x" ]; then
                /sbin/route del \$staticdns1
        elif [ "x\$staticdns2" != "x" ]; then
                /sbin/route del \$staticdns2
        fi
	elif [ "\$(config get wan_proto)" = "pppoe" -o "\$(config get wan_proto)" = "pppoa" ] && [ "\$(config get wan_pppoe_dns_assign)" = "1" ]; then
        echo nameserver "\$staticdns1" > /tmp/resolv.conf
        echo nameserver "\$staticdns2" >> /tmp/resolv.conf
fi
if [ "\$(config get wan_proto)" = "pptp" -a "\$(config get wan_pptp_wan_assign)" = "0" ]; then
	cat /tmp/dhcpc_resolv.conf >> /tmp/resolv.conf
elif [ "\$(config get wan_proto)" = "l2tp" -a "\$(config get wan_l2tp_wan_assign)" = "0" ]; then
	cat /tmp/dhcpc_resolv.conf >> /tmp/resolv.conf
elif [ "\$(config get wan_proto)" = "pppoe" -o "\$(config get wan_proto)" = "pppoa" ] && [ "\$(config get wan_pppoe_intranet_wan_assign)" = "0" ]; then
	cat /tmp/dhcpc_resolv.conf >> /tmp/resolv.conf
fi

[ "\$(/bin/config get ipv6_sameinfo)" = "1" ] && /etc/net6conf/6pppoe adddns


local qos_enable=\$(/bin/config get qos_endis_on)
local qos_bandwidth_enable=\$(/bin/config get qos_threshold)
local qos_bandwidth_type=\$(/bin/config get qos_bandwidth_type)
if [ "x\$qos_enable" = "x1" -a "x\$qos_bandwidth_enable" = "x1" ]; then
	if [ "x\$qos_bandwidth_type" = "x1" ]; then
		/etc/bandcheck/band-check &
	fi
fi
local ipv6_wantype=\$(/bin/config get ipv6_type)
if [ "x\$ipv6_wantype" != "x" -a "\$ipv6_wantype" != "disabled" -a "\$ipv6_wantype" != "bridge" -a "\$ipv6_wantype" != "pppoe" ]; then
	killall net6conf
	/etc/net6conf/net6conf restart
fi
cmd_igmp start
EOF
}

print_ip_down()
{
    cat <<EOF
#!/bin/sh
cmd_igmp stop
/usr/etc/functions/ripd_functions stop
echo -n 0 > /etc/ppp/ppp0-status
cat /proc/uptime | awk '{print$1}' > /tmp/ppp/ppp_last_stop_time
#/usr/bin/killall -SIGINT traffic_meter
# wait 1 second to execute SIGINT signal handler
sleep 1
#cmd_traffic_meter config_update
/sbin/ledcontrol -n wan -c amber -s on
local ipv6_wantype=\$(/bin/config get ipv6_type)
if [ "x\$ipv6_wantype" = "x6to4" ]; then
	killall net6conf
	/etc/net6conf/net6conf stop
fi
EOF
}

early_prepare()
{
	mknod /dev/ppp c 108 0
	mkdir -p /tmp/ppp
	mkdir -p /etc/ppp/peers

	print_ip_up > /etc/ppp/ip-up
	chmod 0777 /etc/ppp/ip-up
	print_ip_down > /etc/ppp/ip-down
	chmod 0777 /etc/ppp/ip-down
}

setup_interface_ppp() {
	local user passwd dns mtu mru idle demand service ip proto gw language staticdns1 staticdns2 pptp_wan_assign pppoe_type
	local wan_if wan_endis_dod

	early_prepare

	[ "x${DGC_WAN_IF_NONUSE_BRIDGE}" = "xy" ] && wan_if=$DGC_WAN_ETH_IF || wan_if=$DGC_WAN_BR_IF
	wan_endis_dod=$($CONFIG get wan_endis_dod)

	pppoe_type=`config get ipv6_sameinfo`
	proto=$($CONFIG get wan_proto)
	if [ "$proto" = "pptp" ]; then
		insert_modules "pptp"
		user=$($CONFIG get wan_pptp_username)
		passwd=$($CONFIG get wan_pptp_password)
		mtu=$($CONFIG get wan_pptp_mtu)
		if [ "x$wan_endis_dod" = "x1" ]; then
			if [ "$($CONFIG get wan_pptp_idle_time)" = "0" ]; then
				idle="persist"
			else
				idle="idle $($CONFIG get wan_pptp_idle_time)"
				demand="demand"
			fi
		elif [ "x$wan_endis_dod" = "x2" ]; then
			[ "x$1" != "xmanually" -a "x$($CONFIG get run_test)" != "xtest" ] && exit 0
			idle="runone"
		else
			idle="persist"
		fi
		if [ "$($CONFIG get wan_pptp_wan_assign)" != "0" ]; then
			route=$($CONFIG get pptp_gw_static_route)
			[ "x$route" != "x" ] && gw="pptp_gateway $route"
		fi
		[ "$($CONFIG get wan_pptp_dns_assign)" != "1" ] && dns="usepeerdns"
		ip=$($CONFIG get wan_pptp_server_ip)
		language="language $($CONFIG get GUI_Region)"
		pptp_wan_assign="pptp_wan_assign $($CONFIG get wan_pptp_wan_assign)"
		pptp_conn_id="pptp_conn_ID $($CONFIG get wan_pptp_connection_id)"
		if [ "$($CONFIG get wan_pptp_dns_assign)" != "0" ]; then
			staticdns1="$($CONFIG get wan_ether_dns1)"
			staticdns2="$($CONFIG get wan_ether_dns2)"
			[ "x$staticdns1" != "x" ] && staticdns1="pptp_dns1 $staticdns1"
			[ "x$staticdns2" != "x" ] && staticdns2="pptp_dns2 $staticdns2"
		fi

		print_pptp_options "$user" "${mtu:-1492}" "$idle" "$demand" "$ip" "$dns" "$gw" "${wan_if:-brwan}" > $DIAL_PRVD_FILE
		if [ "$($CONFIG get wan_pptp_dns_assign)" = "1" ]; then
			echo "$pptp_wan_assign" >> $DIAL_PRVD_FILE
			echo "$staticdns1" >> $DIAL_PRVD_FILE
			echo "$staticdns2" >> $DIAL_PRVD_FILE
		fi
		if [ "x$($CONFIG get wan_pptp_connection_id)" != "x" ]; then
			echo "$pptp_conn_id">> $DIAL_PRVD_FILE
		fi
		sed -i '/user/ s/\\/\\\\/g' $DIAL_PRVD_FILE
		sed -i '/user/ s/\#/\\#/g' $DIAL_PRVD_FILE

		append_pptp_options "${DGC_MODULE_NAME:-R7500}" "${DGC_VENDOR:-NETGEAR}" >> $DIAL_PRVD_FILE
	elif [ "$proto" = "l2tp" ]; then
		insert_modules "l2tp"
		user=$($CONFIG get wan_l2tp_username)
		passwd=$($CONFIG get wan_l2tp_password)
		mtu=$($CONFIG get wan_l2tp_mtu)
		if [ "x$wan_endis_dod" = "x1" ]; then
			if [ "$($CONFIG get wan_l2tp_idle_time)" = "0" ]; then
				idle="persist"
			else
				idle="idle $($CONFIG get wan_l2tp_idle_time)"
				demand="demand"
			fi
		elif [ "x$wan_endis_dod" = "x2" ]; then
			[ "x$1" != "xmanually" -a "x$($CONFIG get run_test)" != "xtest" ] && exit 0
			idle="runone"
		else
			idle="persist"
		fi
		if [ "$($CONFIG get wan_l2tp_wan_assign)" != "0" ]; then
			route=$($CONFIG get l2tp_gw_static_route)
			[ "x$route" != "x" ] && gw="l2tp_gateway $route"
		fi
		[ "$($CONFIG get wan_l2tp_dns_assign)" != "1" ] && dns="usepeerdns"
		if [ "$($CONFIG get wan_l2tp_dns_assign)" != "0" ]; then
			staticdns1="$($CONFIG get wan_ether_dns1)"
			staticdns2="$($CONFIG get wan_ether_dns2)"
			[ "x$staticdns1" != "x" ] && staticdns1="l2tp_dns1 $staticdns1"
			[ "x$staticdns2" != "x" ] && staticdns2="l2tp_dns2 $staticdns2"
		fi

		ip=$($CONFIG get wan_l2tp_server_ip)
		l2tp_wan_assign="l2tp_wan_assign $($CONFIG get wan_l2tp_wan_assign)"

		print_l2tp_options "$user" "${mtu:-1428}" "$idle" "$demand" "$ip" "$dns" "$gw" "${wan_if:-brwan}" > $DIAL_PRVD_FILE
		if [ "$($CONFIG get wan_l2tp_dns_assign)" = "1" ]; then
			echo "$l2tp_wan_assign" >> $DIAL_PRVD_FILE
			echo "$staticdns1" >> $DIAL_PRVD_FILE
			echo "$staticdns2" >> $DIAL_PRVD_FILE
		fi
		sed -i '/user/ s/\\/\\\\/g' $DIAL_PRVD_FILE
		sed -i '/user/ s/\#/\\#/g' $DIAL_PRVD_FILE
	elif [ "$proto" = "pppoa" ]; then
		insert_modules "pppoa"
		user=$($CONFIG get wan_pppoa_username)
		passwd=$($CONFIG get wan_pppoa_passwd)
		mtu=$($CONFIG get wan_pppoa_mtu)
		vpi=$($CONFIG get dsl_wan_vpi)
		vci=$($CONFIG get dsl_wan_vci)
		encaps=$($CONFIG get dsl_wan_multiplex)
		if [ "$($CONFIG get wan_endis_dod)" = "1" ]; then
	    	if [ "$($CONFIG get wan_pppoa_idletime)" = "0" ]; then
                idle="persist"
            else
                idle="idle $($CONFIG get wan_pppoa_idletime)"
                demand="demand"
            fi
		elif [ "$($CONFIG get wan_endis_dod)" = "2" ]; then
	    	[ "x$1" != "xmanually" -a "x$($CONFIG get run_test)" != "xtest" ] && exit 0
	    	idle="runone"
		else
	    	idle="persist"
		fi
		([ -n "$encaps" ] && [ "$encaps" = "vc" ]) && encaps_value=vc-encaps || encaps_value=llc-encaps
		print_pppoa_options "$user" "$passwd" "$mtu" "$idle" "$demand" "$encaps_value" "$vpi" "$vci" > /etc/ppp/peers/dial-provider
	else
		insert_modules "pppoe"
		user=$($CONFIG get wan_pppoe_username)
		passwd=$($CONFIG get wan_pppoe_passwd)
		mtu=$($CONFIG get wan_pppoe_mtu)
		[ "$($CONFIG get wan_pppoe_dns_assign)" != "1" ] && dns="usepeerdns"
		if [ "x$wan_endis_dod" = "x1" ]; then
			if [ "$($CONFIG get wan_pppoe_idletime)" = "0" ]; then
				idle="persist"
			else
				idle="idle $($CONFIG get wan_pppoe_idletime)"
				demand="demand"
			fi
		elif [ "x$wan_endis_dod" = "x2" ]; then
			[ "x$1" != "xmanually" -a "x$($CONFIG get run_test)" != "xtest" ] && exit 0
			idle="runone"
		else
			idle="persist"
		fi
		[ "x$($CONFIG get wan_pppoe_service)" != "x" ] && service="rp_pppoe_service $($CONFIG get wan_pppoe_service)"
		FW_REGION_FILE="/tmp/firmware_region"
		firmware_region=$(cat $FW_REGION_FILE)
		if [ "$($CONFIG get wan_pppoe_wan_assign)" = "1" ]; then
			if [ "x$($CONFIG get GUI_Region)" = "xRussian" -o "$firmware_region" = "RU" ]; then
				netmask=$($CONFIG get wan_pppoe_eth_mask)
				if [ "x$netmask" = "x" -o "x$netmask" = "x0.0.0.0" -o "x$netmask" = "x255.255.255.255" ]; then
					ip="$($CONFIG get wan_pppoe_ip):"
				fi
			else
				ip="$($CONFIG get wan_pppoe_ip):"
			fi
		fi


		local ipv6_wantype=`config get ipv6_type`

		if [ "x$pppoe_type" = "x1" -a "x$ipv6_wantype" = "xpppoe" ] ;then
			print_pppoe_options_v6 "$user" "$dns" "${mtu:-1492}" "$idle" "$demand" "$service" "$ip" "$wan_if" > $DIAL_PRVD_FILE
		else
			print_pppoe_options "$user" "$dns" "${mtu:-1492}" "$idle" "$demand" "$service" "$ip" "$wan_if" > $DIAL_PRVD_FILE
		fi


		sed -i '/user/ s/\\/\\\\/g' $DIAL_PRVD_FILE
		sed -i '/user/ s/\#/\\#/g' $DIAL_PRVD_FILE

		sed -i '/rp_pppoe_service/ s/\\/\\\\/g' $DIAL_PRVD_FILE
		sed -i '/rp_pppoe_service/ s/\#/\\#/g' $DIAL_PRVD_FILE

		append_rp_pppoe_options >> $DIAL_PRVD_FILE
	fi

	append_general_options "$wan_if" >> $DIAL_PRVD_FILE

	local PPP_CHAPS="/etc/ppp/chap-secrets"
	local PPP_PAPS="/etc/ppp/pap-secrets"
	local IPV6_PPPS="/etc/ppp/ipv6-secrets"
	local IPV4_PPPS="/etc/ppp/ipv4-secrets"

	user=$(echo ${user} | sed 's/\\/\\\\/g' | sed 's/\#/\\#/g' | sed 's/"/\\"/g')
	passwd=$(echo ${passwd} | sed 's/\\/\\\\/g' | sed 's/\#/\\#/g' | sed 's/"/\\"/g')
	echo "${user} * \"${passwd}\"" > $IPV4_PPPS

	#combination ipv4 and ipv6 ppp secrets file
	cat $IPV4_PPPS > $PPP_CHAPS
	cat $IPV4_PPPS > $PPP_PAPS
	if [ -f $IPV6_PPPS ]; then
		cat $IPV6_PPPS >> $PPP_CHAPS
		cat $IPV6_PPPS >> $PPP_PAPS
	fi

	if [ "$proto" = "pptp" -a "$($CONFIG get wan_pptp_wan_assign)" = "0" ]; then
		echo "Start PPTP by DHCP module"
	else
		pppd call $DIAL_PRVD updetach
	fi
}

