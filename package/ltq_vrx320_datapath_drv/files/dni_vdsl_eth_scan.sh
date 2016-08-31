#!/bin/sh
# Script to control lantiq ADSL and VDSL
# Copyright(c) DNI 2015


LOCK_FILE="/tmp/.dni_vdsl_eth_scan.lock"
CONFIG="/bin/config"
LOG="/tmp/dslLog.txt"
cat $LOG >> /tmp/wizard_log

OPTIONS=`for opt in $(grep '^func_.*()' $0 | cut -d_ -f2- | cut -d' ' -f1); do echo $opt; done`;

datavidTmp=
dataprotoTmp=
datapriTmp=
videovidTmp=
videoprotoTmp=
videopriTmp=
phonevidTmp=
phoneprotoTmp=
wan2_activeTmp=
wan2_bridge_modeTmp=

case "$($CONFIG get i_opmode)" in
	normal|iptv|vlan) brTmp=brwan ;;
	*) brTmp=br0 ;;
esac

wanmac()
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
}

func_vdsl_country_isp_identify () {

	if [ "$check" = "1" ]; then
		country=`$CONFIG get dsl_wan_country_tmp`
		isp=`$CONFIG get dsl_wan_isp_tmp`
	else
		country=`$CONFIG get dsl_wan_country`
		isp=`$CONFIG get dsl_wan_isp`
	fi

	echo "####################VDSL Country:$country,isp:$isp" > /dev/console
	echo "####################VDSL Country:$country,isp:$isp" >> $LOG
	case "$country,$isp" in
		"Austria,A1 Telekom")
				datavidTmp=2
				dataprotoTmp="pppoe"
				datapriTmp=0
				videovidTmp=4
				videoprotoTmp="bridged"
				videopriTmp=3
				phonevidTmp=2
				phoneprotoTmp="pppoe"
				wan2_activeTmp=1
				wan2_bridge_modeTmp=1
			;;
		"Austria,Comteam.at")
				datavidTmp=2
				dataprotoTmp="pppoe"
			;;
		"Australia,TPG")
				datavidTmp=2
				dataprotoTmp="pppoe"
			;;
		"Belgium,Proximus(Belgacom)")
				datavidTmp=10
				dataprotoTmp="pppoe"
				datapriTmp=3
				videovidTmp=30
				videoprotoTmp="bridged"
				videopriTmp=3
				phonevidTmp=10
				phoneprotoTmp="pppoe"
				wan2_activeTmp=1
				wan2_bridge_modeTmp=1
			;;
		"Canada,SaskTel")
				datavidTmp=3328
				dataprotoTmp="pppoe"
			;;
		"Canada,TekSavvy")
				datavidTmp=35
				dataprotoTmp="pppoe"
			;;
		"Denmark,Telenor")
				datavidTmp=101
				dataprotoTmp="pppoe"
			;;
		"Denmark,TDC")
				datavidTmp=101
				dataprotoTmp="dhcp"
			;;
		"Finland,DNA Welho")
				datavidTmp=
				dataprotoTmp="dhcp"
			;;
		"France,Free")
				datavidTmp=836
				dataprotoTmp="dhcp"
				videovidTmp=100
				videoprotoTmp="dhcp"
				wan2_activeTmp=1
			;;
		"France,Orange")
				datavidTmp=835
				dataprotoTmp="pppoe"
				videovidTmp=838
				videoprotoTmp="bridged"
				videopriTmp=3
				wan2_activeTmp=1
				wan2_bridge_modeTmp=1
			;;
		"Germany,1&1")
				datavidTmp=7
				dataprotoTmp="pppoe"
				phonevidTmp=7
				phoneprotoTmp="pppoe"
			;;
		"Germany,Deutsche Telekom")
				datavidTmp=7
				dataprotoTmp="pppoe"
				datapriTmp=0
				videovidTmp=8
				videoprotoTmp="dhcp"
				videopriTmp=6
				phonevidTmp=7
				phoneprotoTmp="pppoe"
				wan2_activeTmp=1
			;;
		"Germany,Telefonica O2")
				datavidTmp=7
				dataprotoTmp="pppoe"
			;;
		"Germany,Netcologne")
				datavidTmp=10
				dataprotoTmp="pppoe"
			;;
		"Germany,Vodafone")
				datavidTmp=7
				dataprotoTmp="pppoe"
			;;
		"Germany,Easybell")
				datavidTmp=7
				dataprotoTmp="pppoe"
			;;
		"Ireland,Eircom")
				datavidTmp=10
				dataprotoTmp="dhcp"
			;;
		"Italy,Telecom Italia")
				datavidTmp=835
				dataprotoTmp="pppoe"
			;;
		"Italy,Fastweb")
				datavidTmp=1
				dataprotoTmp="dhcp"
			;;
		"Singapore,SingTel")
				datavidTmp=10
				dataprotoTmp="dhcp"
				datapriTmp=0
			;;
		"Spain,Jazztel")
				datavidTmp=1079
				dataprotoTmp="pppoe"
			;;
		"Spain,Movistar")
				datavidTmp=6
				dataprotoTmp="pppoe"
				datapriTmp=1
				videovidTmp=2
				videoprotoTmp="static"
				videopriTmp=4
				wan2_activeTmp=1
			;;
		"Sweden,Telia")
				datavidTmp=835
				dataprotoTmp="dhcp"
				datapriTmp=0
				videovidTmp=845
				videoprotoTmp="bridged"
				videopriTmp=3
				wan2_activeTmp=1
				wan2_bridge_modeTmp=1
			;;
		"Switzerland,Sunrise")
				datavidTmp=
				dataprotoTmp="dhcp"
			;;
		"Switzerland,Swisscom")
				datavidTmp=10
				dataprotoTmp="dhcp"
				videovidTmp=
				videoprotoTmp="dhcp"
			;;
		"Switzerland,Telfort")
				datavidTmp=34
				dataprotoTmp="dhcp"
				phonevidTmp=34
				phoneprotoTmp="dhcp"
			;;
		"Netherlands,Telfort")
				datavidTmp=34
				dataprotoTmp="dhcp"
				phonevidTmp=34
				phoneprotoTmp="dhcp"
			;;
		"Netherlands,Tele2")
				datavidTmp=4
				dataprotoTmp="pppoe"
			;;
		"UK,BT")
				datavidTmp=101
				dataprotoTmp="pppoe"
				videovidTmp=101
				videoprotoTmp="dhcp"
				wan2_activeTmp=1
			;;
		"UK,PlusNet")
				datavidTmp=101
				dataprotoTmp="pppoe"
				videovidTmp=101
				videoprotoTmp="dhcp"
				wan2_activeTmp=1
			;;
		"UK,Sky")
				datavidTmp=101
				dataprotoTmp="dhcp"
			;;
		"UK,TalkTalk")
				datavidTmp=101
				dataprotoTmp="dhcp"
				datapriTmp=2
			#	videovidTmp=101
			#	videoprotoTmp="bridged"
			#	videopriTmp=2
			#	wan2_activeTmp=1
			#	wan2_bridge_modeTmp=1
			;;
		"UK,EE(Orange)")
				datavidTmp=101
				dataprotoTmp="pppoe"
			;;
		"UK,ZEN Internet")
			datavidTmp=101
			dataprotoTmp="pppoe"
			;;
		"UK,Vodafone")
			datavidTmp=101
			dataprotoTmp="pppoe"
			;;
		"USA,CenturyLink")
				datavidTmp=201
				dataprotoTmp="pppoe"
			;;
		*)
			if [ "$country" = "New_Zealand" ]; then
				datavidTmp=10
				dataprotoTmp="pppoe"
			else
				#GUI need these files
				[ -f /tmp/internet_setup_dsl_wan_data_vid ] && rm /tmp/internet_setup_dsl_wan_data_vid
				[ -f /tmp/internet_setup_wan2_active ] && rm /tmp/internet_setup_wan2_active
				[ -f /tmp/internet_setup_dsl_wan_video_vid ] && rm /tmp/internet_setup_dsl_wan_video_vid
				return 0;	#Country/ISP Not in VDSL List
			fi
	esac
	#GUI need these files
	echo $datavidTmp > /tmp/internet_setup_dsl_wan_data_vid
	echo $wan2_activeTmp > /tmp/internet_setup_wan2_active
	echo $videovidTmp > /tmp/internet_setup_dsl_wan_video_vid
	#give GUI the condition for IPTV bridge mode page display
	if [ "$isp" = "Telia" ]; then
		echo 2 > /tmp/wan2_bridge_modeTmp #dhcp on wan1, bridge for iptv
	elif [ "$isp" = "TalkTalk" ]; then
		echo 3 > /tmp/wan2_bridge_modeTmp #dhcp on wan1, igmp for iptv
	else
		echo $wan2_bridge_modeTmp > /tmp/wan2_bridge_modeTmp #pppoe on wan1, bridge for iptv
	fi

	return 1;	#Country/ISP in VDSL List
}

