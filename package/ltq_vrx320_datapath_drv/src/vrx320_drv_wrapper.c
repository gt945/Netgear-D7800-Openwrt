/******************************************************************************
**
** FILE NAME    : ppe_drv_wrapper.c
** PROJECT      : PPA
** MODULES      : PPA Wrapper for PPE Driver API
**
** DATE         : 14 Mar 2011
** AUTHOR       : Shao Guohua
** DESCRIPTION  : PPA Wrapper for PPE Driver API
** COPYRIGHT    :              Copyright (c) 2009
**                          Lantiq Deutschland GmbH
**                   Am Campeon 3; 85579 Neubiberg, Germany
**
**   For licensing information, see the file 'LICENSE' in the root folder of
**   this software module.
**
** HISTORY
** $Date        $Author                $Comment
** 14 MAR 2011  Shao Guohua            Initiate Version
** 10 DEC 2012  Manamohan Shetty       Added the support for RTP,MIB mode and CAPWAP 
**                                     Features 
*******************************************************************************/

/*
 * ####################################
 *              Head File
 * ####################################
 */

/*
 *  Common Head File
 */
//#include <linux/autoconf.h>
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
 *  Chip Specific Head File
 */
#include "lantiq_wrapper.h"
#include "vrx320_api_qos.h"
#include "vrx320_drv_wrapper.h"

/*Hook API for PPE Driver's HAL layer: these hook will be set in PPE HAL driver */
int32_t (*ppa_drv_hal_generic_hook)(PPA_GENERIC_HOOK_CMD cmd, void *buffer, uint32_t flag)=NULL;

//#ifdef CONFIG_LTQ_PPA_QOS
uint32_t ppa_drv_get_qos_qnum( PPE_QOS_COUNT_CFG *count, uint32_t flag)
{
     if( !ppa_drv_hal_generic_hook ) {
			printk("[%s:%d] ppa_drv_hal_generic_hook is not set\n", __func__, __LINE__);
			return PPA_FAILURE;
		 }

    return ppa_drv_hal_generic_hook(PPA_GENERIC_HAL_GET_QOS_QUEUE_NUM, (void *)count, flag );
}

uint32_t ppa_drv_get_qos_status( PPA_QOS_STATUS *status, uint32_t flag)
{
     if( !ppa_drv_hal_generic_hook ) return PPA_FAILURE;

    return ppa_drv_hal_generic_hook(PPA_GENERIC_HAL_GET_QOS_STATUS, (void *)status, flag );
}


uint32_t ppa_drv_get_qos_mib( PPE_QOS_MIB_INFO *mib, uint32_t flag)
{
     if( !ppa_drv_hal_generic_hook ) return PPA_FAILURE;

    return ppa_drv_hal_generic_hook(PPA_GENERIC_HAL_GET_QOS_MIB, (void *)mib, flag );
}

//#ifdef CONFIG_LTQ_PPA_QOS_RATE_SHAPING
uint32_t ppa_drv_set_ctrl_qos_rate(PPE_QOS_ENABLE_CFG *enable_cfg, uint32_t flag)
{
     if( !ppa_drv_hal_generic_hook ) return PPA_FAILURE;

    return ppa_drv_hal_generic_hook(PPA_GENERIC_HAL_SET_QOS_RATE_SHAPING_CTRL, (void *)enable_cfg, flag );
}
uint32_t ppa_drv_get_ctrl_qos_rate(PPE_QOS_ENABLE_CFG *enable_cfg, uint32_t flag)
{
     if( !ppa_drv_hal_generic_hook ) return PPA_FAILURE;

    return ppa_drv_hal_generic_hook(PPA_GENERIC_HAL_GET_QOS_RATE_SHAPING_CTRL, (void *)enable_cfg, flag );
}

uint32_t ppa_drv_set_qos_rate( PPE_QOS_RATE_SHAPING_CFG *cfg, uint32_t flag )
{
     if( !ppa_drv_hal_generic_hook ) return PPA_FAILURE;

    return ppa_drv_hal_generic_hook(PPA_GENERIC_HAL_SET_QOS_RATE_SHAPING_CFG, (void *)cfg, flag );
}

