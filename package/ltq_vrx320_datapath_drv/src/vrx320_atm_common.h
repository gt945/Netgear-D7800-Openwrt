#ifndef __VRX218_ATM_COMMON_H__
#define __VRX218_ATM_COMMON_H__

/* This h file is created to share the address mappings and functions between atm .c files  */

/*
 * ####################################
 *         External Function Declaration
 * ####################################
 */
extern struct sk_buff* (*ifx_atm_alloc_tx)(struct atm_vcc *, unsigned int);
//#ifdef LANTIQ_ENV //ALEX
extern void (*ppa_hook_mpoa_setup)(struct atm_vcc *, int, int);
//#endif

/*
 * ####################################
 *         Structure Declaration
 * ####################################
 */
struct htu_entry {
#if defined(__LITTLE_ENDIAN_BITFIELD)
    unsigned int    vld         :1;
    unsigned int    pti         :3;
    unsigned int    vci         :16;
    unsigned int    vpi         :8;
    unsigned int    pid         :2;
    unsigned int    res1        :2;
#elif defined (__BIG_ENDIAN_BITFIELD)
    unsigned int    res1        :2;
    unsigned int    pid         :2;
    unsigned int    vpi         :8;
    unsigned int    vci         :16;
    unsigned int    pti         :3;
    unsigned int    vld         :1;
#else
#error  "Please fix <asm/byteorder.h>"
#endif
};

struct htu_mask {
#if defined(__LITTLE_ENDIAN_BITFIELD)
    unsigned int    clear       :1;
    unsigned int    pti_mask    :3;
    unsigned int    vci_mask    :16;
    unsigned int    vpi_mask    :8;
    unsigned int    pid_mask    :2;
    unsigned int    set         :2;
#elif defined(__BIG_ENDIAN_BITFIELD)
    unsigned int    set         :2;
    unsigned int    pid_mask    :2;
    unsigned int    vpi_mask    :8;
    unsigned int    vci_mask    :16;
    unsigned int    pti_mask    :3;
    unsigned int    clear       :1;
#else
#error  "Please fix <asm/byteorder.h>"
#endif
};

struct htu_result {
#if defined(__LITTLE_ENDIAN_BITFIELD)
    unsigned int    qid         :4;
    unsigned int    res3        :5;
    unsigned int    ven         :1;
    unsigned int    type        :1;
    unsigned int    res2        :5;
    unsigned int    cellid      :4;
    unsigned int    res1        :12;
#elif defined(__BIG_ENDIAN_BITFIELD)
    unsigned int    res1        :12;
    unsigned int    cellid      :4;
    unsigned int    res2        :5;
    unsigned int    type        :1;
    unsigned int    ven         :1;
    unsigned int    res3        :5;
    unsigned int    qid         :4;
#else
#error  "Please fix <asm/byteorder.h>"
#endif
};

struct dsl_wan_mib_table {
    unsigned int    res1;
    unsigned int    wrx_drophtu_cell;
    unsigned int    wrx_dropdes_pdu;
    unsigned int    wrx_correct_pdu;
    unsigned int    wrx_err_pdu;
    unsigned int    wrx_dropdes_cell;
    unsigned int    wrx_correct_cell;
    unsigned int    wrx_err_cell;
    unsigned int    wrx_total_byte;
    unsigned int    res2;
    unsigned int    wtx_total_pdu;
    unsigned int    wtx_total_cell;
    unsigned int    wtx_total_byte;
    unsigned int    res3[3];
};

struct dsl_queue_mib {
    unsigned int    pdu;
    unsigned int    bytes;
};

struct dsl_queue_drop_mib {
    unsigned int    pdu;
};


/*
 * ####################################
 *         Address Mapping Macro
 * ####################################
 */

#define PSAVE_CFG(base)                         ((volatile struct psave_cfg *)              SOC_ACCESS_VRX218_SB(__PSAVE_CFG, base))

#endif  //__VRX218_ATM_COMMON_H__
