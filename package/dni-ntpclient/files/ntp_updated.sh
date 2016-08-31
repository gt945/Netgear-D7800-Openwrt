#!/bin/sh

CONFIG=/bin/config
wlan_schedule="wlan schedule"

#Record first NTP Sync Timestamp, if the Timestamp have existed on pot partition, ntpst will do nothing.
ntpst -T $($CONFIG get time_zone) -d $(part_path pot)

# When time updates, and selects "Per Schedule" for "Block Sites" && "Block Services", generate the crond's schedule file again.
if [ "x$($CONFIG get block_skeyword)" = "x1" ] || [ "x$($CONFIG get blockserv_ctrl)" = "x1" ]; then
	/sbin/cmdsched
	firewall.sh start
fi

# when time updates,it must check whether WIFI should be turned off according WIFI Schedule
if [ "x$($CONFIG get wladv_schedule_enable)" = "x1" ]; then
	/sbin/cmdsched_wlan_status 11g
	[ "x$($CONFIG get wlg_onoff_sched)" = "x1" ] && \
		$wlan_schedule 11g off || \
		$wlan_schedule 11g on
fi

if [ "x$($CONFIG get wladv_schedule_enable_a)" = "x1" ]; then
	/sbin/cmdsched_wlan_status 11a
	[ "x$($CONFIG get wla_onoff_sched)" = "x1" ] && \
		$wlan_schedule 11a off || \
		$wlan_schedule 11a on
fi