uint32_t ppa_drv_get_qos_rate( PPE_QOS_RATE_SHAPING_CFG *cfg, uint32_t flag )
{
     if( !ppa_drv_hal_generic_hook ) return PPA_FAILURE;

    return ppa_drv_hal_generic_hook(PPA_GENERIC_HAL_GET_QOS_RATE_SHAPING_CFG, (void *)cfg, flag );
}

uint32_t ppa_drv_reset_qos_rate( PPE_QOS_RATE_SHAPING_CFG *cfg , uint32_t flag)
{
     if( !ppa_drv_hal_generic_hook ) return PPA_FAILURE;

    return ppa_drv_hal_generic_hook(PPA_GENERIC_HAL_RESET_QOS_RATE_SHAPING_CFG, (void *)cfg, flag );
}

uint32_t ppa_drv_init_qos_rate(uint32_t flag)
{
    if( !ppa_drv_hal_generic_hook ) return PPA_FAILURE;

    return ppa_drv_hal_generic_hook(PPA_GENERIC_HAL_INIT_QOS_RATE_SHAPING, (void *)NULL, flag );
}
//#endif  //end of CONFIG_LTQ_PPA_QOS_RATE_SHAPING

//#ifdef CONFIG_LTQ_PPA_QOS_WFQ
uint32_t ppa_drv_set_ctrl_qos_wfq(PPE_QOS_ENABLE_CFG *enable_cfg, uint32_t flag)
{
     if( !ppa_drv_hal_generic_hook ) return PPA_FAILURE;

    return ppa_drv_hal_generic_hook(PPA_GENERIC_HAL_SET_QOS_WFQ_CTRL, (void *)enable_cfg, flag );
}

uint32_t ppa_drv_get_ctrl_qos_wfq(PPE_QOS_ENABLE_CFG *enable_cfg, uint32_t flag)
{
     if( !ppa_drv_hal_generic_hook ) return PPA_FAILURE;

    return ppa_drv_hal_generic_hook(PPA_GENERIC_HAL_GET_QOS_WFQ_CTRL, (void *)enable_cfg, flag );
}

uint32_t ppa_drv_set_qos_wfq( PPE_QOS_WFQ_CFG *cfg, uint32_t flag)
{
     if( !ppa_drv_hal_generic_hook ) return PPA_FAILURE;

    return ppa_drv_hal_generic_hook(PPA_GENERIC_HAL_SET_QOS_WFQ_CFG, (void *)cfg, flag );
}
uint32_t ppa_drv_get_qos_wfq( PPE_QOS_WFQ_CFG *cfg, uint32_t flag)
{
     if( !ppa_drv_hal_generic_hook ) return PPA_FAILURE;

    return ppa_drv_hal_generic_hook(PPA_GENERIC_HAL_GET_QOS_WFQ_CFG, (void *)cfg, flag );
}

uint32_t ppa_drv_reset_qos_wfq( PPE_QOS_WFQ_CFG *cfg, uint32_t flag)
{
     if( !ppa_drv_hal_generic_hook ) return PPA_FAILURE;

    return ppa_drv_hal_generic_hook(PPA_GENERIC_HAL_RESET_QOS_WFQ_CFG, (void *)cfg, flag );
}
uint32_t ppa_drv_init_qos_wfq(uint32_t flag)
{
     if( !ppa_drv_hal_generic_hook ) return PPA_FAILURE;

    return ppa_drv_hal_generic_hook(PPA_GENERIC_HAL_INIT_QOS_WFQ, (void *)NULL, flag );
}
//#endif  //end of CONFIG_LTQ_PPA_QOS_WFQ
//#endif  //end of CONFIG_LTQ_PPA_QOS


EXPORT_SYMBOL( ppa_drv_get_qos_rate);
EXPORT_SYMBOL(ppa_drv_reset_qos_rate);
EXPORT_SYMBOL( ppa_drv_set_ctrl_qos_rate);
EXPORT_SYMBOL(ppa_drv_get_qos_status);
EXPORT_SYMBOL(ppa_drv_get_qos_qnum);
EXPORT_SYMBOL( ppa_drv_init_qos_rate);
EXPORT_SYMBOL( ppa_drv_init_qos_wfq);
EXPORT_SYMBOL( ppa_drv_reset_qos_wfq);
EXPORT_SYMBOL( ppa_drv_get_qos_wfq);
EXPORT_SYMBOL( ppa_drv_set_ctrl_qos_wfq);

