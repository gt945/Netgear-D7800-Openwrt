#!/bin/sh /etc/rc.common
# Copyright (C) 2013 OpenWrt.org
#START=22
xDSL_AnnexMode=""
xDSL_AnnexMode_a="AnnexA"
xDSL_AnnexMode_b="AnnexB"
xTSE=""
xTSE_a="05_00_04_00_4C_01_04_07"   # Annex : A, L, M
xTSE_b="10_00_10_40_00_04_01_07"   # Annex : B, J
LINE_SET=""
LINE_GET=""

xDSL_BinDir=/opt/lantiq/bin
#xDSL_FwDir=/lib/firmware/`uname -r`
xDSL_FwRootfsDir=/lib/firmware
xDSL_FwDir=/firmware
xDSL_FwFileName=""
xDSL_FwFileName_a=xcpe_hw.bin
xDSL_FwFileName_b=xcpe_hw_b.bin
xDSL_InitDir=/etc/init.d
xDSL_CtrlAppName="ltq_cpe_control_init.sh"

# Default configuration for values that will be overwritten with external
# values defined within "dsl_auto.cfg.
xDSL_AutoCfg_Bonding=0
xDSL_AutoCfg_VectoringL2=0

if [ ! "$CONFIGLOADED" ]; then
   if [ -r /etc/rc.d/config.sh ]; then
      . /etc/rc.d/config.sh 2>/dev/null
      CONFIGLOADED="1"
   fi
fi

if [ -r ${xDSL_BinDir}/dsl_auto.cfg ]; then
   . ${xDSL_BinDir}/dsl_auto.cfg 2> /dev/null
fi

if [ ${xDSL_AutoCfg_Bonding} = 1 ]; then
   # In case of activated bonding an additional line/device parameter needs
   # to be used for all CLI commands.
   # In case of a get command just read it from line/device zero (by default
   # all lines/devices will have the same configuration)
   LINE_GET="0"
   # In case of a set command apply configuration to all lines/devices
   LINE_SET="-1"
fi

get_xDSL_AnnexMode()
{
   local str=$($CONFIG get xDSL_AnnexMode)
   [ -n "$str" ] && echo "$str" && return
   [ "$($CONFIG get GUI_Region)" = "German" ] && echo "$xDSL_AnnexMode_b" || echo "$xDSL_AnnexMode_a"
}

set_xDSL_AnnexMode() # $1 : xDSL_AnnexMode
{
   $CONFIG set xDSL_AnnexMode="$1"
   $CONFIG commit
}

detect_xDSL_AnnexMode()
{
   local n=0

   while [ $n -lt 10 ]; do
      VIG_VALS=`${xDSL_BinDir}/dsl_cpe_pipe.sh vig`
      if [ "$?" = "0" ]; then
         for k in $VIG_VALS; do eval $k 2>/dev/null; done
         echo "======> n = $n; nHybrid = $nHybrid" > /dev/console
         if [ "$DSL_ChipSetFWVersion" != "n/a" ]; then
            [ "$nHybrid" = "1" ] && echo "$xDSL_AnnexMode_a" && return 0
            [ "$nHybrid" = "3" ] && echo "$xDSL_AnnexMode_b" && return 0
         fi
      fi
      n=$(($n + 1))
      sleep 1
   done
   return 1
}

