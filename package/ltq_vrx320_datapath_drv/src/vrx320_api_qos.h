#ifndef __PPA_API_MFE_H__20100427_1703
#define __PPA_API_MFE_H__20100427_1703
/*******************************************************************************
**
** FILE NAME    : ppa_api_qos.h
** PROJECT      : PPA
** MODULES      : PPA API ( PPA QOS  APIs)
**
** DATE         : 27 April 2010
** AUTHOR       : Shao Guohua
** DESCRIPTION  : PPA QOS APIs 
**                File
** COPYRIGHT    :              Copyright (c) 2009
**                          Lantiq Deutschland GmbH
**                   Am Campeon 3; 85579 Neubiberg, Germany
**
**   For licensing information, see the file 'LICENSE' in the root folder of
**   this software module.
**
** HISTORY
** $Date                $Author         $Comment
** 16 Dec 2009  Shao Guohua             Initiate Version
*******************************************************************************/

/*! \file ppa_api_qos.h
    \brief This file contains es.
           provide PPA power management API.
*/

/** \addtogroup  PPA_API_QOS */
/*@{*/



/*
 * ####################################
 *              Definition
 * ####################################
 */
#define WRAPROUND_32BITS  ((uint64_t)0xFFFFFFFF)

/*!
    \brief PPA_MAX_PORT_NUM
*/
#define PPA_MAX_PORT_NUM                            16   /*!< Maximum PPE FW Port number supported in PPA layer. */

/*!
    \brief PPA_MAX_QOS_QUEUE_NUM
*/
#define PPA_MAX_QOS_QUEUE_NUM                       16   /*!< Maximum PPE FW QoS Queue number supported in PPA layer for one port. */

/*!
    \brief PPA_IOC_MAGIC
*/
#define PPA_IOC_MAGIC                           ((uint32_t)'p') /*!< Magic number to differentiate PPA ioctl commands */


#if 0
/*
 *  Debug Print Mask
 *  Note, once you add a new DBG_ macro, don't forget to add it in DBG_ENABLE_MASK_ALL also !!!!
 */
#define DBG_ENABLE_MASK_ERR                     (1 << 0)
#define DBG_ENABLE_MASK_ASSERT                  (1 << 1)
#define DBG_ENABLE_MASK_DEBUG_PRINT             (1 << 2)
#define DBG_ENABLE_MASK_DUMP_ROUTING_SESSION    (1 << 4)
#define DBG_ENABLE_MASK_DUMP_MC_GROUP           (1 << 5)
#define DBG_ENABLE_MASK_DUMP_BRIDGING_SESSION   (1 << 6)
#define DBG_ENABLE_MASK_DUMP_SKB_RX             (1 << 8)
#define DBG_ENABLE_MASK_DUMP_SKB_TX             (1 << 9)
#define DBG_ENABLE_MASK_DUMP_FLAG_HEADER        (1 << 10)
#define DBG_ENABLE_MASK_DUMP_INIT               (1 << 11)
#define DBG_ENABLE_MASK_QOS                     (1 << 12)
#define DBG_ENABLE_MASK_PWM                     (1 << 13)
#define DBG_ENABLE_MASK_MFE                     (1 << 14)
#define DBG_ENABLE_MASK_PRI_TEST                (1 << 15)
#define DBG_ENABLE_MASK_SESSION                 (1 << 16)
#define DBG_ENABLE_MASK_DEBUG2_PRINT            (1 << 17)
#define DBG_ENABLE_MASK_MARK_TEST               (1 << 18)
#define DBG_ENABLE_MASK_DUMP_CAPWAP_GROUP       (1 << 19)

#define DBG_ENABLE_MASK_ALL                     (DBG_ENABLE_MASK_ERR | DBG_ENABLE_MASK_DEBUG_PRINT | DBG_ENABLE_MASK_ASSERT \
                                                | DBG_ENABLE_MASK_DUMP_ROUTING_SESSION | DBG_ENABLE_MASK_DUMP_MC_GROUP      \
                                                | DBG_ENABLE_MASK_DUMP_BRIDGING_SESSION                                     \
                                                | DBG_ENABLE_MASK_DUMP_SKB_RX | DBG_ENABLE_MASK_DUMP_SKB_TX                 \
                                                | DBG_ENABLE_MASK_DUMP_FLAG_HEADER | DBG_ENABLE_MASK_DUMP_INIT              \
                                                | DBG_ENABLE_MASK_QOS | DBG_ENABLE_MASK_PWM | DBG_ENABLE_MASK_MFE           \
												| DBG_ENABLE_MASK_PRI_TEST | DBG_ENABLE_MASK_SESSION | DBG_ENABLE_MASK_DEBUG2_PRINT)

/*
 *  helper macro
 */
#define NUM_ENTITY(x)                           (sizeof(x) / sizeof(*(x)))

/*ppa_debug currently supported flags:
        DBG_ENABLE_MASK_ERR,
        DBG_ENABLE_MASK_DEBUG_PRINT,
        DBG_ENABLE_MASK_ASSERT,
        DBG_ENABLE_MASK_DUMP_ROUTING_SESSION,
        DBG_ENABLE_MASK_DUMP_MC_GROUP,
        DBG_ENABLE_MASK_DUMP_BRIDGING_SESSION,
        DBG_ENABLE_MASK_DUMP_INIT,
        DBG_ENABLE_MASK_QOS,
        DBG_ENABLE_MASK_PWM,
		DBG_ENABLE_MASK_SESSION,
 DBG_ENABLE_MASK_ALL*/
#endif

