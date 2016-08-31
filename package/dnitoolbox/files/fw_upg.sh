#! /bin/sh

. /dni-gconfig

if [ $# -ne 1 ] || [ ! -f $1 ]; then
	printf "Usage:	${0##*/} <firmware>\n" >&2
	exit 1
fi

# before firmware update, it will execute /sbin/run-ramfs, we should copy
# action scripts to /tmp to ensure it keep valid during upgrading.
cp -rf /usr/etc/firmware_update /tmp/

/usr/sbin/firmware_update \
	-d $(part_path firmware) \
	-p ${DGC_PRODUCT_NAME} \
	-i ${DGC_HW_ID} \
	-0 /tmp/firmware_update/pre_action.sh \
	-1 /tmp/firmware_update/do_action.sh \
	-2 /tmp/firmware_update/post_action.sh \
	$1
exit $?
