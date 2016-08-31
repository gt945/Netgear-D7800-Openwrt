#!/bin/sh

USBPATH=`mount | grep '/dev/sd' |awk '{print $3}' |xargs |awk '{print $1}'`

/usr/bin/zip /log.zip -r /log_* -m

if [ "x$USBPATH" = "x" ]; then
	rm -rf /log.zip
	exit 0 
fi

mv /log.zip $USBPATH/log.zip

