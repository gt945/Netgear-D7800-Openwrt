#! /bin/sh

CONFIG="/bin/config"
FIREWALL="firewall.sh"

sched_block_site()
{
	if [ "x$1" = "xstart" ]; then
		$CONFIG set blk_site_sched=1
	else
		$CONFIG set blk_site_sched=0
	fi

	$FIREWALL restart
}

sched_block_service()
{
	if [ "x$1" = "xstart" ]; then
		$CONFIG set blk_svc_sched=1
	else
		$CONFIG set blk_svc_sched=0
	fi

	$FIREWALL restart
}

case $1 in
	"blk_site")
		sched_block_site $2
		;;
	"blk_svc")
		sched_block_service $2
		;;
	*)
		echo "Usage: ${0##*/} blk_site|blk_svc start|stop"
		exit 1
		;;
esac

