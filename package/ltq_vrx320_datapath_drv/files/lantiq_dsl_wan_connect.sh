#!/bin/sh /etc/rc.common

#START=90

start ()
{
	lantiq_dsl_wan.sh start_connection
	[ "$($CONFIG get wan2_active)" = "1" ] && lantiq_dsl_wan2.sh start_connection

#	/usr/sbin/dni_dsl_log_upload.sh &
}

boot ()
{
	start
}
