/******************************************************************************
**
** FILE NAME    : ppa_api_qos.c
** PROJECT      : UEIP
** MODULES      : PPA API (Routing/Bridging Acceleration APIs)
**
** DATE         : 11 DEC 2009
** AUTHOR       : Shao Guohua
** DESCRIPTION  : PPA Protocol Stack QOS API Implementation
** COPYRIGHT    :              Copyright (c) 2009
**                          Lantiq Deutschland GmbH
**                   Am Campeon 3; 85579 Neubiberg, Germany
**
**   For licensing information, see the file 'LICENSE' in the root folder of
**   this software module.
**
** HISTORY
** $Date        $Author            $Comment
** 11 DEC 2009  Shao Guohua        Initiate Version
*******************************************************************************/


//#include <linux/autoconf.h>
#include <linux/version.h>
#if LINUX_VERSION_CODE < KERNEL_VERSION(2, 6, 33)
#include <linux/autoconf.h>
#else
#include <generated/autoconf.h>
#endif
#include <linux/version.h>
#include <linux/kernel.h>
#include <linux/module.h>
#include <linux/types.h>
#include <linux/init.h>
#include <linux/slab.h>
#include <linux/netdevice.h>
#include <linux/atmdev.h>
#include <net/sock.h>



/*
 *  PPA Specific Head File
 */
//#include <net/ppa_api.h>
#include <net/ppa_stack_al.h>
//#include "ppa_api_misc.h"
//#include "ppa_api_netif.h"
//#include "ppa_api_session.h"
#include "lantiq_wrapper.h"
#include "vrx320_common.h"
#include "vrx320_api_qos.h"
#include "vrx320_drv_wrapper.h"
//#include "ppe_drv_wrapper.h"
//#include "ppa_api_mib.h"

/*
 *  device constant
 */
#define PPA_CHR_DEV_MAJOR                       181
#define PPA_DEV_NAME                            "ppa"



void ppa_trace_lock_get(PPA_LOCK *p_lock)
{
    ASSERT(p_lock->cnt == 0,"Lock already taken!!!, lock cnt: %d\n", p_lock->cnt);
    if(p_lock->cnt != 0){
        dump_stack();
    }
    p_lock->cnt += 1;
}

void ppa_trace_lock_release(PPA_LOCK *p_lock)
{
    ASSERT(p_lock->cnt == 1, "Lock already released!!!, lock cnt: %d\n", p_lock->cnt);
    if(p_lock->cnt != 1){
        dump_stack();
    }
    p_lock->cnt -= 1;
}

void ppa_lock_get(PPA_LOCK *p_lock)
{
  spin_lock_bh(&p_lock->lock);
  ppa_trace_lock_get(p_lock);
}

void ppa_lock_release(PPA_LOCK *p_lock)
{
  ppa_trace_lock_release(p_lock);
  spin_unlock_bh(&p_lock->lock);
}


#ifdef CONFIG_LTQ_PPA_QOS

/*From ppa_api/ppa_api_mib.c*/
PPA_LOCK  g_general_lock;
static uint32_t last_jiffy_port_mib;
//QoS queue MIB varabiles
static PPA_QOS_STATUS g_qos_mib_accumulated[PPA_MAX_PORT_NUM];          /* accumulatd mib counter */
static PPA_QOS_STATUS g_qos_mib_last_instant_read[PPA_MAX_PORT_NUM];  /* last instant read counter */
static uint32_t last_jiffy_qos_mib[PPA_MAX_PORT_NUM];
static PPA_QOS_STATUS g_qos_mib_accumulated_last[PPA_MAX_PORT_NUM];   /* last accumulatd mib counter */

void reset_local_mib(void)
{
    uint32_t curr_jiffy=jiffies;
    int i;
    
    ppa_lock_get(&g_general_lock);
    last_jiffy_port_mib = curr_jiffy;
    
    for(i=0; i<PPA_MAX_PORT_NUM; i++ )
        last_jiffy_qos_mib[i] = curr_jiffy;
    memset( &g_qos_mib_accumulated, 0, sizeof(g_qos_mib_accumulated));
    memset( &g_qos_mib_last_instant_read, 0, sizeof(g_qos_mib_last_instant_read));
    memset( &g_qos_mib_accumulated_last, 0, sizeof(g_qos_mib_accumulated_last));
    ppa_lock_release(&g_general_lock);
    
}

static void update_port_mib64_item(uint64_t *curr, uint64_t *last, uint64_t *accumulated)
{
    if( *curr >= *last)
        *accumulated += (*curr - *last);
    else
        *accumulated += ((uint64_t)*curr + (uint64_t)WRAPROUND_32BITS - *last);
    *last = *curr;

}

