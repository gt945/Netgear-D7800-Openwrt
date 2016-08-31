#!/bin/sh
# Copyright(c) Lantiq Deutschland GmbH 2014
#######################################################################
# DSL CPE Control Notification script called by DSL CPE Control Daemon.
#######################################################################
#
# Macros exported by DSL CPE control Application:-
#
# DSL_NOTIFICATION_TYPE="DSL_STATUS|DSL_INTERFACE_STATUS|DSL_DATARATE_STATUS|DSL_DATARATE_STATUS_US"
# In DSL_STATUS:-
#	DSL_BONDING_STATUS="INACTIVE|ACTIVE"
#	DSL_LINE_NUMBER=" |-1|1|2"
#	DSL_XTU_STATUS="VDSL|ADSL"
#	DSL_TC_LAYER_STATUS="ATM|PTM|EFM"
# In DSL_INTERFACE_STATUS:-
#	DSL_INTERFACE_STATUS="UP|DOWN|READY|TRAINING"
#	DSL_LINE_NUMBER=" -1|1|2"
#	DSL_XTU_STATUS="VDSL|ADSL"
#	DSL_TC_LAYER_STATUS="ATM|PTM|EFM"
#	DSL_DATARATE_US_BC0
#	DSL_DATARATE_DS_BC0
# In DSL_DATARATE_STATUS and DSL_DATARATE_STATUS_US
#	DSL_LINE_NUMBER=" -1|1|2"
#	DSL_XTU_STATUS="VDSL|ADSL"
#	DSL_TC_LAYER_STATUS="ATM|PTM|EFM"
#	DSL_DATARATE_US_BC0
#	DSL_DATARATE_DS_BC0
#
#########################################################################

DSL_STATUS_FILE="/tmp/DSL_status"

outp ()
{
	#echo "$@" > /dev/console
	echo " "  >> /tmp/wizard_log
	/bin/date 	  >> /tmp/wizard_log
	echo "$@" >> /tmp/wizard_log
}

print_details ()
{
	outp "DSL_BONDING_STATUS: $DSL_BONDING_STATUS"
	outp "DSL_LINE_NUMBER: $DSL_LINE_NUMBER"
	outp "DSL_XTU_STATUS: $DSL_XTU_STATUS"
	outp "DSL_TC_LAYER_STATUS: $DSL_TC_LAYER_STATUS"
	outp "DSL_DATARATE_US_BC0: $DSL_DATARATE_US_BC0"
	outp "DSL_DATARATE_DS_BC0: $DSL_DATARATE_DS_BC0"
}

case $DSL_NOTIFICATION_TYPE in
	DSL_STATUS)
		case "$DSL_XTU_STATUS" in
			"VDSL")
				config set dsl_wan_mode="vdsl"
				config commit
				local num=0
				while [ -f /tmp/.dni_dsl_net_wan_lock -a $num -lt 30 ]; do
					sleep 1
					num=$(($num+1))
				done
				/usr/sbin/dni_dsl_net_wan.sh configure_wan_mode vdsl
				;;
			"ADSL")
				config set dsl_wan_mode="adsl"
				config commit
				local num=0
				while [ -f /tmp/.dni_dsl_net_wan_lock -a $num -lt 30 ]; do
					sleep 1
					num=$(($num+1))
				done
				/usr/sbin/dni_dsl_net_wan.sh configure_wan_mode adsl
				;;
		esac
#		outp "DSL_STATUS"
#		print_details
	;;
	DSL_INTERFACE_STATUS)
		case "$DSL_INTERFACE_STATUS" in
			"UP")
				echo UP > $DSL_STATUS_FILE
				cat /proc/uptime |awk -F. '{print $1}' > /tmp/DSL_uptime
				;;
			"DOWN")
				echo DOWN > $DSL_STATUS_FILE
				rm -rf /tmp/DSL_uptime
				;;
			"READY")
				echo READY > $DSL_STATUS_FILE
				rm -rf /tmp/DSL_uptime
				;;
			"TRAINING")
				echo TRAINING > $DSL_STATUS_FILE
				rm -rf /tmp/DSL_uptime
				;;
			*)
				echo DOWN > $DSL_STATUS_FILE
				rm -rf /tmp/DSL_uptime
		esac

		outp "DSL_INTERFACE_STATUS: $DSL_INTERFACE_STATUS"
		print_details
		if [ -n "$DSL_INTERFACE_STATUS" -a "$DSL_INTERFACE_STATUS" = "UP" ]; then
			echo " "	>> /tmp/wizard_log
			/bin/date		>> /tmp/wizard_log
			echo "DSL US Data Rate = $(( $DSL_DATARATE_US_BC0 / 1000 )) kbps" >> /tmp/wizard_log
			echo "DSL DS Data Rate = $(( $DSL_DATARATE_DS_BC0 / 1000 )) kbps" >> /tmp/wizard_log
		fi
	;;
	DSL_DATARATE_STATUS)
		outp "DSL_DATARATE_STATUS"
#		print_details
		outp "DSL US Data Rate = $(( $DSL_DATARATE_US_BC0 / 1000 )) kbps"
		outp "DSL DS Data Rate = $(( $DSL_DATARATE_DS_BC0 / 1000 )) kbps"
	;;
	DSL_DATARATE_STATUS_US)
		outp "DSL_DATARATE_STATUS_US"
#		print_details
		outp "DSL US Data Rate = $(( $DSL_DATARATE_US_BC0 / 1000 )) kbps"
	;;
	*)
		outp "DSL_UNKNOWN"
#		print_details
	;;
esac

