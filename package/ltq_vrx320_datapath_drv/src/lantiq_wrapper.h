
#ifndef LANTIQ_WRAPPER_H
#define LANTIQ_WRAPPER_H

//#define CONFIG_LTQ_PPA_QOS
#define CONFIG_LTQ_PPA_QOS_WFQ
#define CONFIG_LTQ_PPA_QOS_RATE_SHAPING

#define AKRONITE_BOARD
#include "../drivers/net/ethernet/lantiq/lantiq_pcie.h"
//#include <asm/mach-lantiq/xway/lantiq_pcie.h>
#define IFX_SUCCESS 0
#define IFX_ERROR -1
#define KSEG0 0x0
#define KSEG1 0x0
#define KSEG1ADDR(x) (0x00000000 + x)
#define CPHYSADDR(x) (x)
//#include <asm/memory.h>
#define IFX_REG_R32(_r)                    __raw_readl((volatile unsigned int *)(_r))
#define IFX_REG_W32(_v, _r)               __raw_writel((_v), (volatile unsigned int *)(_r))
#define IFX_REG_W32_MASK(_clr, _set, _r)   IFX_REG_W32((IFX_REG_R32((_r)) & ~(_clr)) | (_set), (_r))
/*
struct port_cell_info {
    unsigned int    port_num;
    unsigned int    tx_link_rate[2];
};
typedef enum { 
    LTQ_MEI_UNKNOWN        = 0, 
    LTQ_MEI_SHOWTIME_CHECK = 1, 
    LTQ_MEI_SHOWTIME_ENTER = 2,
    LTQ_MEI_SHOWTIME_EXIT  = 3 
} e_ltq_mei_cb_type; 
struct ltq_mei_atm_showtime_info {
                void *check_ptr;
                void *enter_ptr;
                void *exit_ptr;
                };

//typedef int (*ltq_mei_atm_showtime_check_t)(int *, struct port_cell_info *, void **);
//typedef int (*ltq_mei_atm_showtime_enter_t)(struct port_cell_info *, void *);
//typedef int (*ltq_mei_atm_showtime_exit_t)(void);
*/

extern unsigned int normal_start(void);
extern unsigned int normal_stop(void);

//#define CONFIG_IFX_ETH_FRAMEWORK


#define NUM_ENTITY(x)                           (sizeof(x) / sizeof(*(x)))
//#include <asm/dma-mapping.h>

/*!
    \brief PPA_SUCCESS
*/
#define PPA_SUCCESS                             0   /*!< Operation was successful. */

/*!
    \brief PPA_FAILURE
*/
#define PPA_FAILURE                             -1  /*!< Operation failed */
#define dp printk

#endif