//note, so far only ioctl will set rate_flag to 1, otherwise it will be zero in ppa timer
int32_t ppa_update_qos_mib(PPA_QOS_STATUS *status, uint32_t rate_flag, uint32_t flag)
{
    uint32_t i, curr_jiffy, port_id;
    int32_t num;

    if( !status ) return PPA_FAILURE;
    if( status->qos_queue_portid >= PPA_MAX_PORT_NUM ) return PPA_FAILURE;
    
    num = ppa_get_qos_qnum(status->qos_queue_portid, 0 );
    if( num <= 0 ) 
    {
        ppa_debug(DBG_ENABLE_MASK_QOS,"ppa_get_qos_qnum failed for ppa_get_qos_qnum=%d\n",num);
        return PPA_FAILURE;
    }
    ppa_lock_get(&g_general_lock);
    if( num > PPA_MAX_QOS_QUEUE_NUM ) 
        num = PPA_MAX_QOS_QUEUE_NUM;
    status->max_buffer_size = num;
    port_id = status->qos_queue_portid;    
    
    if( ppa_drv_get_qos_status( status, flag) != PPA_SUCCESS) 
    {
        ppa_lock_release(&g_general_lock);
        ppa_debug(DBG_ENABLE_MASK_DEBUG_PRINT,"ppa_drv_get_qos_status failed\n");
        return PPA_FAILURE;   
    }
    curr_jiffy = jiffies;
    
    for(i=0; i<status->max_buffer_size; i++)
    {   
        update_port_mib64_item( &status->mib[i].mib.total_rx_pkt,                &g_qos_mib_last_instant_read[port_id].mib[i].mib.total_rx_pkt,                 &g_qos_mib_accumulated[port_id].mib[i].mib.total_rx_pkt);
        update_port_mib64_item( &status->mib[i].mib.total_rx_bytes,              &g_qos_mib_last_instant_read[port_id].mib[i].mib.total_rx_bytes,               &g_qos_mib_accumulated[port_id].mib[i].mib.total_rx_bytes);
        
        update_port_mib64_item( &status->mib[i].mib.total_tx_pkt,                &g_qos_mib_last_instant_read[port_id].mib[i].mib.total_tx_pkt,                 &g_qos_mib_accumulated[port_id].mib[i].mib.total_tx_pkt);
        update_port_mib64_item( &status->mib[i].mib.total_tx_bytes,              &g_qos_mib_last_instant_read[port_id].mib[i].mib.total_tx_bytes,               &g_qos_mib_accumulated[port_id].mib[i].mib.total_tx_bytes);

        update_port_mib64_item( &status->mib[i].mib.cpu_path_small_pkt_drop_cnt, &g_qos_mib_last_instant_read[port_id].mib[i].mib.cpu_path_small_pkt_drop_cnt,  &g_qos_mib_accumulated[port_id].mib[i].mib.cpu_path_small_pkt_drop_cnt);
        update_port_mib64_item( &status->mib[i].mib.cpu_path_total_pkt_drop_cnt, &g_qos_mib_last_instant_read[port_id].mib[i].mib.cpu_path_total_pkt_drop_cnt,  &g_qos_mib_accumulated[port_id].mib[i].mib.cpu_path_total_pkt_drop_cnt);

        update_port_mib64_item( &status->mib[i].mib.fast_path_small_pkt_drop_cnt,&g_qos_mib_last_instant_read[port_id].mib[i].mib.fast_path_small_pkt_drop_cnt, &g_qos_mib_accumulated[port_id].mib[i].mib.fast_path_small_pkt_drop_cnt);
        update_port_mib64_item( &status->mib[i].mib.fast_path_total_pkt_drop_cnt,&g_qos_mib_last_instant_read[port_id].mib[i].mib.fast_path_total_pkt_drop_cnt, &g_qos_mib_accumulated[port_id].mib[i].mib.fast_path_total_pkt_drop_cnt);

        if( rate_flag )
        {   
            status->mib[i].mib.tx_diff = ( g_qos_mib_accumulated[port_id].mib[i].mib.total_tx_bytes >= g_qos_mib_accumulated_last[port_id].mib[i].mib.total_tx_bytes )? \
                            (g_qos_mib_accumulated[port_id].mib[i].mib.total_tx_bytes - g_qos_mib_accumulated_last[port_id].mib[i].mib.total_tx_bytes) : \
                            (g_qos_mib_accumulated[port_id].mib[i].mib.total_tx_bytes + (uint64_t)WRAPROUND_32BITS - g_qos_mib_accumulated_last[port_id].mib[i].mib.total_tx_bytes);

            status->mib[i].mib.tx_diff_L1 = status->mib[i].mib.tx_diff + (g_qos_mib_accumulated[port_id].mib[i].mib.total_tx_pkt - g_qos_mib_accumulated_last[port_id].mib[i].mib.total_tx_pkt) * status->overhd_bytes;


            status->mib[i].mib.tx_diff_jiffy = ( curr_jiffy > last_jiffy_qos_mib[port_id]) ? \
                          (curr_jiffy - last_jiffy_qos_mib[port_id] ): \
                          (curr_jiffy + (uint32_t )WRAPROUND_32BITS - last_jiffy_qos_mib[port_id] );
            
            status->mib[i].mib.sys_hz = HZ;
            ppa_debug(DBG_ENABLE_MASK_DEBUG_PRINT,"port[%d] queue[%d] bytes=%010llu(%010llu-%010llu) jiffy=%010llu(%010u-%010u) overhead=%010u pkts=%010u\n",
                                                   port_id, i,  
                                                   status->mib[i].mib.tx_diff,
                                                   g_qos_mib_accumulated[port_id].mib[i].mib.total_tx_bytes, 
                                                   g_qos_mib_accumulated_last[port_id].mib[i].mib.total_tx_bytes, 
                                                   status->mib[i].mib.tx_diff_jiffy, 
                                                   curr_jiffy,
                                                   last_jiffy_qos_mib[port_id],
                                                   status->overhd_bytes,
                                                   (uint32_t)(g_qos_mib_accumulated[port_id].mib[i].mib.total_tx_pkt - g_qos_mib_accumulated_last[port_id].mib[i].mib.total_tx_pkt));
        }
    }

    if( rate_flag )
    {
        g_qos_mib_accumulated_last[port_id] = g_qos_mib_accumulated[port_id];
        last_jiffy_qos_mib[port_id] = curr_jiffy;
    }
   
    ppa_lock_release(&g_general_lock);

    return PPA_SUCCESS;
}





