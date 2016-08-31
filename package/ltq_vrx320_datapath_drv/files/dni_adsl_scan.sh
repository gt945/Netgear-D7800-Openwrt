#!/bin/sh

#dsl log saving
LOG="/tmp/dslLog.txt"
cat $LOG >> /tmp/wizard_log

CONFIG=/bin/config
wan_ifname=brwan
iface=nas0
LOCK_FILE="/tmp/.dni_adsl_scan.lock"
# Quick/Full Scan exit status
QS_Y=10
QS_N=11
FS_Y=20
FS_N=21

# TRUE/FALSE
TRUE=0
FALSE=1


# Country, ISP database
# Principle
# Country_num=ISP1@ISP2*Proto*VPI*VCI*ENCAP
Australia_1="pppoa*8*35*vc*Soul,People Telcom,Adam,Telstra,Internode,Spintel,Onthenet,Westnet"
Australia_2="pppoe*8*35*llc*Optus,Primus,TPG,iiNet,Dodo,Telstra Bigpond,TransACT,Internode,Engin"
Australia_3="pppoe*8*35*vc"
Australia_4="pppoa*8*35*llc*Clubtelco"
Australia_5="pppoe*8*35*llc*TPG"	#same with Australia_2, this will add vlanid detect
Australia_6="pppoe*8*35*vc*Exetel"
Australia_7="pppoa*8*35*vc*Exetel"

Austria_1="pppoe*9*35*llc*UPC Austria"
Austria_2="pppoe*0*32*llc*UTA2"
Austria_3="pppoa*8*48*llc"
Austria_4="pppoa*8*48*vc*A1 Telekom"
Austria_5="pppoa*9*35*llc*A1 Telekom"

Belgium_1="pppoe*8*35*llc*Proximus(Belgacom),Base"

Brazil_1="pppoe*0*35*llc*Gvt-Global Village Telecom"
Brazil_2="pppoe*0*33*llc*Telemar Oi Velox"
Brazil_3="pppoe*1*32*llc*Oi"

Canada_1="pppoe*0*32*llc*Bell Canada(Western)"
Canada_2="dhcp*0*33*llc*Telus Communications"

China_1="pppoe*8*35*llc*China Telecom,China Unicom"
China_2="pppoe*0*35*llc"
China_3="pppoe*8*32*llc"
China_4="pppoe*0*100*llc"
China_5="pppoe*0*32*llc"
China_6="pppoe*8*81*llc"

Czech_Republic_1="pppoe*8*48*llc*O2,Tiscali,T-Mobile"

Denmark_1="pppoa*0*35*vc*Telenor,TDC"

Finland_1="pppoa*0*33*llc*Teliasonera"
Finland_2="pppoe*0*100*llc*Elisa Oyj"
Finland_3="pppoe*0*33*llc"

France_1="pppoe*8*35*llc*SFR,Orange,Bouygues Telecom"
France_2="pppoa*8*35*vc*OVH"
France_3="ipoa*8*36*vc*Free"
France_4="pppoa*0*35*vc"
France_5="pppoa*8*35*llc*Nordnet,Orange"
France_6="pppoe*8*35*vc*OVH"
France_7="dhcp*8*36*llc"
France_8="dhcp*8*36*vc"
France_9="ipoa*8*35*vc*Elisa Oyj"

Germany_1="pppoe*1*32*llc*1&1,Deutsche Telekom,Telefonica O2,Easybell,m-net,Vodafone,Versatel"
Germany_2="pppoe*8*35*llc*Netcologne"
Germany_3="pppoe*1*32*llc*Deutsche Telekom"	#same with Germany_1, this will add vlanid detect

HongKong_1="pppoe*1*32*llc*PCCW"

Hungary_1="pppoe*1*32*llc*Actel,GTS Datanet,Invitel,T-Home"

India_1="pppoe*0*33*llc*TataIndicom"
India_2="pppoe*1*33*llc*TataIndicom"
India_3="pppoe*0*35*llc*BSNL,Inedit"
India_4="pppoe*1*32*llc*AIRTEL"
India_5="pppoe*0*32*llc*MTNL"