# Function to wait until the firmware download has been successfully finished
# on all available lines
# Arguments for this function
#   $1: Timeout in seconds
# Return value(s):
#   FIRMWARE_READY (global variable)
#     0: One or both lines does not reach defined linestate (from $1)
#     1: Both lines have reached defined linestate (from $1)
wait_for_firmware_ready() {
   nTimeout=$1
   nTimeoutInit=$1

   while [ $nTimeout -gt 0 ]
   do
      nFirmwareReady=0

      if [ ${xDSL_AutoCfg_Bonding} = 1 ]; then
         nLines=2
      else
         nLines=1
      fi

      nLine=0
      while [ $nLine -lt $nLines ]
      do
         if [ ${xDSL_AutoCfg_Bonding} = 1 ]; then
            nLineGet="$nLine"
         else
            nLineGet=""
         fi

         VIG_VALS=`${xDSL_BinDir}/dsl_cpe_pipe.sh vig $nLineGet`
         if [ "$?" = "0" ]; then
            for k in $VIG_VALS; do eval $k 2>/dev/null; done
            if [ "$DSL_ChipSetFWVersion" != "n/a" ]; then
               nFirmwareReady=`expr $nFirmwareReady + 1`
            fi
         else
            echo "Error during processing of lsg command!"
         fi
         nLine=`expr $nLine + 1`
      done
      if [ "$nFirmwareReady" = "$nLines" ]; then
         nTimeUsed=`expr $nTimeoutInit - $nTimeout`
         echo "${xDSL_CtrlAppName}: Firmware ready wait time $nTimeUsed sec."
         FIRMWARE_READY=1
         break
      fi
      nTimeout=`expr $nTimeout - 1`
      sleep 1
   done
}

