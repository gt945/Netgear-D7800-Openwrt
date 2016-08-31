#!/bin/sh

WIZLOG="/tmp/wizard_log"
echo "[lantiq] ***************Lantiq-DSL-msg********************" >> $WIZLOG

while [ 1 ]; do

	TIME=`/bin/date '+%Y%m%d%H%M'`
	echo "[lantiq] **********Date:$TIME******************" >> $WIZLOG

	lsg_value=`/opt/lantiq/bin/dsl_cpe_pipe.sh lsg| awk -F['='' '] '{print $4}'`
	echo "[lantiq] dsl_cpe_pipe.sh lsg:  $lsg_value"		>> $WIZLOG

	if [ "$lsg_value" = "0x200" ]; then

		echo "[lantiq] dsl_cpe_pipe.sh vig         "     >> $WIZLOG
		/bin/date										 >> $WIZLOG
		/opt/lantiq/bin/dsl_cpe_pipe.sh vig				 >> $WIZLOG

		echo "[lantiq] dsl_cpe_pipe.sh g997xtusesg "     >> $WIZLOG
		/bin/date										 >> $WIZLOG
		/opt/lantiq/bin/dsl_cpe_pipe.sh g997xtusesg		 >> $WIZLOG 

	elif [ "$lsg_value" = "0x801" ]; then
		echo "[lantiq] dsl_cpe_pipe.sh g997xtusesg "     >> $WIZLOG
		/bin/date										 >> $WIZLOG
		/opt/lantiq/bin/dsl_cpe_pipe.sh g997xtusesg		 >> $WIZLOG

		echo "[lantiq] dsl_cpe_pipe.sh pmccsg 0 0 0" 	 >> $WIZLOG
		/bin/date										 >> $WIZLOG
		/opt/lantiq/bin/dsl_cpe_pipe.sh pmccsg 0 0 0	 >> $WIZLOG

		echo "[lantiq] dsl_cpe_pipe.sh pmccsg 0 1 0" 	 >> $WIZLOG
		/bin/date										 >> $WIZLOG
		/opt/lantiq/bin/dsl_cpe_pipe.sh pmccsg 0 1 0	 >> $WIZLOG

		echo "[lantiq] dsl_cpe_pipe.sh g997lsg 0 1" 	 >> $WIZLOG
		/bin/date										 >> $WIZLOG
		/opt/lantiq/bin/dsl_cpe_pipe.sh g997lsg 0 1	 	 >> $WIZLOG

		echo "[lantiq] dsl_cpe_pipe.sh g997lsg 1 1" 	 >> $WIZLOG
		/bin/date										 >> $WIZLOG
		/opt/lantiq/bin/dsl_cpe_pipe.sh g997lsg 1 1	 	 >> $WIZLOG

		echo "[lantiq] dsl_cpe_pipe.sh g997lig 1" 		 >> $WIZLOG
		/bin/date										 >> $WIZLOG
		/opt/lantiq/bin/dsl_cpe_pipe.sh g997lig 1	 	 >> $WIZLOG

		echo "[lantiq] dsl_cpe_pipe.sh g997csg 0 0" 	 >> $WIZLOG
		/bin/date										 >> $WIZLOG
		/opt/lantiq/bin/dsl_cpe_pipe.sh g997csg 0 0	 	 >> $WIZLOG

		echo "[lantiq] dsl_cpe_pipe.sh g997csg 0 1" 	 >> $WIZLOG
		/bin/date										 >> $WIZLOG
		/opt/lantiq/bin/dsl_cpe_pipe.sh g997csg 0 1	 	 >> $WIZLOG

	fi

			size=`du -m $WIZLOG |awk '{print $1}'`
			if [ $size -ge 2 ]; then
				rm -rf $WIZLOG
			fi
			sleep 4
done