Indonesia_1="pppoe*0*35*llc*Telkom Speedy"
Indonesia_2="pppoa*0*35*llc"
Indonesia_3="pppoa*1*33*llc"
Indonesia_4="pppoa*8*35*llc"
Indonesia_5="pppoe*8*81*llc*Speedy"

Italy_1="pppoe*8*35*llc*Telecom Italia,Wind(Infostrada),AscoTLC,Intred,Teletu"
Italy_2="pppoa*8*35*vc*Aruba,Tiscali,Wind(Infostrada),Twt,Acantho,Siportal"
Italy_3="dhcp*8*36*llc*Fastweb"
Italy_4="pppoe*8*35*vc*Wind(Infostrada),Telecom Italia"
Italy_5="pppoa*0*38*vc*Tiscali"
Italy_6="pppoe*8*36*llc*TELE2"
Italy_7="ipoa*8*35*llc*KPN Qwest Italia,Telecom Italia"
Italy_8="pppoa*8*75*vc*MC-link"

Malaysia_1="pppoe*0*35*llc*Streamyx"

Netherlands_1="pppoe*0*34*llc*Vodafonevast,Telfort"
Netherlands_2="dhcp*0*34*llc*Telfort"
Netherlands_3="dhcp*8*35*llc*Online-nl"
Netherlands_4="pppoe*8*35*llc"
Netherlands_5="pppoa*8*48*vc"
Netherlands_6="pppoa*2*32*vc"

New_Zealand_1="pppoa*0*100*vc*IHug,Kiwi Online(KOL),Orcon,Paradise,Slingshot,Spark,Telstra Clear,Xnet(World Exchange),Bigpipe,Vodafone,Trust power,WXC,Snap"
New_Zealand_2="dhcp*8*35*llc*ICONZ-Webvisions"
New_Zealand_3="pppoe*0*100*llc"
New_Zealand_4="pppoa*0*100*llc"
New_Zealand_5="pppoa*1*100*vc*ICONZ-Webvisions"

Other_1="pppoa*0*38*vc"
Other_2="pppoe*0*35*llc"
Other_3="dhcp*0*44*llc"
Other_4="dhcp*0*44*vc"
Other_5="pppoe*8*32*llc"
Other_6="dhcp*0*35*llc"
Other_7="pppoa*8*48*llc"
Other_8="pppoe*0*35*llc"
Other_9="pppoe*0*100*llc"
Other_10="pppoe*0*32*llc"
Other_11="pppoe*8*81*llc"

Philippine_1="pppoe*0*100*llc*PLDT,TelPlus"
Philippine_2="pppoe*0*35*llc"

Poland_1="pppoe*0*35*llc*Multimo,Tele2,TP SA"
Poland_2="pppoa*0*35*vc*Netia,Orange"
Poland_3="pppoa*0*35*llc"
Poland_4="pppoe*8*35*llc*Netia"

Portugal_1="pppoe*0*35*vc*PT"
Portugal_2="pppoe*0*35*llc*Vodafone,Zon"

Russia_1="pppoa*8*63*vc*Combellga"
Russia_2="pppoe*0*33*llc*Beltelecom"
Russia_3="pppoe*0*35*llc*Domolink CentrTelekom,Avangard-DSL"
Russia_4="pppoe*1*50*llc*MTS Stream,MGTS"
Russia_5="pppoe*1*100*llc*Jdsl Volgatelekom"
Russia_6="pppoe*1*32*llc"
Russia_7="pppoe*2*32*llc"
Russia_8="pppoe*9*148*llc"
Russia_9="pppoe*10*40*llc"
Russia_10="pppoe*9*161*llc"
Russia_11="pppoe*8*35*llc*Rostelecom"

Saudi_Arabia_1="pppoe*0*35*llc*STC"

Singapore_1="pppoe*0*100*llc*PacificNet,Singnet"
Singapore_2="pppoa*0*100*vc"
Singapore_3="pppoe*0*100*vc"

Spain_1="pppoe*8*32*llc*Telefonica Movistar(dynamic IP),Orange"
Spain_2="pppoe*8*35*llc*Jazztel"
Spain_3="pppoa*0*33*vc*Vodafone,Pepephone"
Spain_4="dhcp*8*32*llc*Orange"
Spain_5="pppoa*8*35*vc*Orange"
Spain_6="pppoe*6*36*llc*Orange"
Spain_7="ipoa*8*32*llc*Telefonica Movistar(fixed IP)"
Spain_8="pppoa*8*35*llc"
Spain_9="pppoa*6*35*vc"