#if defined(ENABLE_DEBUG_PRINT) && ENABLE_DEBUG_PRINT        
    #undef ppa_debug    
    //#define ppa_debug(flag, fmt, arg...)  do { if ( (g_ppa_dbg_enable & flag) && max_print_num ) { ppa_printk(/*__FILE__*/ ":%d:%s: " fmt, __LINE__, __FUNCTION__, ##arg); if(max_print_num) max_print_num--; } } while ( 0 )
    #define ppa_debug(flag, fmt, arg...)  do { if ( (g_ppa_dbg_enable & flag) && max_print_num ) { printk(KERN_ERR fmt, ##arg); if( max_print_num != ~0) max_print_num--; } } while ( 0 )
#else
    #undef ppa_debug
    #define ppa_debug(flag, fmt, arg...) 
#endif

/* -------------------------------------------------------------------------- */
/*                        IOCTL Command Definitions                           */
/* -------------------------------------------------------------------------- */
/** \addtogroup  PPA_IOCTL */
/*@{*/

/**  PPA IOCTL NR values
*/
#if 0
typedef enum {
PPA_CMD_GET_QOS_QUEUE_MAX_NUM_NR,         /*!< NR for PPA_CMD_GET_QOS_QUEUE_MAX_NUM  */
PPA_CMD_SET_QOS_WFQ_NR,                   /*!< NR for PPA_CMD_SET_QOS_WFQ  */
PPA_CMD_GET_QOS_WFQ_NR,                   /*!< NR for PPA_CMD_SET_QOS_WFQ  */
PPA_CMD_RESET_QOS_WFQ_NR,                 /*!< NR for PPA_CMD_GET_QOS_WFQ  */
PPA_CMD_SET_CTRL_QOS_WFQ_NR,              /*!< NR for PPA_CMD_SET_CTRL_QOS_WFQ  */
PPA_CMD_GET_CTRL_QOS_WFQ_NR,              /*!< NR for  PPA_CMD_GET_CTRL_QOS_WFQ */
PPA_CMD_SET_CTRL_QOS_RATE_NR,             /*!< NR for PPA_CMD_SET_CTRL_QOS_RATE   */
PPA_CMD_GET_CTRL_QOS_RATE_NR,             /*!< NR for PPA_CMD_GET_CTRL_QOS_RATE  */
PPA_CMD_SET_QOS_RATE_NR,                  /*!< NR for PPA_CMD_SET_QOS_RATE  */
PPA_CMD_GET_QOS_RATE_NR,                  /*!< NR for PPA_CMD_GET_QOS_RATE  */
PPA_CMD_RESET_QOS_RATE_NR,                /*!< NR for PPA_CMD_RESET_QOS_RATE  */
PPA_CMD_GET_QOS_MIB_NR,                   /*!< NR for PPA_CMD_GET_QOS_MIB  */
PPA_CMD_GET_QOS_STATUS_NR,                       /*!< NR for PPA_CMD_GET_QOS_STATUS  */
/*  PPA_IOC_MAXNR should be the last one in the enumberation */
PPA_IOC_MAXNR                            /*!< NR for PPA_IOC_MAXNR  */
}PPA_IOC_NR;
#else
typedef enum {
PPA_CMD_INIT_NR=0,             /*!< NR for PPA_CMD_INI  */
PPA_CMD_EXIT_NR,               /*!< NR for PPA_CMD_EXIT  */
PPA_CMD_ENABLE_NR,             /*!< NR for PPA_CMD_ENABLE  */  
PPA_CMD_GET_STATUS_NR,         /*!< NR for PPA_CMD_GET_STATUS  */
PPA_CMD_MODIFY_MC_ENTRY_NR,    /*!< NR for PPA_CMD_MODIFY_MC_ENTRY  */
PPA_CMD_GET_MC_ENTRY_NR,       /*!< NR for  PPA_CMD_GET_MC_ENTRY */ 
PPA_CMD_ADD_MAC_ENTRY_NR,      /*!< NR for PPA_CMD_ADD_MAC_ENTRY  */
PPA_CMD_DEL_MAC_ENTRY_NR,      /*!< NR for  PPA_CMD_DEL_MAC_ENTRY */
PPA_CMD_SET_VLAN_IF_CFG_NR,    /*!< NR for PPA_CMD_SET_VLAN_IF_CFG  */
PPA_CMD_GET_VLAN_IF_CFG_NR,    /*!< NR for PPA_CMD_GET_VLAN_IF_CFG  */
PPA_CMD_ADD_VLAN_FILTER_CFG_NR,         /*!< NR for PPA_CMD_ADD_VLAN_FILTER_CFG  */
PPA_CMD_DEL_VLAN_FILTER_CFG_NR,         /*!< NR for PPA_CMD_DEL_VLAN_FILTER_CFG  */
PPA_CMD_GET_ALL_VLAN_FILTER_CFG_NR,     /*!< NR for PPA_CMD_GET_ALL_VLAN_FILTER_CFG  */
PPA_CMD_DEL_ALL_VLAN_FILTER_CFG_NR,     /*!< NR for PPA_CMD_DEL_ALL_VLAN_FILTER_CFG  */
PPA_CMD_SET_IF_MAC_NR,   /*!< NR for PPA_CMD_SET_IF_MAC  */
PPA_CMD_GET_IF_MAC_NR,   /*!< NR for PPA_CMD_GET_IF_MAC */ 
PPA_CMD_ADD_LAN_IF_NR,   /*!< NR for PPA_CMD_ADD_LAN_IF   */
PPA_CMD_ADD_WAN_IF_NR,   /*!< NR for PPA_CMD_ADD_WAN_IF   */
PPA_CMD_DEL_LAN_IF_NR,   /*!< NR for PPA_CMD_DEL_LAN_IF  */
PPA_CMD_DEL_WAN_IF_NR,   /*!< NR for PPA_CMD_DEL_WAN_IF   */
PPA_CMD_GET_LAN_IF_NR,   /*!< NR for PPA_CMD_GET_LAN_IF  */
PPA_CMD_GET_WAN_IF_NR,   /*!< NR for  PPA_CMD_GET_WAN_IF */
PPA_CMD_ADD_MC_NR,       /*!< NR for  PPA_CMD_ADD_MC */
PPA_CMD_GET_MC_GROUPS_NR,           /*!< NR for PPA_CMD_GET_MC_GROUPS  */
PPA_CMD_GET_COUNT_LAN_SESSION_NR,   /*!< NR for  PPA_CMD_GET_COUNT_LAN_SESSION */
PPA_CMD_GET_COUNT_WAN_SESSION_NR,   /*!< NR for  PPA_CMD_GET_COUNT_WAN_SESSION */
PPA_CMD_GET_COUNT_NONE_LAN_WAN_SESSION_NR, /*!< NR for  PPA_CMD_GET_COUNT_NONE_LAN_WAN_SESSION_NR */
PPA_CMD_GET_COUNT_LAN_WAN_SESSION_NR,   /*!< NR for  PPA_CMD_GET_COUNT_LAN_WAN_SESSION */
PPA_CMD_GET_COUNT_MC_GROUP_NR,      /*!< NR for PPA_CMD_GET_COUNT_MC_GROUP  */
PPA_CMD_GET_COUNT_VLAN_FILTER_NR,   /*!< NR for PPA_CMD_GET_COUNT_VLAN_FILTER  */
PPA_CMD_GET_LAN_SESSIONS_NR,        /*!< NR for PPA_CMD_GET_LAN_SESSIONS  */  
PPA_CMD_GET_WAN_SESSIONS_NR,        /*!< NR for PPA_CMD_GET_WAN_SESSIONS  */
PPA_CMD_GET_LAN_WAN_SESSIONS_NR,        /*!< NR for PPA_CMD_GET_WAN_SESSIONS  */
PPA_CMD_GET_VERSION_NR,             /*!< NR for PPA_CMD_GET_VERSION  */
PPA_CMD_GET_COUNT_MAC_NR,           /*!< NR for PPA_CMD_GET_COUNT_MAC  */ 
PPA_CMD_GET_ALL_MAC_NR,             /*!< NR for PPA_CMD_GET_ALL_MAC  */
PPA_CMD_WAN_MII0_VLAN_RANGE_ADD_NR,       /*!< NR for PPA_CMD_WAN_MII0_VLAN_RANGE_ADD  */
PPA_CMD_WAN_MII0_VLAN_RANGE_GET_NR,       /*!< NR for PPA_CMD_WAN_MII0_VLAN_RANGE_GET  */
PPA_CMD_GET_COUNT_WAN_MII0_VLAN_RANGE_NR, /*!< NR for PPA_CMD_GET_COUNT_WAN_MII0_VLAN_RANGE  */
PPA_CMD_GET_SIZE_NR,                      /*!< NR for PPA_CMD_GET_SIZE   */
PPA_CMD_BRIDGE_ENABLE_NR,                 /*!< NR for PPA_CMD_BRIDGE_ENABLE  */
PPA_CMD_GET_BRIDGE_STATUS_NR,             /*!< NR for PPA_CMD_GET_BRIDGE_STATUS  */
PPA_CMD_GET_QOS_QUEUE_MAX_NUM_NR,         /*!< NR for PPA_CMD_GET_QOS_QUEUE_MAX_NUM  */
PPA_CMD_SET_QOS_WFQ_NR,                   /*!< NR for PPA_CMD_SET_QOS_WFQ  */
PPA_CMD_GET_QOS_WFQ_NR,                   /*!< NR for PPA_CMD_SET_QOS_WFQ  */
PPA_CMD_RESET_QOS_WFQ_NR,                 /*!< NR for PPA_CMD_GET_QOS_WFQ  */
PPA_CMD_ENABLE_MULTIFIELD_NR,             /*!< NR for PPA_CMD_ENABLE_MULTIFIELD  */
PPA_CMD_GET_MULTIFIELD_STATUS_NR,         /*!< NR for PPA_CMD_GET_MULTIFIELD_STATUS  */
PPA_CMD_GET_MULTIFIELD_ENTRY_MAX_NR,      /*!< NR for PPA_CMD_GET_MULTIFIELD_ENTRY_MAX  */
PPA_CMD_GET_MULTIFIELD_KEY_NUM_NR,        /*!< NR for  PPA_CMD_GET_MULTIFIELD_KEY_NUM */
PPA_CMD_ADD_MULTIFIELD_NR,                /*!< NR for PPA_CMD_ADD_MULTIFIELD  */
PPA_CMD_GET_MULTIFIELD_NR,                /*!< NR for  PPA_CMD_GET_MULTIFIELD */
PPA_CMD_DEL_MULTIFIELD_NR,                /*!< NR for PPA_CMD_DEL_MULTIFIELD  */
PPA_CMD_DEL_MULTIFIELD_VIA_INDEX_NR,      /*!< NR for PPA_CMD_DEL_MULTIFIELD_VIA_INDEX  */ 
PPA_CMD_GET_HOOK_COUNT_NR,                /*!< NR for PPA_CMD_GET_HOOK_COUNT  */
PPA_CMD_GET_HOOK_LIST_NR,                 /*!< NR for PPA_CMD_GET_HOOK_LIST  */   
PPA_CMD_SET_HOOK_NR,                      /*!< NR for PPA_CMD_SET_HOOK   */ 
PPA_CMD_READ_MEM_NR,                      /*!< NR for  PPA_CMD_SET_MEM */
PPA_CMD_SET_MEM_NR,                       /*!< NR for PPA_CMD_SET_MEM  */
PPA_CMD_SET_CTRL_QOS_WFQ_NR,              /*!< NR for PPA_CMD_SET_CTRL_QOS_WFQ  */
PPA_CMD_GET_CTRL_QOS_WFQ_NR,              /*!< NR for  PPA_CMD_GET_CTRL_QOS_WFQ */
PPA_CMD_SET_CTRL_QOS_RATE_NR,             /*!< NR for PPA_CMD_SET_CTRL_QOS_RATE   */
PPA_CMD_GET_CTRL_QOS_RATE_NR,             /*!< NR for PPA_CMD_GET_CTRL_QOS_RATE  */
PPA_CMD_SET_QOS_RATE_NR,                  /*!< NR for PPA_CMD_SET_QOS_RATE  */ 
PPA_CMD_GET_QOS_RATE_NR,                  /*!< NR for PPA_CMD_GET_QOS_RATE  */ 
PPA_CMD_RESET_QOS_RATE_NR,                /*!< NR for PPA_CMD_RESET_QOS_RATE  */
PPA_CMD_GET_QOS_MIB_NR,                   /*!< NR for PPA_CMD_GET_QOS_MIB  */
PPA_CMD_GET_MAX_ENTRY_NR,                 /*!< NR for PPA_CMD_GET_MAX_ENTRY  */
PPA_CMD_GET_PORTID_NR,                         /*!< NR for PPA_GET_CMD_PORTID  */
PPA_CMD_GET_DSL_MIB_NR,                        /*!< NR for PPA_GET_DSL_MIB  */
PPA_CMD_CLEAR_DSL_MIB_NR,                      /*!< NR for PPA_CLEAR_DSL_MIB  */
PPA_CMD_DEL_SESSION_NR,                             /*!< NR for PPA_CMD_DEL_SESSION  */
PPA_CMD_ADD_SESSION_NR,                             /*!< NR for PPA_CMD_ADD_SESSION  */
PPA_CMD_MODIFY_SESSION_NR,                             /*!< NR for PPA_CMD_MODIFY_SESSION  */
PPA_CMD_SET_SESSION_TIMER_NR,                             /*!< NR for PPA_CMD_SET_SESSION_TIMER  */
PPA_CMD_GET_SESSION_TIMER_NR,                             /*!< NR for PPA_CMD_GET_SESSION_TIMER  */
PPA_CMD_GET_PORT_MIB_NR,                        /*!< NR for PPA_GET_PORT_MIB  */
PPA_CMD_CLEAR_PORT_MIB_NR,                      /*!< NR for PPA_CLEAR_PORT_MIB  */
PPA_CMD_SET_HAL_DBG_FLAG_NR,                    /*!< NR for PPA_CMD_SET_HAL_DBG_FLAG  */
PPA_CMD_GET_QOS_STATUS_NR,                       /*!< NR for PPA_CMD_GET_QOS_STATUS  */
PPA_CMD_GET_PPA_HASH_SUMMARY_NR,                 /*!< NR for PPA_CMD_GET_PPA_HASH_SUMMARY  */
PPA_CMD_GET_COUNT_PPA_HASH_NR,                  /*!< NR for PPA_CMD_GET_COUNT_PPA_HASH  */
PPA_CMD_DBG_TOOL_NR,                           /*!< NR for PPA_CMD_DBG_TOOL  */
PPA_CMD_SET_VALUE_NR,                           /*!< NR for PPA_CMD_SET_VALUE  */
PPA_CMD_GET_VALUE_NR,                           /*!< NR for PPA_CMD_GET_VALUE  */
PPA_CMD_SET_PPE_FASTPATH_ENABLE_NR,		/*!< NR for PPA_CMD_SET_PPE_FASTPATH_ENABLE */
PPA_CMD_GET_PPE_FASTPATH_ENABLE_NR,		/*!< NR for PPA_CMD_GET_PPE_FASTPATH_ENABLE */


#if defined(MIB_MODE_ENABLE) && MIB_MODE_ENABLE
PPA_CMD_SET_MIB_MODE_NR,      /*!< NR for  PPA_CMD_SET_MIB_MODE */ 
PPA_CMD_GET_MIB_MODE_NR,      /*!< NR for  PPA_CMD_GET_MIB_MODE */ 
#endif

#if defined(RTP_SAMPLING_ENABLE) && RTP_SAMPLING_ENABLE
PPA_CMD_SET_RTP_NR,            /*!< NR for  PPA_CMD_SET_RTP */ 
#endif

#if defined(CAP_WAP_CONFIG) && CAP_WAP_CONFIG
PPA_CMD_ADD_CAPWAP_NR,       /*!< NR for  PPA_CMD_ADD_CAPWAP */
PPA_CMD_DEL_CAPWAP_NR,       /*!< NR for  PPA_CMD_DEL_CAPWAP */
PPA_CMD_GET_CAPWAP_GROUPS_NR,/*!< NR for  PPA_CMD_GET_CAPWAP_GROUPS */
PPA_CMD_GET_COUNT_CAPWAP_NR,/*!< NR for PPA_CMD_GET_COUNT_CAPWAP_GROUP_NR */
PPA_CMD_GET_MAXCOUNT_CAPWAP_NR,/*!< NR for PPA_CMD_GET_MAXCOUNT_CAPWAP_GROUP_NR */
#endif

#if defined(CONFIG_LTQ_PPA_API_SW_FASTPATH)
PPA_CMD_SET_SW_FASTPATH_ENABLE_NR,              /*!< NR for PPA_CMD_SET_SW_FASTPATH_ENABLE */
PPA_CMD_GET_SW_FASTPATH_ENABLE_NR,              /*!< NR for PPA_CMD_GET_SW_FASTPATH_ENABLE */
#endif
#if defined(CONFIG_LTQ_PPA_HANDLE_CONNTRACK_SESSIONS)
PPA_CMD_GET_SESSIONS_CRITERIA_NR,        /*!< NR for PPA_CMD_GET_SESSIONS_CRITERIA  */  
#endif

/*  PPA_IOC_MAXNR should be the last one in the enumberation */    
PPA_IOC_MAXNR                            /*!< NR for PPA_IOC_MAXNR  */
}PPA_IOC_NR;

