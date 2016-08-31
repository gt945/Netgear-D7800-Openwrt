#! /bin/sh

###############################################################################
### THIS SCRIPT IS A QUICK ENTRY TO MANAGE NET-WALL RULEs
###
###     Consider some times we need to add|delete|change firewall rules on
###     urgent, and it's not easy to modify net-wall source code directly,
###     so add this quick entry to manage firewall rules.
###
###     Each time when `net-wall start|restart` command executes, this script
###     will be called with parameter "start", and of course, `net-wall stop`
###     will call this script with parameter "stop".
###
### NOTE: THIS SCRIPT IS *JUST* A QUICK ENTRY, PLEASE MANAGE FIREWALL RULES
### IN NET-WALL SOURCE CODE AS FAR AS POSSIBLE. AND PLEASE MOVE SOME CHANGES
### IN THIS FILE INTO NET-WALL SOURCE CODE IN THE FUTURE TO KEEP THIS FILE
### IS CONCISE TO REDUCE AFFECTS OF NET-WALL'S PERFORMANCE.
###############################################################################

IPTB=/usr/sbin/iptables
CONFIG=${CONFIG:-/bin/config}

LIBDIR=/etc/net-wall/scripts

get_configs()
{
	:
}

firewall_start()
{
	# start extra firewall rules
	ls ${LIBDIR}/*.rule | while read rule
	do
		$SHELL $rule start
	done

	# should implement a openvpn.rule in openvpn module,
	# and install to $LIBDIR.
	if [ "x$($CONFIG get vpn_enable)" = "x1" ]; then
		/etc/openvpn/vpn-firewall.sh
	fi

	# should implement a streamboost.rule in streamboost,
	# and install to $LIBDIR.
	if [ "x$($CONFIG get streamboost_enable)" = "x1" ]; then
		/etc/appflow/streamboost.d/40_qdiscman teardown_iptables
		/etc/appflow/streamboost.d/40_qdiscman setup_iptables
	fi
}

firewall_stop()
{
	# stop extra firewall rules
	ls ${LIBDIR}/*.rule | while read rule
	do
		$SHELL $rule stop
	done

	# should implement a openvpn.rule in openvpn module,
	# and install to $LIBDIR.
	if [ "x$($CONFIG get vpn_enable)" = "x1" ]; then
		/etc/openvpn/vpn-firewall.sh
	fi

	# should implement a streamboost.rule in streamboost,
	# and install to $LIBDIR.
	if [ "x$($CONFIG get streamboost_enable)" = "x1" ]; then
		/etc/appflow/streamboost.d/40_qdiscman teardown_iptables
		/etc/appflow/streamboost.d/40_qdiscman setup_iptables
	fi
}

get_configs
case ${0##*/} in
	"addon_start.sh")
		firewall_start;;
	"addon_stop.sh")
		firewall_stop;;
	*)
		printf "Usage: ${0##*/} start|stop\n";;
esac