Sweden_1="pppoe*8*35*llc*Telia,Ljusne,Bahnhof AB,Bredbandsbolaget"
Sweden_2="pppoa*8*35*llc"
Sweden_3="dhcp*8*35*llc*Telia"

Switzerland_1="pppoe*8*35*llc*Sunrise,Monzoon Networksi,Swisscom,Telfort"
Switzerland_2="dhcp*8*35*llc*Swisscom,Telfort"
Switzerland_3="pppoa*0*34*llc"
Switzerland_4="pppoe*8*35*vc"

Thailand_1="pppoe*0*33*llc*TT&T,3BB"
Thailand_2="pppoe*0*35*llc*CAT-Telecom,CS-Loxinfo,Samart"
Thailand_3="pppoe*0*100*llc*TRUE Internet"
Thailand_4="pppoe*1*32*llc*TOT"

Turkey_1="pppoa*8*35*vc"
Turkey_2="pppoa*8*35*llc"
Turkey_3="pppoe*8*35*vc"
Turkey_4="pppoe*8*35*llc"

UK_1="pppoa*0*38*vc*BT,Sky,TalkTalk,PlusNet,Virgin Media,Zen Internet,EE(Orange)"
UK_2="pppoe*0*38*llc*BT,Sky,TalkTalk,PlusNet,Virgin Media"
UK_3="pppoa*0*38*llc*BT,Sky,TalkTalk,PlusNet,Virgin Media"
UK_4="pppoe*8*35*llc*EE(Orange)"
UK_5="pppoe*8*36*vc"
UK_6="pppoe*0*101*llc"
UK_7="dhcp*0*101*llc"
UK_8="ipoa*0*101*llc"
UK_9="dhcp*0*40*vc*Sky"

USA_1="pppoe*0*35*llc*AT&T,Earthlink,Verizon,Windstream"
USA_2="pppoa*0*35*llc*Frontier Communications,Rivercity Internet Group"
USA_3="pppoe*8*35*llc*CenturyLink,AT&T,Bigriver.net DSL"
USA_4="pppoe*0*32*llc*Qwest,CenturyLink"
USA_5="pppoa*0*32*vc*Qwest"
USA_6="pppoa*0*32*llc"
USA_7="pppoe*0*38*llc"
USA_8="pppoe*0*38*vc"
USA_9="pppoe*0*32*vc"
USA_10="dhcp*0*33*llc"
USA_11="pppoa*0*100*llc"
USA_12="pppoe*1*34*llc"
USA_13="pppoa*8*35*llc"
USA_14="dhcp*0*35*llc*BEVCOMM,Verizon,Windstream"
USA_15="dhcp*8*129*vc*cox communications"
USA_16="pppoe*0*35*llc*Fairpoint Communications,sonic.net"

Vietnam_1="pppoe*0*33*llc*FPT,NATNAM,SPT"
Vietnam_2="pppoe*0*35*llc*VNN(in Hanoi)"
Vietnam_3="pppoe*8*35*llc*Viettel"
Vietnam_4="pppoe*8*38*llc*VNN(in HAM)"

OPTIONS=`for opt in $(grep '^func_.*()' $0 | cut -d_ -f2- | cut -d' ' -f1); do echo $opt; done`;

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
	pppoa)
		[ "$($CONFIG get wan_pppoa_mac_assign)" = "1" ] && assigned=1
		[ "$($CONFIG get wan_pppoa_mac_assign)" = "2" ] && { assigned=2; use_this_mac_addr=$($CONFIG get wan_pppoa_this_mac); }
		;;
	ipoa)
		[ "$($CONFIG get wan_ipoa_mac_assign)" = "1" ] && assigned=1
		[ "$($CONFIG get wan_ipoa_mac_assign)" = "2" ] && { assigned=2; use_this_mac_addr=$($CONFIG get wan_ipoa_this_mac); }
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

	# Use br2684ctl to create nas interface
	del_nas $1
	br2684ctl -b -p 1 -c $1 -e $mp -q UBR,aal5:max_pcr=0,min_pcr=0 -a $3.$4 -s 65536
	usleep 100000
	ifconfig nas$1 hw ether $(wanmac) up
}