#endif


#ifdef CONFIG_LTQ_PPA_QOS
/** PPA GET QOS status. Value is manipulated by _IOR() macro for final value
    \param[out] PPA_CMD_QOS_STATUS_INFO The parameter points to a
                \ref PPA_CMD_QOS_STATUS_INFO structure 
*/
#define PPA_CMD_GET_QOS_STATUS  _IOR(PPA_IOC_MAGIC, PPA_CMD_GET_QOS_STATUS_NR, PPA_CMD_QOS_STATUS_INFO) 


/** PPA GET the maximum queue supported for WFQ/RateShapping. Value is manipulated by _IOR() macro for final value
    \param[out] PPA_CMD_QUEUE_NUM_INFO The parameter points to a
                \ref PPA_CMD_QUEUE_NUM_INFO structure 
    \note: portid is input parameter, and queue_num  is output value . 
*/
#define PPA_CMD_GET_QOS_QUEUE_MAX_NUM  _IOR(PPA_IOC_MAGIC, PPA_CMD_GET_QOS_QUEUE_MAX_NUM_NR, PPA_CMD_QUEUE_NUM_INFO) 

/** PPA GET the QOS mib counter. Value is manipulated by _IOR() macro for final value
    \param[out] PPA_CMD_QUEUE_NUM_INFO The parameter points to a
                \ref PPA_CMD_QUEUE_NUM_INFO structure 
    \note: portid is input parameter, and queue_num  is output value . 
*/
#define PPA_CMD_GET_QOS_MIB  _IOR(PPA_IOC_MAGIC, PPA_CMD_GET_QOS_MIB_NR, PPA_CMD_QOS_MIB_INFO) 