/*------------------*/

int32_t ppa_ioctl_get_qos_status(unsigned int cmd, unsigned long arg, PPA_CMD_DATA * cmd_info)
{   // Try to return PPA_SUCCESS with ioctl, but make sure put real return value in internal variable. 
    if ( copy_from_user( &cmd_info->qos_status_info, (void *)arg, sizeof(cmd_info->qos_status_info)) != 0 )
        return PPA_FAILURE;

    if( ppa_update_qos_mib(&cmd_info->qos_status_info.qstat, 1, cmd_info->qos_status_info.flags ) != PPA_SUCCESS )
    {
        cmd_info->qos_status_info.qstat.res = PPA_FAILURE;
    }
    else 
        cmd_info->qos_status_info.qstat.res = PPA_SUCCESS;
   
    if (copy_to_user( (void *)arg, &cmd_info->qos_status_info, sizeof(cmd_info->qos_status_info)) != 0 )
        return PPA_FAILURE;

   return PPA_SUCCESS;
}

int32_t ppa_get_qos_qnum( uint32_t portid, uint32_t flag)
{
    PPE_QOS_COUNT_CFG  count={0};

    count.portid = portid;
    count.flags = flag;

    ppa_debug(DBG_ENABLE_MASK_QOS, "ppa_get_qos_qnum for portid:%d\n", count.portid );
    //return ppa_drv_hal_generic_hook(PPA_GENERIC_HAL_GET_QOS_QUEUE_NUM, (void *)count, flag );
    if( ppa_drv_get_qos_qnum( &count, 0) != PPA_SUCCESS ) 
    {
        ppa_debug(DBG_ENABLE_MASK_QOS, "ppa_drv_get_qos_qnum failed\n");
        count.num = 0;
    }
    else
    {
        ppa_debug(DBG_ENABLE_MASK_QOS, "qos num is :%d\n", count.num );
    }
    
    return count.num;
}

int32_t ppa_ioctl_get_qos_qnum(unsigned int cmd, unsigned long arg, PPA_CMD_DATA * cmd_info)
{
    int res = PPA_FAILURE;
    PPE_QOS_COUNT_CFG count={0};
    
    memset(&cmd_info->qnum_info, 0, sizeof(cmd_info->qnum_info) );
    if ( copy_from_user( &cmd_info->qnum_info, (void *)arg, sizeof(cmd_info->qnum_info)) != 0 )
        return PPA_FAILURE;
    count.portid = cmd_info->qnum_info.portid;
    //return ppa_drv_hal_generic_hook(PPA_GENERIC_HAL_GET_QOS_QUEUE_NUM, (void *)count, flag );
    res = ppa_drv_get_qos_qnum( &count, 0);
    cmd_info->qnum_info.queue_num = count.num;
    if (copy_to_user( (void *)arg, &cmd_info->qnum_info, sizeof(cmd_info->qnum_info)) != 0 )
        return PPA_FAILURE;

   return res;
}

int32_t ppa_get_qos_mib( uint32_t portid, uint32_t queueid, PPA_QOS_MIB *mib, uint32_t flag)
{
    uint32_t res;
    PPE_QOS_MIB_INFO mib_info={0};

    mib_info.portid = portid;
    mib_info.queueid = queueid;
    mib_info.flag = flag;
    //return ppa_drv_hal_generic_hook(PPA_GENERIC_HAL_GET_QOS_MIB, (void *)mib, flag );
    res = ppa_drv_get_qos_mib( &mib_info, 0);

    *mib = mib_info.mib;
    
    return res;
}

int32_t ppa_ioctl_get_qos_mib(unsigned int cmd, unsigned long arg, PPA_CMD_DATA * cmd_info)
{
    int res = PPA_FAILURE;
    PPE_QOS_MIB_INFO mib={0};
    
    memset(&cmd_info->qos_mib_info, 0, sizeof(cmd_info->qos_mib_info) );
    if ( copy_from_user( &cmd_info->qos_mib_info, (void *)arg, sizeof(cmd_info->qos_mib_info)) != 0 )
        return PPA_FAILURE;

    mib.portid = cmd_info->qos_mib_info.portid;
    mib.flag = cmd_info->qos_mib_info.flags;
    //return ppa_drv_hal_generic_hook(PPA_GENERIC_HAL_GET_QOS_MIB, (void *)mib, flag );
    res = ppa_drv_get_qos_mib( &mib, 0);
    
    cmd_info->qos_mib_info.mib = mib.mib;

    if (copy_to_user( (void *)arg, &cmd_info->qos_mib_info, sizeof(cmd_info->qos_mib_info)) != 0 )
        return PPA_FAILURE;

   return res;
}




#ifdef CONFIG_LTQ_PPA_QOS_WFQ
int32_t ppa_set_qos_wfq( uint32_t portid, uint32_t queueid, uint32_t weight_level, uint32_t flag )
{
    PPE_QOS_WFQ_CFG wfq={0};

    wfq.portid = portid;
    wfq.queueid = queueid;
    wfq.weight_level = weight_level;
    wfq.flag = flag;

    //return ppa_drv_hal_generic_hook(PPA_GENERIC_HAL_SET_QOS_WFQ_CFG, (void *)cfg, flag );
    return ppa_drv_set_qos_wfq( &wfq, 0);    
}

