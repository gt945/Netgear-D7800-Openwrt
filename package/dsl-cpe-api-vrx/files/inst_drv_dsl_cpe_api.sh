#! /bin/sh
#
# Install DSL CPE API Driver
# if no para : use local debug level
# para 1 ($1): debug level (0 = use local debug level)
# para 2 ($2): entities (default: 0)
#

# This default initializations will be overwritten with external values defined
# within rc.conf. In case of inconsistencies within rc.conf it takes care that
# this script can be executed without problems using default settings
wan_mode="VDSL"

if [ -r /etc/rc.conf ]; then
   . /etc/rc.conf 2> /dev/null
fi

if [ -e /etc/rc.d/ltq_dsl_functions.sh ]; then
   # get_phy_tc_info would return the wan_mode information updated based on the WAN configured.
   . /etc/rc.d/ltq_dsl_functions.sh 
   get_phy_tc_info
fi

if [ "$wan_mode" = "AUTO" -o "$wan_mode" = "ADSL" -o "$wan_mode" = "VDSL" ]; then
   # check for linux 2.6.x or 3.8.x or 3.10.x
   uname -r | grep -q -e 2.6. -e 3.4. -e 3.8. -e 3.10.
   if [ $? -eq 0 ]; then
      MODEXT=.ko
   fi

   drv_dev_base_name=dsl_cpe_api
   drv_obj_file_name=drv_dsl_cpe_api$MODEXT

   # set debug_level: 1=low, 2=normal, 3=high, 4=off
   debug_level=3

   # use parameter as debug_level, if != 0
   if [ $# != 0 ] && [ "$1" != 0 ]; then
      debug_level=$1
   fi

   # enable debugging outputs, if necessary
   if [ "$debug_level" -le 2 ]; then
      echo 8 > /proc/sys/kernel/printk
   fi

   if [ "$debug_level" -le 2 ]; then
      echo "- loading $drv_dev_base_name ($drv_obj_file_name device) driver -"
   fi
   insmod $drv_obj_file_name debug_level=$debug_level
   # add "drv_major_number=$drv_major_number" for fixed major number

   if [ $? -ne 0 ]; then
      echo "- loading driver failed! -"
      exit 1
   fi

   #major_no=`grep $drv_dev_base_name /proc/devices |cut -d' ' -f1`
   major_no=109
   
   # exit if major number not found (in case of devfs)
   if [ -z $major_no ]; then
      exit 0
   fi

   if [ "$debug_level" -le 2 ]; then
      echo "- create device nodes for $drv_dev_base_name device driver -"
   fi

   prefix=/dev/$drv_dev_base_name
   test ! -d $prefix/ && mkdir $prefix/

   # use param $2 or default to 1"
   export entities=${2:-1}

   I=0
   while test $I -lt $entities; do
      test ! -e $prefix/$I && mknod $prefix/$I c $major_no $I
      I=`expr $I + 1`
   done
fi