#ifdef CONFIG_LTQ_PPA_QOS_WFQ
/** PPA Enable/Disable QOS WFQ feature. Value is manipulated by _IOW() macro for final value
    \param[in] PPA_CMD_QOS_CTRL_INFO The parameter points to a
                            \ref PPA_CMD_QOS_CTRL_INFO structure 
*/
#define PPA_CMD_SET_CTRL_QOS_WFQ _IOW(PPA_IOC_MAGIC, PPA_CMD_SET_CTRL_QOS_WFQ_NR, PPA_CMD_QOS_CTRL_INFO) 


/** PPA get QOS WFQ feature status: enabled or disabled. Value is manipulated by _IOR() macro for final value
    \param[in] PPA_CMD_QOS_CTRL_INFO The parameter points to a
                            \ref PPA_CMD_QOS_CTRL_INFO structure 
*/
#define PPA_CMD_GET_CTRL_QOS_WFQ _IOR(PPA_IOC_MAGIC, PPA_CMD_GET_CTRL_QOS_WFQ_NR, PPA_CMD_QOS_CTRL_INFO) 

/** PPA Set WFQ weight. Value is manipulated by _IOW() macro for final value
    \param PPA_CMD_WFQ_INFO The parameter points to a
    \ref PPA_CMD_WFQ_INFO structure 
*/
#define PPA_CMD_SET_QOS_WFQ _IOW(PPA_IOC_MAGIC, PPA_CMD_SET_QOS_WFQ_NR, PPA_CMD_WFQ_INFO) 