int32_t ppa_get_qos_wfq( uint32_t portid, uint32_t queueid, uint32_t *weight_level, uint32_t flag)
{
    PPE_QOS_WFQ_CFG wfq={0};
    int32_t res;

    wfq.portid = portid;
    wfq.queueid = queueid;
    wfq.flag = flag;

    //return ppa_drv_hal_generic_hook(PPA_GENERIC_HAL_GET_QOS_WFQ_CFG, (void *)cfg, flag );
    res = ppa_drv_get_qos_wfq (&wfq, 0);

    if( weight_level ) *weight_level = wfq.weight_level;
    
    return res;
}

int32_t ppa_reset_qos_wfq( uint32_t portid, uint32_t queueid, uint32_t flag)
{
    PPE_QOS_WFQ_CFG cfg={0};

    cfg.portid = portid;
    cfg.queueid = queueid;
    cfg.flag = flag;
    //return ppa_drv_hal_generic_hook(PPA_GENERIC_HAL_RESET_QOS_WFQ_CFG, (void *)cfg, flag );
   return ppa_drv_reset_qos_wfq(&cfg, 0);
}

int32_t ppa_set_ctrl_qos_wfq(uint32_t portid,  uint32_t f_enable, uint32_t flag)
{
    int i;
    PPE_QOS_COUNT_CFG count={0};
    PPE_QOS_ENABLE_CFG enable_cfg={0};

    count.portid = portid;
    count.flags = flag;
    //return ppa_drv_hal_generic_hook(PPA_GENERIC_HAL_GET_QOS_QUEUE_NUM, (void *)count, flag );
    ppa_drv_get_qos_qnum( &count, 0);
    
    if( count.num <= 0 )
    {
        ppa_debug(DBG_ENABLE_MASK_QOS, "ppa_set_ctrl_qos_wfq: count.num not valid (%d) to %s wfq on port %d\n", count.num, f_enable?"enable":"disable", portid );
        return PPA_FAILURE;
    }

    enable_cfg.portid = portid;
    enable_cfg.flag = flag;
    enable_cfg.f_enable = f_enable;
    ppa_debug(DBG_ENABLE_MASK_QOS, "ppa_set_ctrl_qos_wfq to %s wfq on port %d\n", f_enable?"enable":"disable", portid );
    //return ppa_drv_hal_generic_hook(PPA_GENERIC_HAL_SET_QOS_WFQ_CTRL, (void *)enable_cfg, flag );
    ppa_drv_set_ctrl_qos_wfq( &enable_cfg, 0);    

    for( i=0; i<count.num; i++ )
           ppa_reset_qos_wfq( portid, i, 0);
    return PPA_SUCCESS;
}

int32_t ppa_get_ctrl_qos_wfq(uint32_t portid,  uint32_t *f_enable, uint32_t flag)
{ 
    int32_t res = PPA_FAILURE;
    
    if( f_enable )
    {
        PPE_QOS_ENABLE_CFG enable_cfg={0};

        enable_cfg.portid = portid;
        enable_cfg.flag = flag;
            
        res = ppa_drv_get_ctrl_qos_wfq(&enable_cfg, 0);

        if( f_enable ) *f_enable = enable_cfg.f_enable;
    }
    
    return res;
}

int32_t ppa_ioctl_set_ctrl_qos_wfq(unsigned int cmd, unsigned long arg, PPA_CMD_DATA * cmd_info)
{ /*note, arg is a pointer from ioctl, not normally pointer  */
    int32_t res;
    
    memset(&cmd_info->qos_ctrl_info, 0, sizeof(cmd_info->qos_ctrl_info) );

    if (copy_from_user( &cmd_info->qos_ctrl_info, (void *)arg, sizeof(cmd_info->qos_ctrl_info)) != 0 )
        return PPA_FAILURE;
  
     res = ppa_set_ctrl_qos_wfq(cmd_info->qos_ctrl_info.portid, cmd_info->qos_ctrl_info.enable, cmd_info->qos_ctrl_info.flags);
     if ( res != PPA_SUCCESS )
    {
        ppa_debug(DBG_ENABLE_MASK_QOS, "ppa_ioctl_set_ctrl_qos_wfq fail\n");
        res = PPA_FAILURE;
    }

     return res;
}

int32_t ppa_ioctl_get_ctrl_qos_wfq(unsigned int cmd, unsigned long arg, PPA_CMD_DATA * cmd_info)
{ /*note, arg is a pointer from ioctl, not normally pointer  */
    int res = PPA_FAILURE;
        
    memset(&cmd_info->qos_ctrl_info, 0, sizeof(cmd_info->qos_ctrl_info) );

    if (copy_from_user( &cmd_info->qos_ctrl_info, (void *)arg, sizeof(cmd_info->qos_ctrl_info)) != 0 )
        return PPA_FAILURE;

    res = ppa_get_ctrl_qos_wfq(cmd_info->qos_ctrl_info.portid, &cmd_info->qos_ctrl_info.enable, cmd_info->qos_ctrl_info.flags);
    if ( res != PPA_SUCCESS )
    {
        ppa_debug(DBG_ENABLE_MASK_QOS, "ppa_ioctl_get_ctrl_qos_wfq fail\n");
        res = PPA_FAILURE;
    }

    if (copy_to_user( (void *)arg, &cmd_info->qos_ctrl_info, sizeof(cmd_info->qos_ctrl_info)) != 0 )
        return PPA_FAILURE;

    return res;
}