# $1: interface index
del_nas()
{
	ifconfig nas$1 down
	usleep 100000
	killall -9 br2684ctl
	kill -9 `cat /var/run/br2684ctl-nas$1.pid`
	rm -rf /var/run/br2684ctl-nas$1.pid
	usleep 50000
}

pvc_set()
{
	create_nas 0 $encap $vpi $vci

	return $TRUE
}


pvc_detect()
{
	create_nas 0 $encap $vpi $vci
	if [ "$vpi" = "0" ] || [ "$vpi" = "1" ] || [ "$vpi" = "8" ]; then
		export OAM_PING_USLEEP=900000
		[ "x`ps | grep oamd | grep -v grep`" = "x" ] && /usr/bin/oamd &
		oamctl --f5 --vpi $vpi --vci $vci --scope 0 --loopback 400 --num-of-pings 2
	else
		export OAM_PING_USLEEP=250000
		[ "x`ps | grep oamd | grep -v grep`" = "x" ] && /usr/bin/oamd &
		oamctl --f5 --vpi $vpi --vci $vci --scope 0 --loopback 150 --num-of-pings 1
	fi

	#### Check here
	[ $? -eq 0 ] && return $TRUE || return $FALSE
}

pppoa_detect()
{
	# PPPoA detection
	local i=0
	local ipv4_pppd
	
	del_nas 0

	ipv4_pppd=`ps | grep "pppd call dial-provider updetach" | grep -v "grep" |awk '{print $1}'`
	if [ "x$ipv4_pppd" != "x" ]; then
		kill -1 $ipv4_pppd
		sleep 2
		kill -9 $ipv4_pppd
		sleep 2
	fi

	if [ "x$encap" == "xvc" ]; then
		create_nas 10 "vc" 0 1000
	fi

	rm /tmp/ppp_exist -rf

	pppd user root password root maxfail 1 plugin /usr/lib/pppd/2.4.3/pppoatm.so $encap-encaps 0.$vpi.$vci persist unit 0 do_detect

	while [ $i -lt 5 ]
	do
		[ -f /tmp/ppp_exist ] && break
		sleep 2
		i=$(( $i+1 ))
	done

	ipv4_pppd=`ps | grep "pppd user root password root" | grep -v "grep" |awk '{print $1}'`
	if [ "x$ipv4_pppd" != "x" ]; then
		kill -1 $ipv4_pppd
		sleep 2
		kill -9 $ipv4_pppd
		sleep 2
	fi

	[ "x$encap" == "xvc" ] && del_nas 10
	
	[ ! -f /tmp/ppp_exist ] && return $FALSE
	[ "x`cat /tmp/ppp_exist`" == "x1" ] && return $TRUE || return $FALSE 

}

