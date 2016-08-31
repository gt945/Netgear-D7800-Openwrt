#! /bin/sh

### pre-define configs on board ###

CONFIG=$(which config)
commit_flag=0

# Load Different projects Default config if needed.
if [ "$($CONFIG get check_default_for_project)" = "1" ]; then
	if [ "$($CONFIG get Device_name)" = "D7800" ]; then
		$CONFIG set dsl_support="1"
		$CONFIG set wan_endis_dod="0"
		$CONFIG set wan_pppoe_demand="0"
		$CONFIG set wan_bpa_demand="0"
		$CONFIG set wan_pptp_demand="0"
		$CONFIG set wan_l2tp_demand="0"
		$CONFIG set wan_mulpppoe_demand="0"
	fi
	$CONFIG set check_default_for_project="0"
	commit_flag=1
fi

# Load Default QoS rules if needed.
if [ "x$($CONFIG get qos_list_default)" = "x1" ]; then
	count=1
	while :
	do
		qos_rule="$($CONFIG get qos_dft_list$count)"
		if [ "x$qos_rule" = "x" ]; then
			break;
		fi
		$CONFIG set qos_list$count="$qos_rule"

		count=`expr $count + 1`
	done

	count=`expr $count - 1`
	echo "$count QoS default rules are Loaded!"

	$CONFIG set qos_list_default="0"
	commit_flag=1
fi

