#!/bin/sh /etc/rc.common

#START=10

start ()
{
	lantiq_dsl_wan.sh load_driver_module
}

boot ()
{
	start
}