get_adsl_vid()
{
	local country=$($CONFIG get dsl_wan_country)
	local isp=$($CONFIG get dsl_wan_isp)
	if [ "$country" = "France" -a "$isp" = "SFR" -a "$1" = "1" ]; then
		videoprotoTmp="dhcp"
		wan2_activeTmp=1
	elif [ "$country" = "Germany" -a "$isp" = "Deutsche Telekom" -a "$1" = "1" ]; then #
		datavidTmp=7
		datapriTmp=0
		videovidTmp=8
		videoprotoTmp="dhcp"
		videopriTmp=6
		wan2_activeTmp=1
#	elif [ "$country" = "Australia" -a "$isp" = "TPG" -a "$1" = "5" ]; then
#		datavidTmp=
#		videoprotoTmp="dhcp"
#		wan2_activeTmp=1
	fi
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

wan_detect_quick_scan()
{
	local loop_time=0
	while [ $loop_time -lt 1 ]
	do
		case "$proto" in
			pppoa)
				pppoa_detect && { protoResult=129; proto=pppoa; return $TRUE; }
				;;
			ipoa)
				# do nothing, only after quick scan fail, use ipoa proto to connect
			#	proto=ipoa; protoResult=130; return $TRUE
				;;
			*)
				# For non-pppoa
				create_nas 0 $encap $vpi $vci
				del_brwan_wan_vifs $wan_ifname
				
				datavidTmp=
				datapriTmp=
				videovidTmp=
				videoprotoTmp=
				videopriTmp=
				wan2_activeTmp=
				wan2_bridge_modeTmp=

				get_adsl_vid $1
			
				if [ "x$datavidTmp" = "x" ]; then
					realname=$iface
				else
					vconfig add $iface $datavidTmp 2>/dev/null && sleep 1;
					ifconfig $iface.$datavidTmp up && {
						realname=$iface.$datavidTmp
					} || {
						vconfig rem $realname
						del_nas 0
						rm $LOCK_FILE && exit 64
					}
				fi
				brctl addif $wan_ifname $realname
				ifconfig $wan_ifname hw ether $(wanmac) up
				wan_mac=`/sbin/ifconfig $wan_ifname 2>/dev/null|awk '/HWaddr/ { print $5 }'`
				echo "############################ADSL iface:$wan_ifname, wan_mac:$wan_mac, remote_addr:$remote_addr, pc_mac:$pc_mac" > /dev/console
				echo "############################ADSL iface:$wan_ifname, wan_mac:$wan_mac, remote_addr:$remote_addr, pc_mac:$pc_mac" >> $LOG

				#tcpdump
				tcpdump -i $iface -w /tmp/detwan.pcap &
				tcpdump_pid=`ps | grep "tcpdump -i $iface -w /tmp/detwan.pcap" | grep -v "grep" | awk '{print $1}'`

				/usr/sbin/detwan -p $remote_addr -i $wan_ifname -d $wan_mac -n $pc_mac
				detwanResult=$?
				echo "############################ADSL vpi:$vpi,vci:$vci quick scan detect result:$detwanResult" > /dev/console
				echo "############################ADSL vpi:$vpi,vci:$vci quick scan detect result:$detwanResult" >> $LOG
				
				brctl delif $wan_ifname $realname
				del_nas 0

				kill $tcpdump_pid

				[ "$(($detwanResult/2%2))" = "1" -a "$proto" = "dhcp" ] && { protoResult=2; proto=dhcp; return $TRUE; }  #DHCP
				[ "$(($detwanResult%2))" = "1" -a "$proto" = "pppoe" ] && { protoResult=128; proto=pppoe; return $TRUE; }	#PPPoE
				;;
				
		esac
		loop_time=$(($loop_time+1))
	done
	
	return $FALSE
}

wan_detect_full_scan()
{
	# Run detwan to detect pppoe/dhcp first
	local loop_time=0
	while [ $loop_time -lt 3 ]
	do
		create_nas 0 $encap $vpi $vci
		del_brwan_wan_vifs $wan_ifname

		brctl addif $wan_ifname $iface
		ifconfig $wan_ifname hw ether $(wanmac) up
	
		wan_mac=`/sbin/ifconfig $wan_ifname 2>/dev/null|awk '/HWaddr/ { print $5 }'`
		echo "############################ADSL iface:$wan_ifname, wan_mac:$wan_mac, remote_addr:$remote_addr, pc_mac:$pc_mac" > /dev/console
		echo "############################ADSL iface:$wan_ifname, wan_mac:$wan_mac, remote_addr:$remote_addr, pc_mac:$pc_mac" >> $LOG
		
		#tcpdump
		tcpdump -i $iface -w /tmp/detwan.pcap &
		tcpdump_pid=`ps | grep "tcpdump -i $iface -w /tmp/detwan.pcap" | grep -v "grep" | awk '{print $1}'`

		/usr/sbin/detwan -p $remote_addr -i $wan_ifname -d $wan_mac -n $pc_mac
		detwanResult=$?
		
		brctl delif $wan_ifname $iface
		del_nas 0
		kill $tcpdump_pid

		[ "$(($detwanResult/2%2))" = "1" ] && { protoResult=2; proto=dhcp; return $TRUE; }  #DHCP
		[ "$(($detwanResult%2))" = "1" ] && { protoResult=1; proto=pppoe; return $TRUE; }		#PPPoE
		echo "############################ADSL detwan failed. Run PPPoA detect now..." > /dev/console
		echo "############################ADSL detwan failed. Run PPPoA detect now..." >> $LOG
		pppoa_detect && { protoResult=129; proto=pppoa; return $TRUE; }
		echo "############################ADSL detwan and PPPoA failed. Run IPoA now..." > /dev/console
		echo "############################ADSL detwan and PPPoA failed. Run IPoA now..." >> $LOG
		
		loop_time=$(($loop_time+1))
	done

	return $FALSE
}