/** PPA Get WFQ weight. Value is manipulated by _IOR() macro for final value
    \param[out] PPA_CMD_WFQ_INFO The parameter points to a
                     \ref PPA_CMD_WFQ_INFO structure 
    \note portid, queueid and weight should be set accordingly. 
*/
#define PPA_CMD_GET_QOS_WFQ _IOR(PPA_IOC_MAGIC, PPA_CMD_GET_QOS_WFQ_NR, PPA_CMD_WFQ_INFO)

/** PPA Reset WFQ weight. Value is manipulated by _IOW() macro for final value
    \param[out] PPA_CMD_WFQ_INFO The parameter points to a
                            \ref PPA_CMD_WFQ_INFO structure 
    \note: portid/queueid is input parameter, and weight is output value. 
*/
#define PPA_CMD_RESET_QOS_WFQ _IOW(PPA_IOC_MAGIC, PPA_CMD_RESET_QOS_WFQ_NR, PPA_CMD_WFQ_INFO) 

#endif  //end of CONFIG_LTQ_PPA_QOS_WFQ

#ifdef CONFIG_LTQ_PPA_QOS_RATE_SHAPING
/** PPA Enable/Disable QOS Rate Shaping feature. Value is manipulated by _IOW() macro for final value
    \param[in] PPA_CMD_QOS_CTRL_INFO The parameter points to a
                            \ref PPA_CMD_QOS_CTRL_INFO structure 
*/
#define PPA_CMD_SET_CTRL_QOS_RATE _IOW(PPA_IOC_MAGIC, PPA_CMD_SET_CTRL_QOS_RATE_NR, PPA_CMD_QOS_CTRL_INFO) 


/** PPA get QOS Rate Shaping feature status: enabled or disabled. Value is manipulated by _IOR() macro for final value
    \param[in] PPA_CMD_QOS_CTRL_INFO The parameter points to a
                            \ref PPA_CMD_QOS_CTRL_INFO structure 
*/
#define PPA_CMD_GET_CTRL_QOS_RATE _IOR(PPA_IOC_MAGIC, PPA_CMD_GET_CTRL_QOS_RATE_NR, PPA_CMD_QOS_CTRL_INFO) 

/** PPA Set QOS rate shaping. Value is manipulated by _IOW() macro for final value
    \param[in] PPA_CMD_RATE_INFO The parameter points to a
    \ref PPA_CMD_RATE_INFO structure 
*/
#define PPA_CMD_SET_QOS_RATE _IOW(PPA_IOC_MAGIC, PPA_CMD_SET_QOS_RATE_NR, PPA_CMD_RATE_INFO) 