#if restore the factory default read region from flash
if [ "x$($CONFIG get board_region_default)" = "x1" ]; then
	region="$(artmtd -r region | grep REGION | awk '{print $2}')"

	#when region setting on flash's board data area is RU
	if [ "$region" = "RU" ];then
		$CONFIG set wla_country="19"
		$CONFIG set wl_country="19"
		$CONFIG set ntp_server="GMT-4"
		$CONFIG set ntpserver_select="GMT-4"
		$CONFIG set ntp_hidden_select="27"
		$CONFIG set time_zone="GMT-4"
		$CONFIG set email_ntpserver="GMT-4"
		$CONFIG set region_flag="DISABLED"
		$CONFIG set dsl_wan_country="Russia"
		$CONFIG set dsl_wan_isp="Rostelecom"
		$CONFIG set wla_simple_mode="8"
	fi

	#when region setting on flash's board data area is GR
	if [ "$region" = "GR" ];then
		$CONFIG set wla_country="4"
		$CONFIG set wl_country="4"
		$CONFIG set ntp_server="GMT-1"
		$CONFIG set ntpserver_select="GMT-1"
		$CONFIG set ntp_hidden_select="19"
		$CONFIG set time_zone="GMT-1"
		$CONFIG set email_ntpserver="GMT-1"
		$CONFIG set dsl_wan_country="Germany"
		$CONFIG set dsl_wan_isp="Deutsche Telekom"
	fi

	#when region setting on flash's board data area is PR
	if [ "$region" = "PR" ];then
		$CONFIG set wla_country="11"
		$CONFIG set wl_country="11"
		$CONFIG set ntp_server="GMT-8"
		$CONFIG set ntpserver_select="GMT-8"
		$CONFIG set ntp_hidden_select="33"
		$CONFIG set time_zone="GMT-8"
		$CONFIG set email_ntpserver="GMT-8"
		$CONFIG set dsl_wan_country="China"
		$CONFIG set dsl_wan_isp="China Telecom"
	fi

	#when region setting on flash's board data area is BZ
	if [ "$region" = "BZ" ];then
		$CONFIG set wla_country="9"
		$CONFIG set wl_country="9"
		$CONFIG set ntp_server="GMT+3"
		$CONFIG set ntpserver_select="GMT+3"
		$CONFIG set ntp_hidden_select="14"
		$CONFIG set time_zone="GMT+3"
		$CONFIG set email_ntpserver="GMT+3"
		$CONFIG set dsl_wan_country="Brazil"
		$CONFIG set dsl_wan_isp="Gvt-Global Village Telecom"
	fi

	#when region setting on flash's board data area is IN
	if [ "$region" = "IN" ];then
		$CONFIG set wla_country="12"
		$CONFIG set wl_country="12"
		$CONFIG set ntp_server="GMT-5:30"
		$CONFIG set ntpserver_select="GMT-5:30"
		$CONFIG set ntp_hidden_select="30"
		$CONFIG set time_zone="GMT-5:30"
		$CONFIG set email_ntpserver="GMT-5:30"
		$CONFIG set dsl_wan_country="India"
		$CONFIG set dsl_wan_isp="MTNL"
	fi

	#when region setting on flash's board data area is KO
	if [ "$region" = "KO" ];then
		$CONFIG set wla_country="7"
		$CONFIG set wl_country="7"
		$CONFIG set ntp_server="GMT-9"
		$CONFIG set ntpserver_select="GMT-9"
		$CONFIG set ntp_hidden_select="35"
		$CONFIG set time_zone="GMT-9"
		$CONFIG set email_ntpserver="GMT-9"
	fi

	#when region setting on flash's board data area is JP
	if [ "$region" = "JP" ];then
		$CONFIG set wla_country="6"
		$CONFIG set wl_country="6"
		$CONFIG set ntp_server="GMT-9"
		$CONFIG set ntpserver_select="GMT-9"
		$CONFIG set ntp_hidden_select="35"
		$CONFIG set time_zone="GMT-9"
		$CONFIG set email_ntpserver="GMT-9"
		$CONFIG set region_flag="DISABLED"
	fi

	#when region setting on flash's board data area is NA
	if [ "$region" = "NA" -o "$region" = "US" ];then
		$CONFIG set wla_country="10"
		$CONFIG set wl_country="10"
		$CONFIG set wla_hidden_channel="153"
		$CONFIG set region_flag="DISABLED"
		$CONFIG set ntp_server="GMT+8"
		$CONFIG set ntpserver_select="GMT+8"
		$CONFIG set ntp_hidden_select="4"
		$CONFIG set time_zone="GMT+8"
		$CONFIG set email_ntpserver="GMT+8"
		$CONFIG set dsl_wan_country="USA"
		$CONFIG set dsl_wan_isp="CenturyLink"
	fi

	#when region setting on flash's board data area is AU
	if [ "$region" = "AU" ];then
		$CONFIG set wla_country="2"
		$CONFIG set wl_country="2"
		$CONFIG set ntp_server="GMT-10"
		$CONFIG set ntpserver_select="GMT-10"
		$CONFIG set ntp_hidden_select="37"
		$CONFIG set time_zone="GMT-10"
		$CONFIG set email_ntpserver="GMT-10"
		$CONFIG set dsl_wan_country="Australia"
		$CONFIG set dsl_wan_isp="Telstra"
	fi

	#when region setting on flash's board data area is CA
	if [ "$region" = "CA" ];then
		$CONFIG set wla_country="3"
		$CONFIG set wl_country="3"
		$CONFIG set ntp_server="GMT+5"
		$CONFIG set ntpserver_select="GMT+5"
		$CONFIG set ntp_hidden_select="10"
		$CONFIG set time_zone="GMT+5"
		$CONFIG set email_ntpserver="GMT+5"
	fi

	#when region setting on flash's board data area is PE
	if [ "$region" = "PE" ];then
		$CONFIG set dsl_wan_country="Switzerland"
		$CONFIG set dsl_wan_isp="Sunrise"
	fi
	#when region setting on flash's board data area is UK
	if [ "$region" = "UK" ];then
		$CONFIG set dsl_wan_country="UK"
		$CONFIG set dsl_wan_isp="BT"
	fi
	#when region setting on flash's board data area is EE
	if [ "$region" = "EE" ];then
		$CONFIG set dsl_wan_country="Poland"
		$CONFIG set dsl_wan_isp="Orange"
	fi
	#when region setting on flash's board data area is GE
	if [ "$region" = "GE" ];then
		$CONFIG set dsl_wan_country="Switzerland"
		$CONFIG set dsl_wan_isp="Sunrise"
	fi

	$CONFIG set board_region_default="0"
	commit_flag=1
fi

# Wireless security pre-set
if [ "x$($CONFIG get default_ssphrase)" = "x1" ]; then
	artmtd -r ssid
	artmtd -r passphrase

	if [ -s /tmp/ssid-setted ] && [ -s /tmp/passphrase-setted ]; then
		id_set=$(awk '{print $1}' /tmp/ssid-setted)
		ps_set=$(awk '{print $1}' /tmp/passphrase-setted)

		$CONFIG set wl_ssid="${id_set}"
		$CONFIG set wla_ssid="${id_set}-5G"
		$CONFIG set wl_wpa2_psk="${ps_set}"
		$CONFIG set wla_wpa2_psk="${ps_set}"
		$CONFIG set wl_sectype="4"
		$CONFIG set wla_sectype="4"
		$CONFIG set wps_status="5"
		$CONFIG set wla_wps_status="5"

		# set SSID of guest netwroks according to Home Router GUI Redesign
		# Specification Rev10 section 6.3
		$CONFIG set wlg1_ssid="NETGEAR-Guest"
		$CONFIG set wla1_ssid="NETGEAR-5G-Guest"
	fi

	$CONFIG set default_ssphrase="0"
	commit_flag=1
fi

[ "$commit_flag" = "1" ] && $CONFIG commit