save_wan2_conf() #this function is for double vpi/vci setting
{
	local country=`$CONFIG get dsl_wan_country`
	local isp=`$CONFIG get dsl_wan_isp`
	local wan2_vpi wan2_vci wan2_encap
	case "$country/$isp" in
		Australia/TPG)
			vpi=0
			vci=35
			encap=llc
			wan2_activeTmp=1
			videoprotoTmp=dhcp
			;;
		UK/BT)
			vpi=0
			vci=35
			encap=vc
			wan2_activeTmp=1
			videoprotoTmp=dhcp
			;;
#		Germany/Deutsche Telekom)
#			if [ "x$videovidTmp" = "x8" ]; then
#				vpi=1
#				vci=33
#				encap=llc
#				wan2_activeTmp=1
#				videoprotoTmp=dhcp
#			fi
#			;;
		*)
			echo "WAN1 and WAN2 use the same vpi/vci/encap"
			return # no double vpi/vci require
			;;
	esac
}

save_conf()
{
	$CONFIG set wan_proto=$proto
	$CONFIG set dsl_wan_vpi=$vpi
	$CONFIG set dsl_wan_vci=$vci
	$CONFIG set dsl_wan_multiplex=$encap
	$CONFIG set dsl_wan_enablewan=1
	$CONFIG set dsl_wan_data_vid=$datavidTmp

	# enable IGMP default for Extel
	if [ "$($CONFIG get dsl_wan_country)" = "Australia" ] && [ "$($CONFIG get dsl_wan_isp)" = "Exetel" ]; then
		$CONFIG set wan_endis_igmp=1
	fi

	# for wan2 conf
	[ "X$1" = "Xquick" ] && save_wan2_conf
	$CONFIG set dsl_wan2_vpi=$vpi
	$CONFIG set dsl_wan2_vci=$vci
	$CONFIG set dsl_wan2_multiplex=$encap
	$CONFIG set dsl_wan_video_vid=$videovidTmp
	$CONFIG set dsl_wan_video_proto=$videoprotoTmp

	[ -f /tmp/internet_setup_dsl_wan_data_vid ] && rm /tmp/internet_setup_dsl_wan_data_vid
	[ -f /tmp/internet_setup_wan2_active ] && rm /tmp/internet_setup_wan2_active
	[ -f /tmp/internet_setup_dsl_wan_video_vid ] && rm /tmp/internet_setup_dsl_wan_video_vid

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
	$CONFIG set wan2_active=$wan2_activeTmp
	$CONFIG set dsl_wan2_bridge_mode=$wan2_bridge_modeTmp

	echo $datavidTmp > /tmp/internet_setup_dsl_wan_data_vid
	echo $wan2_activeTmp > /tmp/internet_setup_wan2_active
	echo $videovidTmp > /tmp/internet_setup_dsl_wan_video_vid

	if [ "X$1" = "Xfull" ]; then
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
	fi
	$CONFIG commit
}