int32_t ppa_ioctl_set_qos_wfq(unsigned int cmd, unsigned long arg, PPA_CMD_DATA * cmd_info)
{ /*note, arg is a pointer from ioctl, not normally pointer  */
    int32_t res;
    
    memset(&cmd_info->qos_wfq_info, 0, sizeof(cmd_info->qos_wfq_info) );

    if (copy_from_user( &cmd_info->qos_wfq_info, (void *)arg, sizeof(cmd_info->qos_wfq_info)) != 0 )
        return PPA_FAILURE;
  
     res = ppa_set_qos_wfq(cmd_info->qos_wfq_info.portid, cmd_info->qos_wfq_info.queueid, cmd_info->qos_wfq_info.weight, cmd_info->qos_wfq_info.flags);
     if ( res != PPA_SUCCESS )
    {
        ppa_debug(DBG_ENABLE_MASK_QOS, "ppa_ioctl_set_qos_wfq fail\n");
        res = PPA_FAILURE;
    }

     return res;
}

int32_t ppa_ioctl_reset_qos_wfq(unsigned int cmd, unsigned long arg, PPA_CMD_DATA * cmd_info)
{ /*note, arg is a pointer from ioctl, not normally pointer  */
    int res = PPA_FAILURE;
    
    memset(&cmd_info->qos_wfq_info, 0, sizeof(cmd_info->qos_wfq_info) );

    if (copy_from_user( &cmd_info->qos_wfq_info, (void *)arg, sizeof(cmd_info->qos_wfq_info)) != 0 )
        return PPA_FAILURE;

    //return ppa_drv_hal_generic_hook(PPA_GENERIC_HAL_RESET_QOS_WFQ_CFG, (void *)cfg, flag );
    res = ppa_reset_qos_wfq(cmd_info->qos_wfq_info.portid, cmd_info->qos_wfq_info.queueid, cmd_info->qos_wfq_info.flags);
    if ( res != PPA_SUCCESS )
    {
        ppa_debug(DBG_ENABLE_MASK_QOS, "ppa_ioctl_reset_qos_wfq fail\n");
        res = PPA_FAILURE;
    }

    return res;   
}

int32_t ppa_ioctl_get_qos_wfq(unsigned int cmd, unsigned long arg, PPA_CMD_DATA * cmd_info)
{ /*note, arg is a pointer from ioctl, not normally pointer  */
    int res = PPA_FAILURE;
        
    memset(&cmd_info->qos_wfq_info, 0, sizeof(cmd_info->qos_wfq_info) );

    if (copy_from_user( &cmd_info->qos_wfq_info, (void *)arg, sizeof(cmd_info->qos_wfq_info)) != 0 )
        return PPA_FAILURE;

    //return ppa_drv_hal_generic_hook(PPA_GENERIC_HAL_GET_QOS_WFQ_CFG, (void *)cfg, flag );
    res = ppa_get_qos_wfq(cmd_info->qos_wfq_info.portid, cmd_info->qos_wfq_info.queueid, &cmd_info->qos_wfq_info.weight, cmd_info->qos_wfq_info.flags);
    if ( res != PPA_SUCCESS )
    {
        ppa_debug(DBG_ENABLE_MASK_QOS, "ppa_ioctl_get_qos_wfq fail\n");
        res = PPA_FAILURE;
    }

    if (copy_to_user( (void *)arg, &cmd_info->qos_wfq_info, sizeof(cmd_info->qos_wfq_info)) != 0 )
        return PPA_FAILURE;

    return res;
}

EXPORT_SYMBOL(ppa_set_ctrl_qos_wfq);
EXPORT_SYMBOL(ppa_get_ctrl_qos_wfq);
EXPORT_SYMBOL(ppa_set_qos_wfq);
EXPORT_SYMBOL(ppa_get_qos_wfq);
EXPORT_SYMBOL(ppa_reset_qos_wfq);
EXPORT_SYMBOL(ppa_ioctl_set_ctrl_qos_wfq);
EXPORT_SYMBOL(ppa_ioctl_get_ctrl_qos_wfq);
EXPORT_SYMBOL(ppa_ioctl_set_qos_wfq);
EXPORT_SYMBOL(ppa_ioctl_reset_qos_wfq);
EXPORT_SYMBOL(ppa_ioctl_get_qos_wfq);
#endif  //end of CONFIG_LTQ_PPA_QOS_WFQ

#ifdef CONFIG_LTQ_PPA_QOS_RATE_SHAPING
int32_t ppa_set_ctrl_qos_rate(uint32_t portid,  uint32_t f_enable, uint32_t flag)
{
    uint32_t i;
    PPE_QOS_COUNT_CFG count={0};
    PPE_QOS_ENABLE_CFG enable_cfg={0};
    PPE_QOS_RATE_SHAPING_CFG rate={0};

    count.portid = portid;
    count.flags = flag;
    ppa_drv_get_qos_qnum( &count, 0);

    if( count.num <= 0 ) {
				printk("count.num = %d\n", count.num);
        return PPA_FAILURE;
		}

    enable_cfg.portid = portid;
    enable_cfg.flag = flag;
    enable_cfg.f_enable = f_enable;
    ppa_drv_set_ctrl_qos_rate( &enable_cfg, 0);    

    for( i=0; i<count.num; i++ )
    {
        rate.flag = 0;
        rate.portid = portid;
        ppa_drv_reset_qos_rate( &rate, 0);
    }

    return PPA_SUCCESS;
}

