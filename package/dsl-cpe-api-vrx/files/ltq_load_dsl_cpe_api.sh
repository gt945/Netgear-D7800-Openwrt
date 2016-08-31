#!/bin/sh /etc/rc.common
# Copyright (C) 2012 OpenWrt.org
#START=18
DebugLevel=3

BIN_DIR=/opt/lantiq/bin

# Default configuration for values that will be overwritten with external
# values defined within "dsl_auto.cfg.
xDSL_AutoCfg_Entities=1

EXTRA_COMMANDS="dbg_on dbg_off"
EXTRA_HELP="	dbg_on	Enable debugging outputs \n
	dbg_off	Disable debugging outputs"

start() {
	[ -z "`cat /proc/modules | grep ifxos`" ] && {
		echo "Ooops - IFXOS isn't loaded, DSL CPE API will do it. Check your basefiles..."
		insmod /lib/modules/*/drv_ifxos.ko
	}

	if [ -r ${BIN_DIR}/dsl.cfg ]; then
		. ${BIN_DIR}/dsl.cfg 2> /dev/null
	fi

	if [ "$xDSL_Dbg_DebugLevel" != "" ]; then
		DebugLevel="${xDSL_Dbg_DebugLevel}"
	else
		if [ -e ${BIN_DIR}/debug_level.cfg ]; then
			# read in the global definition of the debug level
			. ${BIN_DIR}/debug_level.cfg 2> /dev/null

			if [ "$ENABLE_DEBUG_OUTPUT" != "" ]; then
				DebugLevel="${ENABLE_DEBUG_OUTPUT}"
			fi
		fi
	fi

	# Get environment variables for system related configuration
	if [ -r ${BIN_DIR}/dsl_auto.cfg ]; then
		. ${BIN_DIR}/dsl_auto.cfg 2> /dev/null
	fi

	# loading DSL CPE API driver -
	cd ${BIN_DIR}
	${BIN_DIR}/inst_drv_dsl_cpe_api.sh $DebugLevel $xDSL_AutoCfg_Entities
}

stop() {
	rmmod drv_dsl_cpe_api
}

dbg_on() {
	echo 7 > /proc/sys/kernel/printk
}

dbg_off() {
	echo 4 > /proc/sys/kernel/printk
}