del_brwan_wan_vifs()
{
	local nif
	for nif in `brctl show $1 | awk '!/bridge/ {print $NF}' | grep "ptm\|nas\|ethwan"` ; do
		brctl delif $1 $nif
	done

	#delete vlan brs
	local brx vlan_brs=`awk '/br[1-9]|brwan2/ {print $1}' /proc/net/dev |sed 's/://g'` #brwan2 is for WAN2 that have no vlan id
	for brx in $vlan_brs; do
		ifconfig $brx down
		for nif in `brctl show $brx | awk '!/bridge/ {print $NF}' | grep "ptm\|nas\|eth"`; do
			brctl delif $brx $nif
			vconfig rem $nif
		done
		brctl delbr $brx
	done
}

func_check_in_vdsl_list () {
	while [ -f $LOCK_FILE ]; do
		sleep 1
	done

	touch $LOCK_FILE
	func_vdsl_country_isp_identify
	echo $? > /tmp/quick_scan_result
	rm $LOCK_FILE
}

func_vdsl_quick_scan () {
	while [ -f $LOCK_FILE ]; do
		sleep 1
	done
	
	touch $LOCK_FILE
	echo "############################VDSL I am in QuickScan process...." > /dev/console
	echo "############################VDSL I am in QuickScan process...." >> $LOG
	
	func_vdsl_country_isp_identify
	local country=$($CONFIG get dsl_wan_country)
	local isp=$($CONFIG get dsl_wan_isp)

	/etc/init.d/opmode reset_wan_dsl_or_eth

	local loop_time=0
	local loop_num=3
	while [ $loop_time -lt $loop_num ]
	do
		del_brwan_wan_vifs $brTmp

		dsl_wan_preference=`$CONFIG get dsl_wan_preference`
		if [ "X$dsl_wan_preference" = "X1" ]; then	#WAN-setup page: Must use DSL
			vdsl_wan_ifname=`$CONFIG get vdsl_wan_ifname`
			ifconfig $vdsl_wan_ifname hw ether $(wanmac) up
			if [ "x$datavidTmp" = "x" ]; then
				iface=$vdsl_wan_ifname
			else
				vconfig add $vdsl_wan_ifname $datavidTmp 2>/dev/null && sleep 1;
				ifconfig $vdsl_wan_ifname.$datavidTmp up && {
					iface=$vdsl_wan_ifname.$datavidTmp
				} || {
					vconfig rem $iface
					echo "############################VDSL Error: Unable to create a vlan interface on $vdsl_wan_ifname." > /dev/console
					echo "############################VDSL Error: Unable to create a vlan interface on $vdsl_wan_ifname." >> $LOG
					rm $LOCK_FILE && exit 64
				}
			fi
		elif [ "X$dsl_wan_preference" = "X2" ]; then	#WAN-setup page: Must use Ethernet
			ifconfig ethwan down
			vconfig rem ethwan && ifconfig eth0 down || ip link set dev ethwan name eth0
			wan_ifname=eth0
			if [ "x$datavidTmp" = "x" ]; then
				ip link set dev $wan_ifname name ethwan
			else
				ifconfig $wan_ifname up
				vconfig add $wan_ifname $datavidTmp 2>/dev/null && sleep 1;
				ifconfig $wan_ifname.$datavidTmp down
				ip link set dev $wan_ifname.$datavidTmp name ethwan
			fi
			ifconfig ethwan up && {
				iface=ethwan
			} || {
				vconfig rem ethwan
				echo "############################VDSL Error: Unable to create a vlan interface on $wan_ifname." > /dev/console
				echo "############################VDSL Error: Unable to create a vlan interface on $wan_ifname." >> $LOG
				rm $LOCK_FILE && exit 64
			}
		fi

		brctl addif $brTmp $iface
		[ "x$brTmp" = "xbrwan" ] && ifconfig $brTmp hw ether $(wanmac) up

		#tcpdump 
		tcpdump -i $iface -w /tmp/detwan.pcap &
		tcpdump_pid=`ps | grep "tcpdump -i $iface -w /tmp/detwan.pcap" | grep -v "grep" | awk '{print $1}'`

		wan_mac=`/sbin/ifconfig $brTmp 2>/dev/null|awk '/HWaddr/ { print $5 }'`
		echo "############################VDSL QuickScan: iface:$iface, wan_mac:$wan_mac." > /dev/console
		echo "############################VDSL QuickScan: iface:$iface, wan_mac:$wan_mac." >> $LOG
		/usr/sbin/detwan -p $remote_addr -i $brTmp -d $wan_mac -n $pc_mac > /dev/console
		protoResult=$?

		kill $tcpdump_pid

		brctl delif $brTmp $iface
		vconfig rem $iface
		if [ "$dataprotoTmp" = "pppoe" ] && [ "$(($protoResult%2))" = "1" ]; then
			$CONFIG set dsl_wan_data_vid=$datavidTmp
			$CONFIG set dsl_wan_data_proto=$dataprotoTmp
			$CONFIG set dsl_wan_video_vid=$videovidTmp
			$CONFIG set dsl_wan_video_proto=$videoprotoTmp
			$CONFIG set dsl_wan_phone_vid=$phonevidTmp
			$CONFIG set dsl_wan_phone_proto=$phoneprotoTmp
			$CONFIG set wan2_active=$wan2_activeTmp
			$CONFIG set dsl_wan_enablewan=1
			if [ "x$datavidTmp" != "x" ]; then
				$CONFIG set dsl_wan_enable_vlanidActive=1
				$CONFIG set dsl_wan_priority=$datapriTmp
			else
				$CONFIG set dsl_wan_enable_vlanidActive=
				$CONFIG set dsl_wan_priority=
			fi
			if [ "x$videovidTmp" != "x" ]; then
				$CONFIG set dsl_wan2_enable_vlanidActive=1
				$CONFIG set dsl_wan2_priority=$videopriTmp
			else
				$CONFIG set dsl_wan2_enable_vlanidActive=
				$CONFIG set dsl_wan2_priority=
			fi
			$CONFIG set dsl_wan2_enablewan=$wan2_activeTmp
			$CONFIG set dsl_wan2_bridge_mode=$wan2_bridge_modeTmp
			$CONFIG commit
			echo "############################VDSL QuickScan success, proto:pppoe." > /dev/console
			echo "############################VDSL QuickScan success, proto:pppoe." >> $LOG
			rm $LOCK_FILE && exit 128
		fi
		if [ "$dataprotoTmp" = "dhcp" ] && [ "$(($protoResult/2%2))" = "1" ]; then
			$CONFIG set dsl_wan_data_vid=$datavidTmp
			$CONFIG set dsl_wan_data_proto=$dataprotoTmp
			$CONFIG set dsl_wan_video_vid=$videovidTmp
			$CONFIG set dsl_wan_video_proto=$videoprotoTmp
			$CONFIG set dsl_wan_phone_vid=$phonevidTmp
			$CONFIG set dsl_wan_phone_proto=$phoneprotoTmp
			$CONFIG set wan2_active=$wan2_activeTmp
			$CONFIG set dsl_wan_enablewan=1
			if [ "x$datavidTmp" != "x" ]; then
				$CONFIG set dsl_wan_enable_vlanidActive=1
				$CONFIG set dsl_wan_priority=$datapriTmp
			else
				$CONFIG set dsl_wan_enable_vlanidActive=
				$CONFIG set dsl_wan_priority=
			fi
			if [ "x$videovidTmp" != "x" ]; then
				$CONFIG set dsl_wan2_enable_vlanidActive=1
				$CONFIG set dsl_wan2_priority=$videopriTmp
			else
				$CONFIG set dsl_wan2_enable_vlanidActive=
				$CONFIG set dsl_wan2_priority=
			fi
			$CONFIG set dsl_wan2_enablewan=$wan2_activeTmp
			$CONFIG set dsl_wan2_bridge_mode=$wan2_bridge_modeTmp
			$CONFIG commit
			echo "############################VDSL QuickScan success, proto:dhcp." > /dev/console
			echo "############################VDSL QuickScan success, proto:dhcp." >> $LOG
			rm $LOCK_FILE && exit 2
		fi
		echo "############################VDSL QuickScan fail...protoResult:$protoResult" > /dev/console
		echo "############################VDSL QuickScan fail...protoResult:$protoResult" >> $LOG
		loop_time=$(($loop_time+1))
	done
	rm $LOCK_FILE && exit 64
}

