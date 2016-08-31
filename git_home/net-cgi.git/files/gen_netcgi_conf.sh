#! /bin/sh

CONF_FILE="/tmp/netcgi.conf"

CONFIG_BIN=${CONFIG_BIN:-/bin/config}

append_configs()
{
	printf "%s\n" "$*" >> $CONF_FILE
}

###
# modify this function to works with a series products for single image.
collect_configs()
{
	[ "x$($CONFIG_BIN get green_download_enable)" = "x0" ] \
		&& append_configs nc_have_greendownload OFF

	append_configs nc_host_name $(cat /module_name)
}

cat >$CONF_FILE <<-EOF
	##############################################################################
	# This file was generated automatically, it configurate net-cgi features.    #
	# All lines begin with '#' are comments and will be ignored in net-cgi.      #
	# Each config line use format: "<config_name> <config_value>", exclude       #
	# colon. <config_name> should be a valid config name in net-cgi source file  #
	# nc_config_default.c, and <config_value> should be string, number or ON|OFF #
	# for boolean value of some config variables.                                #
	##############################################################################
EOF
collect_configs
