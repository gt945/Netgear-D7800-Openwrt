#the following line combines the last line to prevent this file from being sourced twice
if [ "x$net_br_dhcpc_helper_sh" = "x" ]; then net_br_dhcpc_helper_sh="sourced"
. /lib/cfgmgr/cfgmgr.sh

# this file is target depedent,
# it provids following functions for /etc/init.d/net-br-dhcpc-helper
#    brmode_wlg_linked()
#    brmode_wla_linked()
#    brmode_wlg_fixup()
#    brmode_wla_fixup()
#
#    extmode_wlg_linked()
#    extmode_wla_linked()
#    extmode_wlg_fixup()
#    extmode_wla_fixup()

brmode_wlg_linked()
{
	[ "$(awk 'NR==3' /proc/sys/net/ath1/status)" = "RUN" ]
}

brmode_wla_linked()
{
	[ "$(awk 'NR==3' /proc/sys/net/ath0/status)" = "RUN" ]
}

extmode_wlg_linked()
{
	[ "$(awk 'NR==3' /proc/sys/net/ath1/status)" = "RUN" ]
}

extmode_wlg_fixup()
{
	oc echo "unable to estabilish extmode 2.4G wireless link !"

	local extchannel=$(extkit 2g scan | awk -v ssid=$($CONFIG get wlg_ext_ssid) '
	BEGIN {var = "\x22" ssid "\x22"}
	{ if ($1 == var) { print $2; exit } }
	')

	[ -n ${extchannel} -a "${extchannel}" != "$($CONFIG get wlg_ext_channel)" ] && {
		oc echo "new 2.4G ext channel : $extchannel !"
		$CONFIG set wlg_ext_channel="$extchannel" && $CONFIG commit
		/etc/init.d/wlan-common restart
	}
}

extmode_wla_linked()
{
	[ "$(awk 'NR==3' /proc/sys/net/ath0/status)" = "RUN" ]
}
fi #-------------------- this must be the last line -----------------------------