/** PPA Get QOS Rate shaping configuration. Value is manipulated by _IOR() macro for final value
    \param[out] PPA_CMD_RATE_INFO The parameter points to a
                     \ref PPA_CMD_RATE_INFO structure 
    \note portid, queueid and weight should be set accordingly. 
*/
#define PPA_CMD_GET_QOS_RATE _IOR(PPA_IOC_MAGIC, PPA_CMD_GET_QOS_RATE_NR, PPA_CMD_RATE_INFO)

/** PPA Reset QOS Rate shaping. Value is manipulated by _IOW() macro for final value
    \param[in] PPA_CMD_RATE_INFO The parameter points to a
                            \ref PPA_CMD_RATE_INFO structure 
    \note: portid/queueid is input parameter, and weight is output value. 
*/
#define PPA_CMD_RESET_QOS_RATE _IOW(PPA_IOC_MAGIC, PPA_CMD_RESET_QOS_RATE_NR, PPA_CMD_RATE_INFO) 

#endif  //end of CONFIG_LTQ_PPA_QOS_RATE_SHAPING

#endif //end of CONFIG_LTQ_PPA_QOS
 

typedef enum {
  PPA_GENERIC_HAL_GET_QOS_QUEUE_NUM,  //get maximum QOS queue number
  PPA_GENERIC_HAL_GET_QOS_MIB,  //get maximum QOS queue number
  PPA_GENERIC_HAL_SET_QOS_WFQ_CTRL,  //enable/disable WFQ
  PPA_GENERIC_HAL_GET_QOS_WFQ_CTRL,  //get  WFQ status: enabeld/disabled
  PPA_GENERIC_HAL_SET_QOS_WFQ_CFG,  //set WFQ cfg
  PPA_GENERIC_HAL_RESET_QOS_WFQ_CFG,  //reset WFQ cfg
  PPA_GENERIC_HAL_GET_QOS_WFQ_CFG,  //get WFQ cfg
  PPA_GENERIC_HAL_INIT_QOS_WFQ, // init QOS Rateshapping
  PPA_GENERIC_HAL_SET_QOS_RATE_SHAPING_CTRL,  //enable/disable Rate shaping
  PPA_GENERIC_HAL_GET_QOS_RATE_SHAPING_CTRL,  //get  Rateshaping status: enabeld/disabled
  PPA_GENERIC_HAL_SET_QOS_RATE_SHAPING_CFG,  //set rate shaping
  PPA_GENERIC_HAL_GET_QOS_RATE_SHAPING_CFG,  //get rate shaping cfg
  PPA_GENERIC_HAL_RESET_QOS_RATE_SHAPING_CFG,  //reset rate shaping cfg
  PPA_GENERIC_HAL_INIT_QOS_RATE_SHAPING, // init QOS Rateshapping
  PPA_GENERIC_HAL_GET_QOS_STATUS, // get QOS tatus
}PPA_GENERIC_HOOK_CMD;

/*
 * ####################################
 *              Data Type
 * ####################################
 */

typedef int32_t (*ppe_generic_hook_t)(PPA_GENERIC_HOOK_CMD cmd, void *buffer, uint32_t flag);

/*!
    \brief This is the data structure for IOCTL
*/

/*!
    \brief This is the data structure for PPA QOS Internal INFO
*/
typedef struct { 
    uint32_t   t; /*!<  Time Tick */
    uint32_t   w; /*!<  weight */
    uint32_t   s; /*!<  burst */
    uint32_t   r; /*!<  Replenish */
    uint32_t   d; /*!<  ppe internal variable */
    uint32_t   tick_cnt; /*!<  ppe internal variable */
    uint32_t   b; /*!<  ppe internal variable */

    /*For PPA Level only */
    uint32_t   reg_addr;  /*!<  register address */
    uint32_t bit_rate_kbps;  /*!<  rate shaping in kbps */  
    uint32_t weight_level;   /*!<  internal wfq weight */
    
}PPA_QOS_INTERVAL;

/*!
    \brief This is the data structure for PPA QOS Internal Debug INFO
*/
typedef struct  {
    //struct wtx_qos_q_desc_cfg
    uint32_t    threshold; /*!<  qos wtx threshold */
    uint32_t    length;  /*!<  qos wtx length  */
    uint32_t    addr; /*!<  qos wtx address */
    uint32_t    rd_ptr; /*!<  qos wtx read pointer  */
    uint32_t    wr_ptr; /*!<  qos wtx write pointer */

        /*For PPA Level only */
   uint32_t   reg_addr;  /*!<  register address */     
}PPA_QOS_DESC_CFG_INTERNAL;


/*!
    \brief This is the data structure for PPA QOS to get the maximum queue number supported for one physical port
*/
typedef struct {
    uint32_t        portid;   /*!<  the phisical port id which support qos queue */    
    uint32_t        queue_num;  /*!<  the maximum queue number is supported */
    uint32_t        flags;    /*!<  Reserved currently */
} PPA_CMD_QUEUE_NUM_INFO;

/*!
    \brief This is the data structure for PPA QOS MIB Counter
*/
typedef struct {
    uint64_t        total_rx_pkt;   /*!<  all packets received by this queue */
    uint64_t        total_rx_bytes; /*!<  all bytes received by thi queue */
    uint64_t        total_tx_pkt;   /*!<  all packets trasmitted by this queue */
    uint64_t        total_tx_bytes; /*!<  all bytes trasmitted by thi queue */
    
    uint64_t        cpu_path_small_pkt_drop_cnt;  /*!< all small packets dropped in CPU path for lack of TX DMA descriptor in the queue*/
    uint64_t        cpu_path_total_pkt_drop_cnt;  /*!< all packets dropped in CPU path for lack of TX DMA descriptor in the queue*/
    uint64_t        fast_path_small_pkt_drop_cnt; /*!< all small packets dropped in fast path for lack of TX DMA descriptor */
    uint64_t        fast_path_total_pkt_drop_cnt; /*!< all packets dropped in fast path for lack of TX DMA descriptor */

    uint64_t        tx_diff;  /*!< tx bytes since last read */
    uint64_t        tx_diff_L1;  /*!< tx bytes plus L1 overheader since last read */
    uint64_t        tx_diff_jiffy;  /*!< jiffy diff since last read */
    uint32_t        sys_hz;  /*!< system HZ value. For debugging purpose */
} PPA_QOS_MIB;

