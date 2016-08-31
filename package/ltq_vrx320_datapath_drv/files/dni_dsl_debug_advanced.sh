#!/bin/sh

USBPATH=`mount | grep '/dev/sd' |awk '{print $3}' |xargs |awk '{print $1}'`

dsl=`cat /tmp/dsl_port_status`
if [ $dsl -eq 0 ]; then
	echo "DSL not detected, Please plugin the DSL cable and try again"
	exit 0
fi

if [ "x$USBPATH" = "x" ]; then
	exit 0
fi

echo "USB Mounted. Start logging..."
#rm -rf $USBPATH/log.zip
rm -rf /log.zip
rm -rf /log_*

while [ 1 ]; do

	TIME=`/bin/date '+%Y%m%d%H%M'`
	FP=/log_$TIME
	echo $TIME >> $FP

		for i in $(seq 43200); do

			#cat /proc/kmsg >> $FP &
			#dmesg >> $FP &
			TIME=`/bin/date '+%Y%m%d%H%M'`

			echo "**********************Lantiq-DSL-msg***********************" >> $FP
			echo "**						Date: $TIME" 			  		   >> $FP
			echo "[PM_ChannelCountersTotalGet]" 	   			 >> $FP
			/opt/lantiq/bin/dsl_cpe_pipe.sh pmcctg 0 0 			 >> $FP
			/opt/lantiq/bin/dsl_cpe_pipe.sh pmcctg 0 1 			 >> $FP
			echo "[G997_LineStatusGet]"   						 >> $FP
			/opt/lantiq/bin/dsl_cpe_pipe.sh g997lsg 0 1 		 >> $FP
			/opt/lantiq/bin/dsl_cpe_pipe.sh g997lsg 1 1 		 >> $FP
			echo "[LineFailureStatusGet]" 						 >> $FP
			/opt/lantiq/bin/dsl_cpe_pipe.sh g997lfsg 0 			 >> $FP
			/opt/lantiq/bin/dsl_cpe_pipe.sh g997lfsg 1 			 >> $FP

			echo "[pint dsl_cpe_pepe.sh g997xtusecg, vig, lsg,]" >> $FP
			/opt/lantiq/bin/dsl_cpe_pipe.sh g997xtusecg 		 >> $FP
			/opt/lantiq/bin/dsl_cpe_pipe.sh vig 				 >> $FP
			/opt/lantiq/bin/dsl_cpe_pipe.sh lsg 				 >> $FP

			size=`du -m $FP |awk '{print $1}'`

			if [ $size -ge 2 ];
				then break
			fi

			sleep 5
			done	

	#killall -9 cat >/dev/null
done
