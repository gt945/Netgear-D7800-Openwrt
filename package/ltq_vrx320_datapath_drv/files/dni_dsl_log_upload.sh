#!/bin/sh

CONFIG=/bin/config


sleep 300
TIME=`/bin/date '+%Y%m%d%H%M'`
curMac=`/sbin/ifconfig br0 | awk '/HWaddr/ { print $5 }'|sed 's/://g'`;
FP=/tmp/${curMac}_BootState_$TIME

dsl_wan_preference=`$CONFIG get dsl_wan_preference`

	if [ "$dsl_wan_preference" = "2" ]; then
		exit 0
	elif [ "$dsl_wan_preference" = "1" ]; then
		dsl_wan_type=`$CONFIG get dsl_wan_type`

		if [ "$dsl_wan_type" = "adsl" ]; then
		##############ADSL########################
		wan_factory_mac=`$CONFIG get wan_factory_mac`
		dsl_wan_country=`$CONFIG get dsl_wan_country`
		dsl_wan_isp=`$CONFIG get dsl_wan_isp`
		wan_proto=`$CONFIG get wan_proto`		
		dsl_wan_vci=`$CONFIG get dsl_wan_vci`
		dsl_wan_vpi=`$CONFIG get dsl_wan_vci`
		dsl_wan_multiple=`$CONFIG get dsl_wan_multiple`
		dsl_wan_video_vid=`$CONFIG get dsl_wan_video_vid`

		echo "[DEBUG][dsl_wan_type=ADSL]" > $FP
		echo "[DEBUG][wan_mac=$wan_factory_mac]" >> $FP
		echo "[DEBUG][Country=$dsl_wan_country]" >> $FP
		echo "[DEBUG][ISP=$dsl_wan_isp]" >> $FP
		echo "[DEBUG][Proto=$wan_proto]" >> $FP
		echo "[DEBUG][VCI=$dsl_wan_vci]" >> $FP
		echo "[DEBUG][VPI=$dsl_wan_vpi]" >> $FP
		echo "[DEBUG][Multiple=$dsl_wan_multiple]" >> $FP
		echo "[DEBUG][Video_vid=$dsl_wan_video_vid]" >> $FP

		elif [ "$dsl_wan_type" = "vdsl" ]; then
		##############VDSL########################
		wan_factory_mac=`$CONFIG get wan_factory_mac`
		dsl_wan_country=`$CONFIG get dsl_wan_country`
		dsl_wan_isp=`$CONFIG get dsl_wan_isp`
		vdsl_wan_ifname=`$CONFIG get vdsl_wan_ifname`
		dsl_wan_data_vid=`$CONFIG get dsl_wan_data_vid`
		dsl_wan_data_proto=`$CONFIG get dsl_wan_data_proto`
		dsl_wan_video_vid=`$CONFIG get dsl_wan_video_vid`
		dsl_wan_video_proto=`$CONFIG get dsl_wan_video_proto`
		dsl_wan_voice_vid=`$CONFIG get dsl_wan_voice_vid`
		dsl_wan_voice_proto=`$CONFIG get dsl_wan_voice_proto`
		wan2_active=`$CONFIG get wan2_active`

		echo "[DEBUG][dsl_wan_type=VDSL]" > $FP
		echo "[DEBUG][wan_mac=$wan_factory_mac]" >> $FP
		echo "[DEBUG][Country=$dsl_wan_country]" >> $FP
		echo "[DEBUG][ISP=$dsl_wan_isp]" >> $FP
		echo "[DEBUG][ifname=$vdsl_wan_ifname]" >> $FP
		echo "[DEBUG][Data_vid=$dsl_wan_data_vid]" >> $FP
		echo "[DEBUG][Data_proto=$dsl_wan_data_proto]" >> $FP
		echo "[DEBUG][Video_vid=$dsl_wan_video_vid]" >> $FP
		echo "[DEBUG][Video_proto=$dsl_wan_video_proto]" >> $FP
		echo "[DEBUG][Voice_vid=$dsl_wan_voice_vid]" >> $FP
		echo "[DEBUG][Voice_proto=$dsl_wan_voice_proto]" >> $FP
		echo "[DEBUG][wan2_active=$wan2_active]" >> $FP

		fi
		down=`/opt/lantiq/bin/dsl_cpe_pipe.sh g997csg 0 1 | awk -F['='' '] '{print $8}'`
		up=`/opt/lantiq/bin/dsl_cpe_pipe.sh g997csg 0 0 | awk -F['='' '] '{print $8}'`
		down=$(echo $down|awk '{print $0/1000/1000}')"Mbps"
		up=$(echo $up|awk '{print $0/1000/1000}')"Mbps"
		down="Downstream=$down"
		up="Upstream=$up"
		echo $down >> $FP
		echo $up >> $FP
		/usr/bin/ftpput -u ftp -p ftp "60.248.155.55" D7800/${curMac}_BootState_$TIME $FP
		rm -rf $FP
	fi