/*!
    \brief This is the data structure for PPA QOS to get the maximum queue number supported for one physical port
*/
typedef struct {
    uint32_t        portid; /*!<  the phisical port id which support qos queue */
    uint32_t        queueid;  /*!<  the queue id for the mib */
    PPA_QOS_MIB     mib;    /*!<  the mib information for the current specified queue */
    uint32_t        flags;  /*!<  Reserved currently */
} PPA_CMD_QOS_MIB_INFO;



/*!
    \brief This is the data structure for PPA QOS to be enabled/disabled
*/
typedef struct {
    uint32_t        portid;  /*!<  which support qos queue. */
    uint32_t        enable;  /*!<  enable/disable  flag */
    uint32_t        flags;   /*!<  Reserved currently */
} PPA_CMD_QOS_CTRL_INFO;

/*!
    \brief This is the data structure for PPA Rate Shapping Set/Get/Reset one queue's rate limit
*/
typedef struct {
    uint32_t        portid;   /*!<  the phisical port id which support qos queue */
    uint32_t        queueid;  /*!<  the queu id. Now it only support 0 ~ 7 */
    uint32_t        rate;     /*!<  rate limit in kbps  */
    uint32_t        burst;    /*!<  rate limit in bytes. Note: it is PPE FW QOS internal value. Normally there is no need to set this value or just set to default value zero */
    uint32_t        flags;    /*!<  Reserved currently */
} PPA_CMD_RATE_INFO;



/*!
    \brief This is the data structure for PPA WFQ Set/Get/Reset one queue's weight
*/
typedef struct {
    uint32_t        portid;   /*!<  the phisical port id which support qos queue */
    uint32_t        queueid;  /*!<  the queu id. Now it only support 0 ~ 7 */    
    uint32_t        weight;   /*!<  WFQ weight. The value is from 0 ~ 100 */
    uint32_t        flags;    /*!<  Reserved currently */
} PPA_CMD_WFQ_INFO;

typedef struct {
    uint32_t portid;
    uint32_t num ; 
    uint32_t flags ; 
} PPE_QOS_COUNT_CFG;

typedef struct {
    uint32_t portid;
    uint32_t queueid;
    PPA_QOS_MIB mib;
    uint32_t reg_addr; 
    uint32_t flag;
} PPE_QOS_MIB_INFO;

typedef struct {
    uint32_t portid;
    uint32_t queueid;
    uint32_t weight_level;
    uint32_t flag;
} PPE_QOS_WFQ_CFG;

typedef struct {
    uint32_t portid;
    uint32_t f_enable;
    uint32_t flag;
} PPE_QOS_ENABLE_CFG;

typedef struct {
    uint32_t portid;
    uint32_t queueid;
    uint32_t rate_in_kbps;
    uint32_t burst;
    uint32_t flag;
} PPE_QOS_RATE_SHAPING_CFG;


/*!
    \brief This is the data structure for PPA QOS status
*/
typedef struct
{
    uint32_t qos_queue_portid; /*!<  the port id which support qos. at present, only one port can support QOS at run time */

    //port's qos status
    uint32_t time_tick     ; /*!<    number of PP32 cycles per basic time tick */
    uint32_t overhd_bytes  ; /*!<    number of overhead bytes per packet in rate shaping */
    uint32_t eth1_eg_qnum  ; /*!<    maximum number of egress QoS queues; */        
    uint32_t eth1_burst_chk; /*!<    always 1, more accurate WFQ */    
    uint32_t eth1_qss      ; /*!<    1-FW QoS, 0-HW QoS */
    uint32_t shape_en      ; /*!<    1-enable rate shaping, 0-disable */
    uint32_t wfq_en        ; /*!<    1-WFQ enabled, 0-strict priority enabled */
	
    uint32_t tx_qos_cfg_addr; /*!<  qos cfg address */
    uint32_t pp32_clk;   /*!<  pp32 clock  */
    uint32_t basic_time_tick; /*!<  pp32 qos time tick  */
	
    uint32_t wfq_multiple; /*!<  qos wfq multipler  */
    uint32_t wfq_multiple_addr; /*!<  qos wfq multipler address  */
	
    uint32_t wfq_strict_pri_weight; /*!<  strict priority's weight value */
    uint32_t wfq_strict_pri_weight_addr; /*!<  strict priority's weight address  */	

    uint32_t    wan_port_map;  /*!<  wan port interface register value  */
    uint32_t    wan_mix_map;   /*!<  mixed register value  */


    PPA_QOS_INTERVAL qos_port_rate_internal;   /*!<  internal qos port parameters  */
    PPA_QOS_INTERVAL ptm_qos_port_rate_shaping[4]; /*!< internal ptm qos port rate shaping parameters */

    uint32_t max_buffer_size;  /*!<  must match with below arrays, ie, here set to 8 */
    PPE_QOS_MIB_INFO  mib[PPA_MAX_QOS_QUEUE_NUM];   /*!<  Qos mib buffer */
    PPA_QOS_INTERVAL queue_internal[PPA_MAX_QOS_QUEUE_NUM];   /*!<  internal qos queue parameters */
    PPA_QOS_DESC_CFG_INTERNAL desc_cfg_interanl[PPA_MAX_QOS_QUEUE_NUM];/*!<  internal desc cfg parameters */
    uint32_t res;   /*!<  res flag for qos status succeed or not: possible value is PPA_SUCCESS OR PPA_FAILURE  */
  
} PPA_QOS_STATUS;