int32_t ppa_get_ctrl_qos_rate(uint32_t portid,  uint32_t *f_enable, uint32_t flag)
{ 
    PPE_QOS_ENABLE_CFG enable_cfg={0};
    int32_t res;

    enable_cfg.portid = portid;
    enable_cfg.flag = flag;

    res= ppa_drv_get_ctrl_qos_rate( &enable_cfg, 0);

    if( *f_enable ) *f_enable = enable_cfg.f_enable;
    return res;
}

int32_t ppa_set_qos_rate( uint32_t portid, uint32_t queueid, uint32_t rate, uint32_t burst, uint32_t flag )
{
    PPE_QOS_RATE_SHAPING_CFG rate_cfg={0};

    rate_cfg.portid = portid;
    rate_cfg.queueid = queueid;
    rate_cfg.rate_in_kbps = rate;
    rate_cfg.burst = burst;
    rate_cfg.flag = flag;
    
    return ppa_drv_set_qos_rate( &rate_cfg, 0);
}

int32_t ppa_get_qos_rate( uint32_t portid, uint32_t queueid, uint32_t *rate, uint32_t *burst, uint32_t flag)
{
    PPE_QOS_RATE_SHAPING_CFG rate_cfg={0};
    int32_t res = PPA_FAILURE;

    rate_cfg.portid = portid;
    rate_cfg.flag = flag;
    rate_cfg.queueid = queueid;
    
    res = ppa_drv_get_qos_rate( &rate_cfg, 0);

    if( rate ) *rate = rate_cfg.rate_in_kbps;
    if( burst )  *burst = rate_cfg.burst;

    return res;

}

int32_t ppa_reset_qos_rate( uint32_t portid, uint32_t queueid, uint32_t flag)
{
    PPE_QOS_RATE_SHAPING_CFG rate_cfg={0};

    rate_cfg.portid = portid;
    rate_cfg.queueid = queueid;
    rate_cfg.flag = flag;
    
    return ppa_drv_reset_qos_rate( &rate_cfg, 0);
}


int32_t ppa_ioctl_set_ctrl_qos_rate(unsigned int cmd, unsigned long arg, PPA_CMD_DATA * cmd_info)
{ /*note, arg is a pointer from ioctl, not normally pointer  */
    int32_t res;
    
    memset(&cmd_info->qos_ctrl_info, 0, sizeof(cmd_info->qos_ctrl_info) );

    if (copy_from_user( &cmd_info->qos_ctrl_info, (void *)arg, sizeof(cmd_info->qos_ctrl_info)) != 0 )
        return PPA_FAILURE;
  
     res = ppa_set_ctrl_qos_rate(cmd_info->qos_ctrl_info.portid, cmd_info->qos_ctrl_info.enable, cmd_info->qos_ctrl_info.flags);
     if ( res != PPA_SUCCESS )
    {
        ppa_debug(DBG_ENABLE_MASK_QOS, "ppa_ioctl_set_ctrl_qos_rate fail\n");
        res = PPA_FAILURE;
    }

     return res;
}

int32_t ppa_ioctl_get_ctrl_qos_rate(unsigned int cmd, unsigned long arg, PPA_CMD_DATA * cmd_info)
{ /*note, arg is a pointer from ioctl, not normally pointer  */
    int res = PPA_FAILURE;
        
    memset(&cmd_info->qos_ctrl_info, 0, sizeof(cmd_info->qos_ctrl_info) );

    if (copy_from_user( &cmd_info->qos_ctrl_info, (void *)arg, sizeof(cmd_info->qos_ctrl_info)) != 0 )
        return PPA_FAILURE;

    res = ppa_get_ctrl_qos_rate(cmd_info->qos_ctrl_info.portid, &cmd_info->qos_ctrl_info.enable, cmd_info->qos_ctrl_info.flags);
    if ( res != PPA_SUCCESS )
    {
        ppa_debug(DBG_ENABLE_MASK_QOS, "ppa_ioctl_get_ctrl_qos_rate fail\n");
        res = PPA_FAILURE;
    }

    if (copy_to_user( (void *)arg, &cmd_info->qos_ctrl_info, sizeof(cmd_info->qos_ctrl_info)) != 0 )
        return PPA_FAILURE;

    return res;
}

int32_t ppa_ioctl_set_qos_rate(unsigned int cmd, unsigned long arg, PPA_CMD_DATA * cmd_info)
{ /*note, arg is a pointer from ioctl, not normally pointer  */
    int32_t res;
    
    memset(&cmd_info->qos_rate_info, 0, sizeof(cmd_info->qos_rate_info) );

    if (copy_from_user( &cmd_info->qos_rate_info, (void *)arg, sizeof(cmd_info->qos_rate_info)) != 0 )
        return PPA_FAILURE;

    res = ppa_set_qos_rate(cmd_info->qos_rate_info.portid, cmd_info->qos_rate_info.queueid, cmd_info->qos_rate_info.rate, cmd_info->qos_rate_info.burst, cmd_info->qos_rate_info.flags);
    if ( res != PPA_SUCCESS )
    {  
        ppa_debug(DBG_ENABLE_MASK_QOS, "ppa_ioctl_set_qos_rate fail\n");
        res = PPA_FAILURE;
    }

    return res;
}