func_adsl_quick_scan ()
{
	while [ -f $LOCK_FILE ]; do
		sleep 1
	done

	touch $LOCK_FILE

	local country isp i wan_proto num
	country=`$CONFIG get dsl_wan_country`
	isp=`$CONFIG get dsl_wan_isp`
	wan_proto=$($CONFIG get wan_proto)

	echo "############################ADSL I am in QuickScan process...." > /dev/console
	echo "############################ADSL I am in QuickScan process...." >> $LOG

	#sort country_i sequence
	ipoa_conf=
	i=1
	num=1
	while true
	do
		eval conf=\${${country}_$i}
		[ -z "$conf" ] && break
		grep_result=`echo $conf | grep "$isp"`
		[ -n "$grep_result" ] && {
			eval scan_country_isp_$num=\"$conf\"
			[ `echo $grep_result|cut -d "*" -f1` = ipoa ] && ipoa_conf=$conf
			num=$(($num+1))
		}
		i=$(($i+1))
	done

	i=1
	while true
	do
		eval conf=\${${country}_$i}
		[ -z "$conf" ] && break
		grep_result=`echo "$conf" | grep "$isp"`
		[ -z "$grep_result" ] && {
			eval scan_country_isp_$num=\"$conf\"
			num=$(($num+1))
		}
		i=$(($i+1))
	done

	eval scan_country_isp_$num=
	# Iterate this country list
	protoResult=0
	i=1
	while true
	do
		eval conf=\${scan_country_isp_$i}
		[ -z "$conf" ] && break

		echo "############################ADSL Process ADSL quick scan with conf: $conf" > /dev/console
		echo "############################ADSL Process ADSL quick scan with conf: $conf" >> $LOG
		proto=`echo $conf|cut -d "*" -f1`
		vpi=`echo $conf|cut -d "*" -f2`
		vci=`echo $conf|cut -d "*" -f3`
		encap=`echo $conf|cut -d "*" -f4`

		if [ -z $proto -o -z $vpi -o -z $vci -o -z $encap ]; then
			echo "conf miss"
		else
			# pvc detect
#			pvc_set && {
				# wan detect
			wan_detect_quick_scan $i && {
				save_conf "quick"
				rm $LOCK_FILE
				echo "############################ADSL QuickScan success, detect result:$protoResult" > /dev/console
				echo "############################ADSL QuickScan success, detect result:$protoResult" >> $LOG
				exit $protoResult
			}
#			}
		fi

		i=$(( $i+1 ))
	done

	if [ "X$ipoa_conf" != "X" ]; then
		proto=`echo $ipoa_conf|cut -d "*" -f1`
		vpi=`echo $ipoa_conf|cut -d "*" -f2`
		vci=`echo $ipoa_conf|cut -d "*" -f3`
		encap=`echo $ipoa_conf|cut -d "*" -f4`
		save_conf "full"
		rm $LOCK_FILE
		exit 130
	fi
	rm $LOCK_FILE
	echo "############################ADSL QuickScan Fail." > /dev/console
	echo "############################ADSL QuickScan Fail." >> $LOG
	exit 64
}


fs_vpis="0 1 8 2 3 4 5 6 7 9 10"
# vci range [32, 102] with step 1
func_adsl_full_scan ()
{
	while [ -f $LOCK_FILE ]; do
		sleep 1
	done

	touch $LOCK_FILE

	echo "############################ADSL i am in FullScan process..." > /dev/console
	echo "############################ADSL i am in FullScan process..." >> $LOG


	local wan_proto=$($CONFIG get wan_proto)

	protoResult=0
	killall oamd
	/usr/bin/oamd &
	for vpi in $fs_vpis
	do
		vci=32
		while [ $vci -le 102 ]
		do
#			pvc_detect && {
#				for encap in "llc vc"
#				do
#					for proto in "pppoa pppoe dhcp ipoa"
#					do
#						wan_detect && {
#							save_conf
#							rm $LOCK_FILE
#							exit $FS_Y
#						}
#					done
#				done
#			}
			for encap in llc vc
			do
				pvc_detect && wan_detect_full_scan && {
					save_conf "full"
					killall oamd
					rm $LOCK_FILE
					echo "############################ADSL FullScan success vpi:$vpi,vci:$vci,encap:$encap" > /dev/console
					echo "############################ADSL FullScan success vpi:$vpi,vci:$vci,encap:$encap" >> $LOG
					exit $protoResult
				}
			done
			vci=$(( $vci+1 ))
		done
	done
	
	killall oamd
	rm $LOCK_FILE
	echo "############################ADSL FullScan Fail." > /dev/console
	echo "############################ADSL FullScan Fail." >> $LOG
	exit 0
}

for opt in $OPTIONS; do
	if [ -n "$1" ] && [ "$1" = "$opt" ]; then
		shift
		eval $@
		func_$opt

		exit 0;
	fi
done

echo "Error: dni_adsl_scan.sh not option $opt." > /dev/console
