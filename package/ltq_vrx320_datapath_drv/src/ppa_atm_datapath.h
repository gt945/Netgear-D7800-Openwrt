#ifndef PPA_ATM_DATAPATH_H
#define PPA_ATM_DATAPATH_H



/******************************************************************************
**
** FILE NAME    : ppa_datapath.h
** PROJECT      : UEIP
** MODULES      : Acceleration Package (PPA A4/D4/A5/D5)
**
** DATE         : 2 SEP 2009
** AUTHOR       : Xu Liang
** DESCRIPTION  : Acceleration Package Data Path Header File
** COPYRIGHT    :   Copyright (c) 2006
**          Infineon Technologies AG
**          Am Campeon 1-12, 85579 Neubiberg, Germany
**
**    This program is free software; you can redistribute it and/or modify
**    it under the terms of the GNU General Public License as published by
**    the Free Software Foundation; either version 2 of the License, or
**    (at your option) any later version.
**
** HISTORY
** $Date        $Author         $Comment
**  2 SEP 2009  Xu Liang        Initiate Version
*******************************************************************************/

/*
 * ####################################
 *              Definition
 * ####################################
 */

/*
 *  ATM ioctl Command
 */
#define PPE_ATM_IOC_MAGIC               'o'
#define PPE_ATM_MIB_CELL                _IOW(PPE_ATM_IOC_MAGIC,  0, atm_cell_ifEntry_t)
#define PPE_ATM_MIB_AAL5                _IOW(PPE_ATM_IOC_MAGIC,  1, atm_aal5_ifEntry_t)
#define PPE_ATM_MIB_VCC                 _IOWR(PPE_ATM_IOC_MAGIC, 2, atm_aal5_vcc_x_t)
#define PPE_ATM_MAP_PKT_PRIO_TO_Q       _IOR(PPE_ATM_IOC_MAGIC,  3, struct ppe_prio_q_map)
#define PPE_ATM_TX_Q_OP                 _IOR(PPE_ATM_IOC_MAGIC,  4, struct tx_q_op)
#define PPE_ATM_GET_MAP_PKT_PRIO_TO_Q   _IOWR(PPE_ATM_IOC_MAGIC, 5, struct ppe_prio_q_map_all)
#define PPE_ATM_IOC_MAXNR               6

#define PPE_ATM_TX_Q_OP_CHG_MASK        0x01
#define PPE_ATM_TX_Q_OP_ADD             0x02

/*
 * ####################################
 *              Data Type
 * ####################################
 */

/*
 *  ATM MIB
 */
typedef struct {
        __u32   ifHCInOctets_h;
        __u32   ifHCInOctets_l;
        __u32   ifHCOutOctets_h;
        __u32   ifHCOutOctets_l;
        __u32   ifInErrors;
        __u32   ifInUnknownProtos;
        __u32   ifOutErrors;
} atm_cell_ifEntry_t;

typedef struct {
        __u32   ifHCInOctets_h;
        __u32   ifHCInOctets_l;
        __u32   ifHCOutOctets_h;
        __u32   ifHCOutOctets_l;
        __u32   ifInUcastPkts;
        __u32   ifOutUcastPkts;
        __u32   ifInErrors;
        __u32   ifInDiscards;
        __u32   ifOutErros;
        __u32   ifOutDiscards;
} atm_aal5_ifEntry_t;

typedef struct {
        __u32   aal5VccCrcErrors;
        __u32   aal5VccSarTimeOuts;//no timer support yet
        __u32   aal5VccOverSizedSDUs;

        __u32   aal5VccRxPDU;
        __u32   aal5VccRxBytes;
        __u32   aal5VccRxCell;      //  reserved
        __u32   aal5VccRxOAM;       //  reserved
        __u32   aal5VccTxPDU;
        __u32   aal5VccTxBytes;
        __u32   aal5VccTxDroppedPDU;
        __u32   aal5VccTxCell;      //  reserved
        __u32   aal5VccTxOAM;       //  reserved
} atm_aal5_vcc_t;

/*
 *  Data Type Used to Call ATM ioctl
 */
typedef struct {
    int             vpi;
    int             vci;
    atm_aal5_vcc_t  mib_vcc;
} atm_aal5_vcc_x_t;

struct ppe_prio_q_map {     //  also used in ethernet ioctl
    int             pkt_prio;
    int             qid;
    int             vpi;    //  ignored in eth interface
    int             vci;    //  ignored in eth interface
};

struct tx_q_op {
    int             vpi;
    int             vci;
    unsigned int    flags;
};

struct ppe_prio_q_map_all {
    int             vpi;
    int             vci;
    int             total_queue_num;
    int             pkt_prio[8];
    int             qid[8];
};

/*
 *  Bits Operation
 */
#define GET_BITS(x, msb, lsb)               \
    (((x) >> (lsb)) & ((1 << ((msb) + 1 - (lsb))) - 1))
#define SET_BITS(x, msb, lsb, value)        \
    (((x) & ~(((1 << ((msb) + 1)) - 1) ^ ((1 << (lsb)) - 1))) | (((value) & ((1 << (1 + (msb) - (lsb))) - 1)) << (lsb)))


#endif  // PPA_ATM_DATAPATH_H