int32_t ppa_ioctl_reset_qos_rate(unsigned int cmd, unsigned long arg, PPA_CMD_DATA * cmd_info)
{ /*note, arg is a pointer from ioctl, not normally pointer  */
    int res = PPA_FAILURE;
    
    memset(&cmd_info->qos_rate_info, 0, sizeof(cmd_info->qos_rate_info) );

    if (copy_from_user( &cmd_info->qos_rate_info, (void *)arg, sizeof(cmd_info->qos_rate_info)) != 0 )
        return PPA_FAILURE;

    res = ppa_reset_qos_rate(cmd_info->qos_rate_info.portid, cmd_info->qos_rate_info.queueid, cmd_info->qos_rate_info.flags);
    if ( res != PPA_SUCCESS )
    {
        ppa_debug(DBG_ENABLE_MASK_QOS, "ppa_reset_rate fail\n");
        res = PPA_FAILURE;
    }

    return res;   
}

int32_t ppa_ioctl_get_qos_rate(unsigned int cmd, unsigned long arg, PPA_CMD_DATA * cmd_info)
{ /*note, arg is a pointer from ioctl, not normally pointer  */
    int res = PPA_FAILURE;
        
    memset(&cmd_info->qos_rate_info, 0, sizeof(cmd_info->qos_rate_info) );

    if (copy_from_user( &cmd_info->qos_rate_info, (void *)arg, sizeof(cmd_info->qos_rate_info)) != 0 )
        return PPA_FAILURE;

    res = ppa_get_qos_rate(cmd_info->qos_rate_info.portid, cmd_info->qos_rate_info.queueid, &cmd_info->qos_rate_info.rate, &cmd_info->qos_rate_info.burst, cmd_info->qos_rate_info.flags);
    if ( res != PPA_SUCCESS )
    {
        ppa_debug(DBG_ENABLE_MASK_QOS, "ppa_ioctl_get_qos_rate fail\n");
        res = PPA_FAILURE;
    }

    if (copy_to_user( (void *)arg, &cmd_info->qos_rate_info, sizeof(cmd_info->qos_rate_info)) != 0 )
        return PPA_FAILURE;

    return res;
}


EXPORT_SYMBOL(ppa_set_ctrl_qos_rate);
EXPORT_SYMBOL(ppa_get_ctrl_qos_rate);
EXPORT_SYMBOL(ppa_set_qos_rate);
EXPORT_SYMBOL(ppa_get_qos_rate);
EXPORT_SYMBOL(ppa_reset_qos_rate);
EXPORT_SYMBOL(ppa_ioctl_set_ctrl_qos_rate);
EXPORT_SYMBOL(ppa_ioctl_get_ctrl_qos_rate);
EXPORT_SYMBOL(ppa_ioctl_set_qos_rate);
EXPORT_SYMBOL(ppa_ioctl_reset_qos_rate);
EXPORT_SYMBOL(ppa_ioctl_get_qos_rate);
#endif  //end of CONFIG_LTQ_PPA_QOS_RATE_SHAPING

EXPORT_SYMBOL(ppa_get_qos_qnum);
EXPORT_SYMBOL(ppa_ioctl_get_qos_qnum);
EXPORT_SYMBOL(ppa_get_qos_mib);
EXPORT_SYMBOL(ppa_ioctl_get_qos_mib);
#endif  //end of CONFIG_LTQ_PPA_QOS


