/******************************************************************************
**
** FILE NAME    : ppe_drv_wrapper.h
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
** $Date        $Author         $Comment
** 14 MAR 2011  Shao Guohua       Initiate Version
*******************************************************************************/
#ifndef PPA_PPE_DRV_WRAPPER_2011_03_14
#define PPA_PPE_DRV_WRAPPER_2011_03_14

#ifdef CONFIG_LTQ_PPA_QOS
extern uint32_t ppa_drv_get_qos_status( PPA_QOS_STATUS *status, uint32_t flag);
extern uint32_t ppa_drv_get_qos_qnum( PPE_QOS_COUNT_CFG *count, uint32_t flag);
extern uint32_t ppa_drv_get_qos_mib( PPE_QOS_MIB_INFO *mib, uint32_t flag);
#ifdef CONFIG_LTQ_PPA_QOS_RATE_SHAPING
extern uint32_t ppa_drv_set_ctrl_qos_rate(PPE_QOS_ENABLE_CFG *enable_cfg, uint32_t flag);
extern uint32_t ppa_drv_get_ctrl_qos_rate(PPE_QOS_ENABLE_CFG *enable_cfg, uint32_t flag);
extern uint32_t ppa_drv_set_qos_rate( PPE_QOS_RATE_SHAPING_CFG *cfg , uint32_t flag);
extern uint32_t ppa_drv_get_qos_rate( PPE_QOS_RATE_SHAPING_CFG *cfg , uint32_t flag);
extern uint32_t ppa_drv_reset_qos_rate( PPE_QOS_RATE_SHAPING_CFG *cfg , uint32_t flag);
extern uint32_t ppa_drv_init_qos_rate(uint32_t flag);
#endif
#ifdef CONFIG_LTQ_PPA_QOS_WFQ
extern uint32_t ppa_drv_set_ctrl_qos_wfq(PPE_QOS_ENABLE_CFG *enable_cfg, uint32_t flag);
extern uint32_t ppa_drv_get_ctrl_qos_wfq(PPE_QOS_ENABLE_CFG *enable_cfg, uint32_t flag);
extern uint32_t ppa_drv_set_qos_wfq( PPE_QOS_WFQ_CFG *cfg, uint32_t flag);
extern uint32_t ppa_drv_get_qos_wfq( PPE_QOS_WFQ_CFG *cfg, uint32_t flag);
extern uint32_t ppa_drv_reset_qos_wfq( PPE_QOS_WFQ_CFG *cfg, uint32_t flag);
extern uint32_t ppa_drv_init_qos_wfq( uint32_t flag);
#endif
#endif

#endif //end of PPA_PPE_DRV_WRAPPER_2011_03_14