/*!
    \brief This is the data structure for PPA QOS to get the status
*/
typedef struct {
    PPA_QOS_STATUS qstat; /*!< qos status buffer */
    uint32_t        flags;    /*!<  Reserved currently */
} PPA_CMD_QOS_STATUS_INFO;


typedef union
{
#ifdef CONFIG_LTQ_PPA_QOS
    PPA_CMD_QOS_STATUS_INFO        qos_status_info; /*!< PPA qos status parameter */
    PPA_CMD_QUEUE_NUM_INFO          qnum_info;  /*!< PPA qos queue parameter */
    PPA_CMD_QOS_CTRL_INFO           qos_ctrl_info;  /*!< PPA qos control parameter */
    PPA_CMD_QOS_MIB_INFO            qos_mib_info; /*!< PPA qos mib parameter */
#ifdef CONFIG_LTQ_PPA_QOS_RATE_SHAPING
    PPA_CMD_RATE_INFO               qos_rate_info;  /*!< PPA qos rate shapping parameter */
#endif  //end of CONFIG_LTQ_PPA_QOS_RATE_SHAPING
#ifdef CONFIG_LTQ_PPA_QOS_WFQ
    PPA_CMD_WFQ_INFO                qos_wfq_info;  /*!< PPA qos wfq parameter */
#endif  //end of CONFIG_LTQ_PPA_QOS_WFQ
#endif  //end of CONFIG_LTQ_PPA_QOS
} PPA_CMD_DATA;




/*
 * ####################################
 *             Declaration
 * ####################################
 */
#ifdef CONFIG_LTQ_PPA_QOS
extern int32_t ppa_ioctl_get_qos_status(unsigned int cmd, unsigned long arg, PPA_CMD_DATA * cmd_info);
extern int32_t ppa_get_qos_qnum( uint32_t portid, uint32_t flag);
extern int32_t ppa_ioctl_get_qos_qnum(unsigned int cmd, unsigned long arg, PPA_CMD_DATA * cmd_info);
extern int32_t ppa_get_qos_mib( uint32_t portid, uint32_t queueid, PPA_QOS_MIB *mib, uint32_t flag);
extern int32_t ppa_ioctl_get_qos_mib(unsigned int cmd, unsigned long arg, PPA_CMD_DATA * cmd_info);

#ifdef CONFIG_LTQ_PPA_QOS_WFQ
extern int32_t ppa_set_qos_wfq( uint32_t portid, uint32_t queueid, uint32_t weight_level, uint32_t flag );
extern int32_t ppa_get_qos_wfq( uint32_t portid, uint32_t queueid, uint32_t *weight_level, uint32_t flag);
extern int32_t ppa_reset_qos_wfq( uint32_t portid, uint32_t queueid, uint32_t flag);
extern int32_t ppa_set_ctrl_qos_wfq(uint32_t portid,  uint32_t f_enable, uint32_t flag);
extern int32_t ppa_get_ctrl_qos_wfq(uint32_t portid,  uint32_t *f_enable, uint32_t flag);

extern int32_t ppa_ioctl_set_ctrl_qos_wfq(unsigned int cmd, unsigned long arg, PPA_CMD_DATA * cmd_info);
extern int32_t ppa_ioctl_get_ctrl_qos_wfq(unsigned int cmd, unsigned long arg, PPA_CMD_DATA * cmd_info);
extern int32_t ppa_ioctl_set_qos_wfq(unsigned int cmd, unsigned long arg, PPA_CMD_DATA * cmd_info);
extern int32_t ppa_ioctl_get_qos_wfq(unsigned int cmd, unsigned long arg, PPA_CMD_DATA * cmd_info);
extern int32_t ppa_ioctl_reset_qos_wfq(unsigned int cmd, unsigned long arg, PPA_CMD_DATA * cmd_info); 
#endif //end of CONFIG_LTQ_PPA_QOS_WFQ

#ifdef CONFIG_LTQ_PPA_QOS_RATE_SHAPING
extern int32_t ppa_set_ctrl_qos_rate(uint32_t portid,  uint32_t f_enable, uint32_t flag);
extern int32_t ppa_get_ctrl_qos_rate(uint32_t portid,  uint32_t *f_enable, uint32_t flag);
extern int32_t ppa_set_qos_rate( uint32_t portid, uint32_t queueid, uint32_t rate, uint32_t burst, uint32_t flag );
extern int32_t ppa_get_qos_rate( uint32_t portid, uint32_t queueid, uint32_t *rate, uint32_t *burst, uint32_t flag);
extern int32_t ppa_reset_qos_rate( uint32_t portid, uint32_t queueid, uint32_t flag);

extern int32_t ppa_ioctl_set_ctrl_qos_rate(unsigned int cmd, unsigned long arg, PPA_CMD_DATA * cmd_info);
extern int32_t ppa_ioctl_get_ctrl_qos_rate(unsigned int cmd, unsigned long arg, PPA_CMD_DATA * cmd_info);
extern int32_t ppa_ioctl_set_qos_rate(unsigned int cmd, unsigned long arg, PPA_CMD_DATA * cmd_info);
extern int32_t ppa_ioctl_reset_qos_rate(unsigned int cmd, unsigned long arg, PPA_CMD_DATA * cmd_info);
extern int32_t ppa_ioctl_get_qos_rate(unsigned int cmd, unsigned long arg, PPA_CMD_DATA * cmd_info);
#endif //END OF CONFIG_LTQ_PPA_QOS_RATE_SHAPING

#endif //END OF CONFIG_LTQ_PPA_QOS


#endif  //end of __PPA_API_MFE_H__20100427_1703