func_vdsl_full_scan () {

	while [ -f $LOCK_FILE ]; do
		sleep 1
	done
	touch $LOCK_FILE
		
	local country isp
	$CONFIG set dsl_wan_data_vid=
	$CONFIG set dsl_wan_data_proto=
	$CONFIG set dsl_wan_video_vid=
	$CONFIG set dsl_wan_video_proto=
	$CONFIG set dsl_wan_phone_vid=
	$CONFIG set dsl_wan_phone_proto=
	$CONFIG set wan2_active=0
	$CONFIG set dsl_wan2_enablewan=
	$CONFIG set dsl_wan_enable_vlanidActive=
	$CONFIG set dsl_wan2_enable_vlanidActive=
	$CONFIG set dsl_wan_priority=0
	$CONFIG set dsl_wan2_priority=0
	$CONFIG set dsl_wan2_bridge_mode=

	country=$($CONFIG get dsl_wan_country)
	isp=$($CONFIG get dsl_wan_isp)
	[ "$country" = "Switzerland" -a "$isp" = "Swisscom All IP(with phone)" ] && {
		$CONFIG set dsl_wan_ether_dhcp_option60="100008,0001,,NETGEAR D7800"
		$CONFIG set wan_endis_igmp=1
	}

	[ "$country" = "Switzerland" -a "$isp" = "Swisscom" ] && $CONFIG set wan_endis_igmp=1

	$CONFIG commit

	echo "############################VDSL i am in FullScan process..." > /dev/console
	echo "############################VDSL i am in FullScan process..." >> $LOG

	/etc/init.d/opmode reset_wan_dsl_or_eth
	
	local loop_time=0

	while [ $loop_time -lt 3 ]
	do
		del_brwan_wan_vifs $brTmp

		dsl_wan_preference=`$CONFIG get dsl_wan_preference`
		if [ "X$dsl_wan_preference" = "X1" ]; then  #WAN-setup page: Must use DSL
			iface=`$CONFIG get vdsl_wan_ifname`
			ifconfig $iface hw ether $(wanmac) up
		elif [ "X$dsl_wan_preference" = "X2" ]; then	#WAN-setup page: Must use Ethernet
			ifconfig ethwan down
			vconfig rem ethwan || ip link set dev ethwan name eth0
			ifconfig eth0 down
			ip link set dev eth0 name ethwan
			ifconfig ethwan up
			iface=ethwan
		fi

		brctl addif $brTmp $iface
		[ "x$brTmp" = "xbrwan" ] && ifconfig $brTmp hw ether $(wanmac) up
		wan_mac=`/sbin/ifconfig $brTmp 2>/dev/null|awk '/HWaddr/ { print $5 }'`
		echo "############################VDSL iface:$iface,wan_mac:$wan_mac...." > /dev/console
		echo "############################VDSL iface:$iface,wan_mac:$wan_mac...." >> $LOG

		#tcpdump
		tcpdump -i $iface -w /tmp/detwan.pcap &
		tcpdump_pid=`ps | grep "tcpdump -i $iface -w /tmp/detwan.pcap" | grep -v "grep" | awk '{print $1}'`

		/usr/sbin/detwan -p $remote_addr -i $brTmp -d $wan_mac -n $pc_mac
		protoResult=$?

		kill $tcpdump_pid

		brctl delif $brTmp $iface
		echo "############################VDSL FullScan success, proto:$protoResult..." > /dev/console
		echo "############################VDSL FullScan success, proto:$protoResult..." >> $LOG
		[ $protoResult != "0" ] && {
			$CONFIG set dsl_wan_enablewan=1
			rm $LOCK_FILE
			exit $protoResult
		}
		loop_time=$(($loop_time+1))
	done

	rm $LOCK_FILE
	kill $tcpdump_pid
	exit $protoResult
}

for opt in $OPTIONS; do
	if [ -n "$1" ] && [ "$1" = "$opt" ]; then
		shift
		eval $@
		func_$opt

		exit 0;
	fi
done

echo "Error: dni_vdsl_eth_scan.sh not option $opt." > /dev/console