# Parameters that are externally defined and which are of relevance within
# this script handling
# Starting with "xDSL_Cfg_xxx" or "xDSL_Dbg_xx" are defined within dsl.cfg
start()     # $1: need_to_detect_xDSL_AnnexMode
{
   MAC_ADR=""
   DBG_TEST_IF=""
   DTI_IF_STR=""
   TCPM_IF_STR=""
   AUTOBOOT_ADSL=""
   AUTOBOOT_VDSL=""
   NOTIFICATION_SCRIPT=""
   DEBUG_CFG=""
   ACTIVATION_CFG=""
   TCPM_IF=""
   DTI_IF=""
   XDSL_MULTIMODE=""
   XTM_MULTIMODE=""
   DSL_FIRMWARE=""
   FW_FOUND=0
   START_CTRL=0
   RETX_ENA_DS=1
   RETX_ENA_US=0

   # This default initializations will be overwritten with external values defined
   # within "rc.conf", "dsl.cfg" or "ltq_dsl_functions.sh". In case of inconsistencies
   # within that files it takes care that this script can be executed without
   # problems using default settings
   xTM_Mgmt_Mode=""
   wan_mode="VDSL"
   BS_ENA=1
   RETX_ENA=1
   VN_ENA=1
   CNTL_MODE_ENA=0
   CNTL_MODE=0
   VECT_ENA=1

   if [ -f /sys/class/net/br0/address ]; then
      MAC_ADR=`cat /sys/class/net/br0/address`
   else
      # Initialize MAC address with Linux command line setting (from u-boot)
      MAC_ADR=`cat /proc/cmdline | grep -E -o '([a-fA-F0-9]{2}\:){5}[a-fA-F0-9]{2}'`
   fi

   xDSL_AnnexMode=$(get_xDSL_AnnexMode)
   if [ $xDSL_AnnexMode = $xDSL_AnnexMode_b ]; then
      xTSE=$xTSE_b
      xDSL_FwFileName=$xDSL_FwFileName_b
   else
      xTSE=$xTSE_a
      xDSL_FwFileName=$xDSL_FwFileName_a
   fi

   # This script handles the DSL FSM for Multimode configuration
   # Determine the mode in which the DSL Control Application should be started
   echo "0" > /tmp/adsl_status
   if [ -r /etc/rc.conf ]; then
      . /etc/rc.conf 2> /dev/null
   fi

   if [ -r ${xDSL_BinDir}/dsl.cfg ]; then
      . ${xDSL_BinDir}/dsl.cfg 2> /dev/null
   fi

   # This script checks if one of primary or secondary wan modes is DSL and returns the values.
   # Current running DSL Phy and TC  - get_phy_tc_info
   # xTSE bits for the current running mode in X_X_X_X_X_X_X_X format - calc_xtse
   if [ -e /etc/rc.d/ltq_dsl_functions.sh ]; then
      . /etc/rc.d/ltq_dsl_functions.sh
   fi

   # get_phy_tc_info fucntion returns wan_mode = VDSL or ADSL.
   # nTC_Mode - 1 - ATM, 2- PTM, 4 - Auto
   get_phy_tc_info

   # Only for VRX Platform, we can use either ADSL or VDSL, hence the
   # DSL Control should be started in both cases
   if [ "$wan_mode" = "AUTO" -o "$wan_mode" = "ADSL" -o "$wan_mode" = "VDSL" ]; then

      echo "${xDSL_CtrlAppName}: DSL related system status:"
      echo "${xDSL_CtrlAppName}:   L2 vectoring = $xDSL_AutoCfg_VectoringL2"
      echo "${xDSL_CtrlAppName}:   bonding      = $xDSL_AutoCfg_Bonding"

      echo `cat /proc/modules` | grep -q "drv_dsl_cpe_api" && {
         START_CTRL=1
      }

      if [ -e ${xDSL_BinDir}/adsl.scr ]; then
         AUTOBOOT_ADSL="-a ${xDSL_BinDir}/adsl.scr"
      fi

      if [ -e ${xDSL_BinDir}/vdsl.scr ]; then
         AUTOBOOT_VDSL="-A ${xDSL_BinDir}/vdsl.scr"
      fi

      if [ -e ${xDSL_InitDir}/xdslrc.sh ]; then
         NOTIFICATION_SCRIPT="-n ${xDSL_InitDir}/xdslrc.sh"
      fi

      if [ -e ${xDSL_FwDir}/${xDSL_FwFileName} ]; then
         DSL_FIRMWARE="-f ${xDSL_FwDir}/${xDSL_FwFileName}"
         FW_FOUND=1
      elif [ -e ${xDSL_FwRootfsDir}/${xDSL_FwFileName} ]; then
         DSL_FIRMWARE="-f ${xDSL_FwRootfsDir}/${xDSL_FwFileName}"
         FW_FOUND=1
      fi
      

      # Check if debug capabilities are enabled within dsl_cpe_control
      # and configure according settings if required
      echo `${xDSL_BinDir}/dsl_cpe_control -h` | grep -q "(-D)" && {
         if [ "$xDSL_Dbg_DebugLevel" != "" ]; then
            DEBUG_LEVEL_COMMON="-D${xDSL_Dbg_DebugLevel}"
            if [ "$xDSL_Dbg_DebugLevelsApp" != "" ]; then
               DEBUG_LEVELS_APP="-G${xDSL_Dbg_DebugLevelsApp}"
            fi
            if [ "$xDSL_Dbg_DebugLevelsDrv" != "" ]; then
               DEBUG_LEVELS_DRV="-g${xDSL_Dbg_DebugLevelsDrv}"
            fi
            DEBUG_CFG="${DEBUG_LEVEL_COMMON} ${DEBUG_LEVELS_DRV} ${DEBUG_LEVELS_APP}"
            echo "${xDSL_CtrlAppName}: TestCfg: DEBUG_CFG=${DEBUG_CFG}"
         else
            if [ -e ${xDSL_BinDir}/debug_level.cfg ]; then
               # read in the global definition of the debug level
               . ${xDSL_BinDir}/debug_level.cfg 2> /dev/null

               if [ "$ENABLE_DEBUG_OUTPUT" != "" ]; then
                  DEBUG_CFG="-D${ENABLE_DEBUG_OUTPUT}"
               fi
            fi
         fi
      }

      # Special test and debug functionality to use Telefonica switching mode
      # configuration from dsl.cfg
      if [ "$xDSL_Cfg_ActSeq" == "2" ]; then
         ACTIVATION_CFG="-S${xDSL_Cfg_ActSeq}_${xDSL_Cfg_ActMode}"
      fi

      # Usage of debug and test interfaces (if available).
      # Configuration from dsl.cfg
      case "$xDSL_Dbg_DebugAndTestInterfaces" in
         "0")
            # Do not use interfaces, empty string is anyhow default (just in case)
            DTI_IF_STR=""
            TCPM_IF_STR=""
            ;;
         "1")
            # Use LAN interfaces for debug and test communication
            DBG_TEST_IF=`ifconfig br0 | grep -E -o \
               'addr:([0-9]{1,3}?\.){3}([0-9]{1,3}?{1})' | cut -d':' -f2`
            if [ "$DBG_TEST_IF" != "" ]; then
               DTI_IF_STR="-d${DBG_TEST_IF}"
               TCPM_IF_STR="-t${DBG_TEST_IF}"
            else
               echo "${xDSL_CtrlAppName}: ERROR processing LAN IP-Address " \
                  "(no test and debug functionality available)!"
            fi
            ;;
         "2")
            # Use all interfaces for debug and test communication
            DTI_IF_STR="-d0.0.0.0"
            TCPM_IF_STR="-t0.0.0.0"
            ;;
      esac

      echo `${xDSL_BinDir}/dsl_cpe_control -h` | grep -q "(-d)" && {
         DTI_IF="${DTI_IF_STR}"
      }

      echo `${xDSL_BinDir}/dsl_cpe_control -h` | grep -q "(-t)" && {
         TCPM_IF="${TCPM_IF_STR}"
      }

      # Special test and debug functionality to use multimode realted
      # configuration for initial xDSL mode
      if [ "$xDSL_Cfg_NextMode" != "" ]; then
         # Use multimode realted configuration from dsl.cfg
         XDSL_MULTIMODE="-M${xDSL_Cfg_NextMode}"
      else
         # Use multimode realted configuration from UGW system level
         # configuration (rc.conf)
         # Initialize the NextMode with the last showtime mode to optimize the
         # timing of the first link start

         # Use default configuration (set to API-default value)
         XDSL_MULTIMODE="-M0"
         if [ "$wan_mode" = "AUTO" ]; then
            if [ "$next_mode" = "ADSL" ]; then
               XDSL_MULTIMODE="-M1"
            elif [ "$next_mode" = "VDSL" ]; then
               XDSL_MULTIMODE="-M2"
            fi
         fi
      fi

      # Special test and debug functionality to use multimode realted
      # configuration for initial SystemInterface configuration
      if [ "$xDSL_Cfg_SystemInterface" != "" ]; then
         # Use multimode realted configuration from dsl.cfg
         XTM_MULTIMODE="-T${xDSL_Cfg_SystemInterface}"
         echo "${xDSL_CtrlAppName}: TestCfg: XTM_MULTIMODE=${XTM_MULTIMODE}"
      else
         # Use multimode realted configuration from UGW system level
         # configuration (rc.conf)
         if [ "$nADSL_TC_Mode" != "" -a "$nVDSL_TC_Mode" != "" ]; then
            XTM_MULTIMODE="-T$nADSL_TC_Mode:0x1:0x1_$nVDSL_TC_Mode:0x1:0x1"
         else
            XTM_MULTIMODE=""
         fi
      fi

      ##########################################################################
      # start dsl cpe control application with appropriate options

      if [ ${FW_FOUND} = 0 -o ${START_CTRL} = 0 ]; then
         echo "${xDSL_CtrlAppName}: API *not* started due to the following reason"
         if [ ${FW_FOUND} = 0 ]; then
            echo "${xDSL_CtrlAppName}: -> No firmware binary available within '${xDSL_FwDir}'"
         fi
         if [ ${START_CTRL} = 0 ]; then
            echo "${xDSL_CtrlAppName}: -> API driver (drv_dsl_cpe_api) not installed within system"
         fi
      else
         # call the function to calculate the xTSE bits
         calc_xtse

         # Special test and debug functionality uses xTSE configuration from dsl.cfg