static int ppa_dev_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
{
    int res = 0;
    PPA_CMD_DATA *cmd_info;

    if ( in_atomic() || in_interrupt() )
      cmd_info = kmalloc(sizeof(PPA_CMD_DATA),GFP_ATOMIC);
    else
      cmd_info = kmalloc(sizeof(PPA_CMD_DATA),GFP_KERNEL);

    if ( cmd_info == NULL )
        return -EFAULT;

    if (_IOC_TYPE(cmd) != PPA_IOC_MAGIC )
    {
        printk("ppa_ioc_type(%08X - %d) != PPA_IOC_MAGIC(%d)\n", cmd, _IOC_TYPE(cmd), PPA_IOC_MAGIC);
        goto EXIT_EIO;
    }
    else if(_IOC_NR(cmd) >= PPA_IOC_MAXNR )
    {
        printk("Current cmd is %02x wrong, it should less than %02x\n", _IOC_NR(cmd), PPA_IOC_MAXNR );
        goto EXIT_EIO;
    }

    if ( ((_IOC_DIR(cmd) & _IOC_READ) && !access_ok(VERIFY_WRITE, arg, _IOC_SIZE(cmd)))
        || ((_IOC_DIR(cmd) & _IOC_WRITE) && !access_ok(VERIFY_READ, arg, _IOC_SIZE(cmd))) )
    {
        printk("access check: (%08X && %d) || (%08X && %d)\n", (_IOC_DIR(cmd) & _IOC_READ), (int)!access_ok(ppa_ioc_verify_write(), arg, _IOC_SIZE(cmd)),
                                                               (_IOC_DIR(cmd) & _IOC_WRITE), (int)!access_ok(ppa_ioc_verify_read(), arg, _IOC_SIZE(cmd)));
        goto EXIT_EFAULT;
    }
#ifdef MURALI //TODO: Check
    if( need_checking_ppa_status_cmd(cmd))
    {
        if( !ppa_is_init())
        {
            goto EXIT_EFAULT;
        }
    }
#endif

    switch ( cmd )
    {
#ifdef CONFIG_LTQ_PPA_QOS
    case PPA_CMD_GET_QOS_STATUS:
    {
        res = ppa_ioctl_get_qos_status(cmd, arg, cmd_info );
        break;
    }
    case PPA_CMD_GET_QOS_QUEUE_MAX_NUM:
    {
        res = ppa_ioctl_get_qos_qnum(cmd, arg, cmd_info );
        break;
    }
    case PPA_CMD_GET_QOS_MIB:
    {
        res = ppa_ioctl_get_qos_mib(cmd, arg, cmd_info );
        break;
    }
#ifdef CONFIG_LTQ_PPA_QOS_WFQ
    case PPA_CMD_SET_CTRL_QOS_WFQ:
    {
        res = ppa_ioctl_set_ctrl_qos_wfq(cmd, arg, cmd_info );
        break;
    }
    case PPA_CMD_GET_CTRL_QOS_WFQ:
    {
        res = ppa_ioctl_get_ctrl_qos_wfq(cmd, arg, cmd_info );
        break;
    }
    case PPA_CMD_SET_QOS_WFQ:
    {
        res = ppa_ioctl_set_qos_wfq(cmd, arg, cmd_info );
        break;
    }
    case PPA_CMD_RESET_QOS_WFQ:
    {
        res = ppa_ioctl_reset_qos_wfq(cmd, arg, cmd_info );
        break;
    }
    case PPA_CMD_GET_QOS_WFQ:
    {
        res = ppa_ioctl_get_qos_wfq(cmd, arg, cmd_info );
        break;
    }
#endif //end of CONFIG_LTQ_PPA_QOS_WFQ
#ifdef CONFIG_LTQ_PPA_QOS_RATE_SHAPING
    case PPA_CMD_SET_CTRL_QOS_RATE:
    {
        res = ppa_ioctl_set_ctrl_qos_rate(cmd, arg, cmd_info );
        break;
    }
    case PPA_CMD_GET_CTRL_QOS_RATE:
    {
        res = ppa_ioctl_get_ctrl_qos_rate(cmd, arg, cmd_info );
        break;
    }
    case PPA_CMD_SET_QOS_RATE:
    {
        res = ppa_ioctl_set_qos_rate(cmd, arg, cmd_info );
        break;
    }
    case PPA_CMD_RESET_QOS_RATE:
    {
        res = ppa_ioctl_reset_qos_rate(cmd, arg, cmd_info );
        break;
    }
    case PPA_CMD_GET_QOS_RATE:
    {
        res = ppa_ioctl_get_qos_rate(cmd, arg, cmd_info );
        break;
    }
#endif //end of CONFIG_LTQ_PPA_QOS_RATE_SHAPING
  }

#endif //end of CONFIG_LTQ_PPA_QOS
    if ( res != PPA_SUCCESS )
    {
        goto EXIT_EIO;
    }
    else
        goto EXIT_ZERO;

EXIT_EIO:
    res = -EIO;
    goto EXIT_LAST;
EXIT_EFAULT:
    res = -EFAULT;
    goto EXIT_LAST;
EXIT_ZERO:
    res = 0;
    goto EXIT_LAST;
EXIT_LAST:
    if( cmd_info )
        kfree(cmd_info);
    return res;
}

/*
 * ####################################
 *            Local Function
 * ####################################
 */

/*
 *  file operation functions
 */

static int ppa_dev_open(struct inode *inode, struct file *file)
{
    return 0;
}

static int ppa_dev_release(struct inode *inode, struct file *file)
{
    return 0;
}


static struct file_operations g_ppa_dev_ops = {
    owner:      THIS_MODULE,
#if LINUX_VERSION_CODE < KERNEL_VERSION(2,6,36)
    ioctl:      ppa_dev_ioctl,
#else
    unlocked_ioctl:      ppa_dev_ioctl,
#endif
    open:       ppa_dev_open,
    release:    ppa_dev_release
};


int __init ppa_driver_init(void)
{
    int ret;
    ret = register_chrdev(PPA_CHR_DEV_MAJOR, PPA_DEV_NAME, &g_ppa_dev_ops);
    if ( ret != 0 )
        printk("PPA API --- failed in register_chrdev(%d, %s, g_ppa_dev_ops), errno = %d\n", PPA_CHR_DEV_MAJOR, PPA_DEV_NAME, ret);
		else {
#ifdef CONFIG_LTQ_PPA_QOS_RATE_SHAPING
    	if( ppa_drv_init_qos_rate(0) != PPA_SUCCESS ){
     	   ppa_debug(DBG_ENABLE_MASK_DEBUG_PRINT,"ppa_drv_init_qos_rate  fail\n");
    	}
#endif /* CONFIG_LTQ_PPA_QOS_RATE_SHAPING */

#ifdef CONFIG_LTQ_PPA_QOS_WFQ
    	if( ppa_drv_init_qos_wfq(0) != PPA_SUCCESS ){
     	   ppa_debug(DBG_ENABLE_MASK_DEBUG_PRINT,"ppa_drv_init_qos_wfq  fail\n");
    	}
#endif /* CONFIG_LTQ_PPA_QOS_WFQ */
		}
    return ret;
}

void __exit ppa_driver_exit(void)
{
  unregister_chrdev(PPA_CHR_DEV_MAJOR, PPA_DEV_NAME);
}