#        if [ "$xDSL_Cfg_G997XTU" != "" ]; then
#           xTSE="${xDSL_Cfg_G997XTU}"
            echo "${xDSL_CtrlAppName}: TestCfg: xTSE=${xTSE}"
#        fi

         # Special test and debug functionality uses Bitswap configuration from dsl.cfg
         if [ "$xDSL_Cfg_BitswapEnable" != "" ]; then
            BS_ENA="${xDSL_Cfg_BitswapEnable}"
            echo "${xDSL_CtrlAppName}: TestCfg: BS_ENA=${BS_ENA}"
         fi

         # Special test and debug functionality uses ReTx(DS) configuration from dsl.cfg
         if [ "$xDSL_Cfg_ReTxEnable_Ds" != "" ]; then
            RETX_ENA_DS="${xDSL_Cfg_ReTxEnable_Ds}"
            echo "${xDSL_CtrlAppName}: TestCfg: RETX_ENA_DS=${RETX_ENA_DS}"
         else
            RETX_ENA_DS=${RETX_ENA}
         fi
         # Special test and debug functionality uses ReTx(US) configuration from dsl.cfg
         if [ "$xDSL_Cfg_ReTxEnable_Us" != "" ]; then
            RETX_ENA_US="${xDSL_Cfg_ReTxEnable_Us}"
            echo "${xDSL_CtrlAppName}: TestCfg: RETX_ENA_US=${RETX_ENA_US}"
         else
            RETX_ENA_US=${RETX_ENA}
         fi

         # Special test and debug functionality uses VN configuration from dsl.cfg
         if [ "$xDSL_Cfg_VNEnable" != "" ]; then
            VN_ENA="${xDSL_Cfg_VNEnable}"
            echo "${xDSL_CtrlAppName}: TestCfg: VN_ENA=${VN_ENA}"
         fi

         # Special test and debug functionality to activate DSL related kernel prints
         if [ "$xDSL_Dbg_EnablePrint" == "1" ]; then
            echo 7 > /proc/sys/kernel/printk
         fi

         # start DSL CPE Control Application in the background
         ${xDSL_BinDir}/dsl_cpe_control ${DEBUG_CFG} -i${xTSE} ${DSL_FIRMWARE} \
            ${XDSL_MULTIMODE} ${XTM_MULTIMODE} ${AUTOBOOT_VDSL} ${AUTOBOOT_ADSL} \
            ${NOTIFICATION_SCRIPT} ${TCPM_IF} ${DTI_IF} ${ACTIVATION_CFG} &

         PS=`ps`
         # Timeout to wait for dsl_cpe_control startup [in seconds]
         iLp=10
         echo $PS | grep -q dsl_cpe_control && {
            # workaround for nfs: allow write to pipes for non-root
            while [ ! -e /tmp/pipe/dsl_cpe1_ack -a $iLp -gt 0 ] ; do
               iLp=`expr $iLp - 1`
               sleep 1;
            done

            if [ ${iLp} -le 0 ]; then
               echo "${xDSL_CtrlAppName}: Problem with pipe handling, exit" \
                  "dsl_cpe_control startup!!!"
               false
            fi

            chmod a+w /tmp/pipe/dsl_*
         }
         echo $PS | grep -q dsl_cpe_control || {
            echo "${xDSL_CtrlAppName}: Start of dsl_cpe_control failed!!!"
            false
         }

         # Special test and debug functionality to activate event console prints
         if [ "$xDSL_Dbg_EnablePrint" == "1" ]; then
            tail -f /tmp/pipe/dsl_cpe0_event &
         fi

         sleep 1

         if [ "$wan_mode" = "ADSL" ]; then
            /usr/sbin/status_oper SET BW_INFO max_us_bw "512"
         fi

         # Apply low level configurations
         # Special test and debug functionality uses Handshake tone configuration from dsl.cfg
         if [ "$xDSL_Cfg_LowLevelHsTonesSet" == "1" ]; then
            echo "${xDSL_CtrlAppName}: TestCfg: Test/Debug cfg for HS tones selected"
            echo "${xDSL_CtrlAppName}:   A =0x${xDSL_Cfg_LowLevelHsTonesVal_A}"
            echo "${xDSL_CtrlAppName}:   V =0x${xDSL_Cfg_LowLevelHsTonesVal_V}"

            LLCG_VALS=`${xDSL_BinDir}/dsl_cpe_pipe.sh llcg $LINE_GET`
            if [ "$?" = "0" ]; then
               for i in $LLCG_VALS; do eval $i 2>/dev/null; done
               ${xDSL_BinDir}/dsl_cpe_pipe.sh llcs $LINE_SET $nFilter 1 \
                  $xDSL_Cfg_LowLevelHsTonesVal_A $xDSL_Cfg_LowLevelHsTonesVal_V \
                  0 $nBaseAddr $nIrqNum $bNtrEnable >/dev/null
            else
               echo "Error during processing of HS tones. Using defaults instead!"
            fi
         fi

         sleep 1

         # Apply configurations for LineFeatureConfigSet (lfcs)
         dir="0 1"
         for j in $dir ; do
            # Map configuration values that are direction specific
            if [ "$j" = "0" ]; then
               # Upstream (US) values
               RETX_ENA_CLI=${RETX_ENA_US}
            else
               # Downstream (DS) values
               RETX_ENA_CLI=${RETX_ENA_DS}
            fi
            LFCG_VALS=`${xDSL_BinDir}/dsl_cpe_pipe.sh lfcg $LINE_GET $j`
            if [ "$?" = "0" ]; then
               for i in $LFCG_VALS; do eval $i 2>/dev/null; done
               ${xDSL_BinDir}/dsl_cpe_pipe.sh lfcs $LINE_SET $nDirection \
                  $bTrellisEnable $BS_ENA $RETX_ENA_CLI $VN_ENA \
                  $b20BitSupport >/dev/null
            else
               if [ "$j" = "0" ]; then
                  ${xDSL_BinDir}/dsl_cpe_pipe.sh lfcs $LINE_SET $j 1 $BS_ENA \
                     $RETX_ENA_CLI $VN_ENA -1 >/dev/null
               else
                  ${xDSL_BinDir}/dsl_cpe_pipe.sh lfcs $LINE_SET $j 1 $BS_ENA \
                     $RETX_ENA_CLI $VN_ENA 0 >/dev/null
               fi
            fi
         done

         # Apply TestMode configuration from system level configuration
         if [ "$CNTL_MODE_ENA" = "1" ]; then
            if [ "$CNTL_MODE" = "0" ]; then
               ${xDSL_BinDir}/dsl_cpe_pipe.sh tmcs $LINE_SET 1 >/dev/null
            elif [ "$CNTL_MODE" = "1" ]; then
               ${xDSL_BinDir}/dsl_cpe_pipe.sh tmcs $LINE_SET 2 >/dev/null
            fi
         fi

         # Apply configurations for reboot criteria's
         # Special test and debug functionality uses configuration from dsl.cfg
         if [ "$xDSL_Cfg_RebootCritSet" == "1" ]; then
            ${xDSL_BinDir}/dsl_cpe_pipe.sh rccs $LINE_SET $xDSL_Cfg_RebootCritVal >/dev/null
            echo "${xDSL_CtrlAppName}: TestCfg: xDSL_Cfg_RebootCritVal=${xDSL_Cfg_RebootCritVal}"
         fi

         # Apply configurations for SRA
         # Special test and debug functionality uses configuration from dsl.cfg
         if [ "$xDSL_Cfg_SraSet" == "1" ]; then
            ${xDSL_BinDir}/dsl_cpe_pipe.sh g997racs $LINE_SET 0 0 `expr $xDSL_Cfg_SraVal_A_Us + 2` >/dev/null
            ${xDSL_BinDir}/dsl_cpe_pipe.sh g997racs $LINE_SET 0 1 `expr $xDSL_Cfg_SraVal_A_Ds + 2` >/dev/null
            ${xDSL_BinDir}/dsl_cpe_pipe.sh g997racs $LINE_SET 1 0 `expr $xDSL_Cfg_SraVal_V_Us + 2` >/dev/null
            ${xDSL_BinDir}/dsl_cpe_pipe.sh g997racs $LINE_SET 1 1 `expr $xDSL_Cfg_SraVal_V_Ds + 2` >/dev/null
            echo "${xDSL_CtrlAppName}: TestCfg: xDSL_Cfg_SraVal_A_Us=${xDSL_Cfg_SraVal_A_Us}"
            echo "${xDSL_CtrlAppName}: TestCfg: xDSL_Cfg_SraVal_A_Ds=${xDSL_Cfg_SraVal_A_Ds}"
            echo "${xDSL_CtrlAppName}: TestCfg: xDSL_Cfg_SraVal_V_Us=${xDSL_Cfg_SraVal_V_Us}"
            echo "${xDSL_CtrlAppName}: TestCfg: xDSL_Cfg_SraVal_V_Ds=${xDSL_Cfg_SraVal_V_Ds}"
         fi

         FIRMWARE_READY=0
         wait_for_firmware_ready 7
         # [TBR] After Jira DSLCPE_SW-784 has been solved
         sleep 1
         if [ $FIRMWARE_READY = 1 ]; then

            if [ ${xDSL_AutoCfg_VectoringL2} = 1 ]; then
               ${xDSL_BinDir}/dsl_cpe_pipe.sh dsmmcs $LINE_SET $MAC_ADR
               # Special functionality uses vectoring configuration from dsl.cfg
               if [ "$xDSL_Cfg_VectoringEnable" != "" ]; then
                  if [ ${xDSL_Cfg_VectoringEnable} = 3 ]; then
                     # *No* configuration required in this case (MEI driver handles it autonomously)!
                     echo "${xDSL_CtrlAppName}: G.Vector (best fitting, automatic MEI Driver mode)"
                  else
                     ${xDSL_BinDir}/dsl_cpe_pipe.sh dsmcs $LINE_SET $xDSL_Cfg_VectoringEnable
                     echo "${xDSL_CtrlAppName}: G.Vector configuration = ${xDSL_Cfg_VectoringEnable}"
                  fi
               else
                  # Not supported yet, using MEI Driver automatic mode instead as default
                  #if [ "$VECT_ENA" = "1" ]; then
                  #   ${xDSL_BinDir}/dsl_cpe_pipe.sh dsmcs $LINE_SET 1
                  #fi
                  # *No* configuration required in this case (MEI driver handles it autonomously)!
                  echo "${xDSL_CtrlAppName}: G.Vector (best fitting, automatic MEI Driver mode)"
               fi
            fi

            ${xDSL_BinDir}/dsl_cpe_pipe.sh acs $LINE_SET 1
            if [ "$1" = "need_to_detect_xDSL_AnnexMode" ]; then
               xDSL_AnnexMode_detected=$(detect_xDSL_AnnexMode)
               if [ "$?" = "0" ]; then
                  if [ $xDSL_AnnexMode != $xDSL_AnnexMode_detected ]; then
                     set_xDSL_AnnexMode $xDSL_AnnexMode_detected
                     return 99
                  fi
               else
                  echo "Timeout in detect_xDSL_AnnexMode !"
               fi
            fi
         else
            echo "Timeout within waiting for firmware ready!"
            echo "Autoboot handling of API could be not started!"
         fi
      fi
   fi
}

stop() {
   ${xDSL_BinDir}/dsl_cpe_pipe.sh acos $LINE_SET 1 1 1 0 0 0
   ${xDSL_BinDir}/dsl_cpe_pipe.sh acs $LINE_SET 2
   sleep 3
   ${xDSL_BinDir}/dsl_cpe_pipe.sh acs $LINE_SET 0
   ${xDSL_BinDir}/dsl_cpe_pipe.sh quit $LINE_SET
}

boot()
{
   start need_to_detect_xDSL_AnnexMode
   if [ "$?" = "99" ]; then
      echo "======> restart ltq_cpe_control_init.sh !" > /dev/console
      stop; sleep 2;
      /etc/init.d/ltq_load_dsl_cpe_api.sh stop; sleep 2
      /etc/init.d/ltq_load_dsl_cpe_api.sh start; sleep 2
      start
   fi
}
