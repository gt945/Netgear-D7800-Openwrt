/*
 *  This program is free software; you can redistribute it and/or modify it
 *  under the terms of the GNU General Public License version 2 as published
 *  by the Free Software Foundation.
 *
 *  Copyright (C) 2009~2013 Lei Chuanhua <chuanhua.lei@lantiq.com>
 */
#ifndef PCIE_LANTIQ_H
#define PCIE_LANTIQ_H
#include <linux/types.h>
#include <linux/delay.h>
#include <linux/of.h>

#include <linux/pci.h>
#include <linux/interrupt.h>
#include <linux/spinlock.h>

//#include <lantiq.h>
#include <linux/gpio.h>
//#include <lantiq_soc.h>


/*!
 \defgroup PCIE  PCI Express bus driver module
 \brief  PCI Express IP module support VRX200/ARX300/HN
*/

/*!
 \defgroup PCIE_OS OS APIs
 \ingroup PCIE
 \brief PCIe bus driver OS interface functions
*/

/*!
 \file pcie-lantiq.h
 \ingroup PCIE
 \brief header file for PCIe module common header file
*/

#define MS(_v, _f)  (((_v) & (_f)) >> _f##_S)
#define SM(_v, _f)  (((_v) << _f##_S) & (_f))


#define PCIE_MSG_MSI		0x00000001
#define PCIE_MSG_ISR		0x00000002
#define PCIE_MSG_FIXUP		0x00000004
#define PCIE_MSG_READ_CFG	0x00000008
#define PCIE_MSG_WRITE_CFG	0x00000010
#define PCIE_MSG_CFG		(PCIE_MSG_READ_CFG | PCIE_MSG_WRITE_CFG)
#define PCIE_MSG_REG		0x00000020
#define PCIE_MSG_INIT		0x00000040
#define PCIE_MSG_ERR		0x00000080
#define PCIE_MSG_PHY		0x00000100
#define PCIE_MSG_ANY		0x000001ff

/* Debug option, more will be coming */

/* #define LTQ_PCIE_DBG */

/* Reuse kernel stuff, but we need to differentiate baseline
 * error reporting and AEE */
#ifdef CONFIG_PCIEAER
#define LTQ_PCIE_BASIC_ERROR_INT
#endif /* CONFIG_PCIEAER */

/* XXX, should be only enabled after LTQ_PCIE_BASIC_ERROR_INT */
#define LTQ_PCIE_AER_REPORT

/* Always report fatal error */
#define PCIE_KASSERT(exp, msg) do {	\
	if (unlikely(!(exp))) {	\
		printk msg;		\
		BUG();			\
	}				\
} while (0)

/* Port number definition */
enum {
	LTQ_PCIE_PORT0 = 0,
	LTQ_PCIE_PORT1,
	LTQ_PCIE_PORT2,
};

#if defined(LTQ_PCIE_DBG)
#define pcie_dbg(_m, _fmt, args...) do {	\
	if (g_pcie_debug_flag & (_m))		\
		pcie_debug((_fmt), ##args);	\
} while (0)

#else
#define pcie_dbg(_m, _fmt, args...)	do {} while (0)
#endif

#define MSI_IRQ_NUM    16

enum {
	PCIE_MSI_IDX0 = 0,
	PCIE_MSI_IDX1,
	PCIE_MSI_IDX2,
	PCIE_MSI_IDX3,
};

/* Interrupt related stuff */
#define PCIE_LEGACY_DISABLE		0
#define PCIE_LEGACY_INTA		1
#define PCIE_LEGACY_INTB		2
#define PCIE_LEGACY_INTC		3
#define PCIE_LEGACY_INTD		4
#define PCIE_LEGACY_INT_MAX		PCIE_LEGACY_INTD

#if 0
/** Structure used to extract physical Root Complex index number,
 * it is shared between RC and EP */
struct ltq_pcie_controller {
	/*!< PCI controller information used as system specific information */
	struct pci_controller pcic;
	spinlock_t lock; /*!< Per controller lock */
	 /*!< RC specific, per host bus information,
	  * port 0 -- RC 0, port 1 -- RC1 */
	const u32 port;
};
#endif

/* The structure will store mapping address to support multiple RC */
struct pcie_addr_map {
	const u32 cfg_base;
	const u32 mem_base;
	const u32 io_base;
	const u32 mem_phy_base;
	const u32 mem_phy_end;
	const u32 io_phy_base;
	const u32 io_phy_end;
	const u32 app_logic_base;
	const u32 rc_addr_base;
	const u32 phy_base;
};

struct msi_irq_idx {
	const int irq;
	const int idx;
};

struct ltq_msi_pic {
	volatile u32 pic_table[MSI_IRQ_NUM];
	volatile u32 pic_endian; /* 0x40  */
};

struct msi_irq {
	struct ltq_msi_pic * const msi_pic_p;
	const u32 msi_phy_base;
	const struct msi_irq_idx msi_irq_idx[MSI_IRQ_NUM];
	spinlock_t msi_lock;
	/*
	 * Each bit in msi_free_irq_bitmask represents a MSI interrupt that is
	 * in use.
	 */
	u16 msi_free_irq_bitmask;

	/*
	 * Each bit in msi_multiple_irq_bitmask tells that the device using
	 * this bit in msi_free_irq_bitmask is also using the next bit. This
	 * is used so we can disable all of the MSI interrupts when a device
	 * uses multiple.
	 */
	u16 msi_multiple_irq_bitmask;
};

struct pcie_ir_irq {
	const unsigned int irq;
	const char name[16];
};

struct pcie_legacy_irq {
	const u32 irq_bit;
	const int irq;
};

struct pcie_irq {
	struct pcie_ir_irq ir_irq;
	struct pcie_legacy_irq legacy_irq[PCIE_LEGACY_INT_MAX];
};

#if 0
struct ltq_pcie_port {
	struct pcie_addr_map port_to_addr;
	struct ltq_pcie_controller controller;
	struct pcie_irq legacy_irqs;
	struct msi_irq msi_irqs;
	int rc_physical_port;
};
#endif


/* Port number defined in platform specific file */

#define PCIE_CFG_PORT_TO_BASE(X) (g_pcie_port_defs[(X)].port_to_addr.cfg_base)

#define PCIE_MEM_PORT_TO_BASE(X) (g_pcie_port_defs[(X)].port_to_addr.mem_base)

#define PCIE_IO_PORT_TO_BASE(X)  (g_pcie_port_defs[(X)].port_to_addr.io_base)

#define PCIE_MEM_PHY_PORT_TO_BASE(X)	\
	(g_pcie_port_defs[(X)].port_to_addr.mem_phy_base)

#define PCIE_MEM_PHY_PORT_TO_END(X)	\
	(g_pcie_port_defs[(X)].port_to_addr.mem_phy_end)

#define PCIE_IO_PHY_PORT_TO_BASE(X)	\
	(g_pcie_port_defs[(X)].port_to_addr.io_phy_base)

#define PCIE_IO_PHY_PORT_TO_END(X)	\
	(g_pcie_port_defs[(X)].port_to_addr.io_phy_end)

#define PCIE_APP_PORT_TO_BASE(X)	\
	(g_pcie_port_defs[(X)].port_to_addr.app_logic_base)

#define PCIE_RC_PORT_TO_BASE(X)		\
	(g_pcie_port_defs[(X)].port_to_addr.rc_addr_base)

#define PCIE_PHY_PORT_TO_BASE(X)	\
	(g_pcie_port_defs[(X)].port_to_addr.phy_base)

/* PCIe Application Logic Register */
/* RC Core Control Register */
#define PCIE_RC_CCR(X)		(u32 *)(PCIE_APP_PORT_TO_BASE(X) + 0x10)

/* This should be enabled after initializing configuratin registers
 * Also should check link status retraining bit
 */
/* Enable LTSSM to continue link establishment */
#define PCIE_RC_CCR_LTSSM_ENABLE		0x00000001
/* RC Core Debug Register */
#define PCIE_RC_DR(X)		(u32 *)(PCIE_APP_PORT_TO_BASE(X) + 0x14)

#define PCIE_RC_DR_DLL_UP			0x00000001
#define PCIE_RC_DR_CURRENT_POWER_STATE		0x0000000E
#define PCIE_RC_DR_CURRENT_POWER_STATE_S	1
#define PCIE_RC_DR_CURRENT_LTSSM_STATE		0x000001F0
#define PCIE_RC_DR_CURRENT_LTSSM_STATE_S	4

#define PCIE_RC_DR_PM_DEV_STATE			0x00000E00
#define PCIE_RC_DR_PM_DEV_STATE_S		9

#define PCIE_RC_DR_PM_ENABLED			0x00001000
#define PCIE_RC_DR_PME_EVENT_ENABLED		0x00002000
#define PCIE_RC_DR_AUX_POWER_ENABLED		0x00004000

/* Current Power State Definition */
enum {
	PCIE_RC_DR_D0 = 0,
	PCIE_RC_DR_D1, /* Not supported */
	PCIE_RC_DR_D2, /* Not supported */
	PCIE_RC_DR_D3,
	PCIE_RC_DR_UN,
};

/* PHY Link Status Register */
#define PCIE_PHY_SR(X)		(u32 *)(PCIE_APP_PORT_TO_BASE(X) + 0x18)

#define PCIE_PHY_SR_PHY_LINK_UP		0x00000001

/* Electromechanical Control Register */
#define PCIE_EM_CR(X)		(u32 *)(PCIE_APP_PORT_TO_BASE(X) + 0x1C)

#define PCIE_EM_CR_CARD_IS_PRESENT		0x00000001
#define PCIE_EM_CR_MRL_OPEN			0x00000002
#define PCIE_EM_CR_POWER_FAULT_SET		0x00000004
#define PCIE_EM_CR_MRL_SENSOR_SET		0x00000008
#define PCIE_EM_CR_PRESENT_DETECT_SET		0x00000010
#define PCIE_EM_CR_CMD_CPL_INT_SET		0x00000020
#define PCIE_EM_CR_SYS_INTERLOCK_SET		0x00000040
#define PCIE_EM_CR_ATTENTION_BUTTON_SET		0x00000080

/* Interrupt Status Register */
#define PCIE_IR_SR(X)		(u32 *)(PCIE_APP_PORT_TO_BASE(X) + 0x20)

#define PCIE_IR_SR_PME_CAUSE_MSI		0x00000002
#define PCIE_IR_SR_HP_PME_WAKE_GEN		0x00000004
#define PCIE_IR_SR_HP_MSI			0x00000008
#define PCIE_IR_SR_AHB_LU_ERR			0x00000030
#define PCIE_IR_SR_AHB_LU_ERR_S			4
#define PCIE_IR_SR_INT_MSG_NUM			0x00003E00
#define PCIE_IR_SR_INT_MSG_NUM_S		9
#define PCIE_IR_SR_AER_INT_MSG_NUM		0xF8000000
#define PCIE_IR_SR_AER_INT_MSG_NUM_S		27

/* Message Control Register */
#define PCIE_MSG_CR(X)		(u32 *)(PCIE_APP_PORT_TO_BASE(X) + 0x30)

#define PCIE_MSG_CR_GEN_PME_TURN_OFF_MSG	0x00000001
#define PCIE_MSG_CR_GEN_UNLOCK_MSG		0x00000002

#define PCIE_VDM_DR(X)		(u32 *)(PCIE_APP_PORT_TO_BASE(X) + 0x34)

/* Vendor-Defined Message Requester ID Register */
#define PCIE_VDM_RID(X)		(PCIE_APP_PORT_TO_BASE(X) + 0x38)

#define PCIE_VDM_RID_VENROR_MSG_REQ_ID		0x0000FFFF
#define PCIE_VDM_RID_VDMRID_S			0

/* ASPM Control Register */
#define PCIE_ASPM_CR(X)		(u32 *)(PCIE_APP_PORT_TO_BASE(X) + 0x40)

#define PCIE_ASPM_CR_HOT_RST			0x00000001
#define PCIE_ASPM_CR_REQ_EXIT_L1		0x00000002
#define PCIE_ASPM_CR_REQ_ENTER_L1		0x00000004

/* Vendor Message DW0 Register */
#define PCIE_VM_MSG_DW0(X)	(u32 *)(PCIE_APP_PORT_TO_BASE(X) + 0x50)

#define PCIE_VM_MSG_DW0_TYPE		0x0000001F /* Message type */
#define PCIE_VM_MSG_DW0_TYPE_S		0
#define PCIE_VM_MSG_DW0_FORMAT		0x00000060 /* Format */
#define PCIE_VM_MSG_DW0_FORMAT_S	5
#define PCIE_VM_MSG_DW0_TC		0x00007000 /* Traffic Class */
#define PCIE_VM_MSG_DW0_TC_S		12
#define PCIE_VM_MSG_DW0_ATTR		0x000C0000 /* Atrributes */
#define PCIE_VM_MSG_DW0_ATTR_S		18
#define PCIE_VM_MSG_DW0_EP_TLP		0x00100000 /* Poisoned TLP */
#define PCIE_VM_MSG_DW0_TD		0x00200000 /* TLP Digest */
#define PCIE_VM_MSG_DW0_LEN		0xFFC00000 /* Length */
#define PCIE_VM_MSG_DW0_LEN_S		22

/* Format Definition */
enum {
	PCIE_VM_MSG_FORMAT_00 = 0, /* 3DW Hdr, no data */
	PCIE_VM_MSG_FORMAT_01, /* 4DW Hdr, no data */
	PCIE_VM_MSG_FORMAT_10, /* 3DW Hdr, with data */
	PCIE_VM_MSG_FORMAT_11, /* 4DW Hdr, with data */
};

/* Traffic Class Definition */
enum {
	PCIE_VM_MSG_TC0 = 0,
	PCIE_VM_MSG_TC1,
	PCIE_VM_MSG_TC2,
	PCIE_VM_MSG_TC3,
	PCIE_VM_MSG_TC4,
	PCIE_VM_MSG_TC5,
	PCIE_VM_MSG_TC6,
	PCIE_VM_MSG_TC7,
};

/* Attributes Definition */
enum {
	PCIE_VM_MSG_ATTR_00 = 0, /* RO and No Snoop cleared */
	PCIE_VM_MSG_ATTR_01, /* RO cleared , No Snoop set */
	PCIE_VM_MSG_ATTR_10, /* RO set, No Snoop cleared */
	PCIE_VM_MSG_ATTR_11, /* RO and No Snoop set */
};

/* Payload Size Definition */
#define PCIE_VM_MSG_LEN_MIN		0
#define PCIE_VM_MSG_LEN_MAX		1024

/* Vendor Message DW1 Register */
#define PCIE_VM_MSG_DW1(X)	(u32 *)(PCIE_APP_PORT_TO_BASE(X) + 0x54)

#define PCIE_VM_MSG_DW1_FUNC_NUM	0x00000070 /* Function Number */
#define PCIE_VM_MSG_DW1_FUNC_NUM_S	8
#define PCIE_VM_MSG_DW1_CODE		0x00FF0000 /* Message Code */
#define PCIE_VM_MSG_DW1_CODE_S		16
#define PCIE_VM_MSG_DW1_TAG		0xFF000000 /* Tag */
#define PCIE_VM_MSG_DW1_TAG_S		24

#define PCIE_VM_MSG_DW2(X)	(u32 *)(PCIE_APP_PORT_TO_BASE(X) + 0x58)

#define PCIE_VM_MSG_DW3(X)	(u32 *)(PCIE_APP_PORT_TO_BASE(X) + 0x5C)

/* Vendor Message Request Register */
#define PCIE_VM_MSG_REQR(X)	(u32 *)(PCIE_APP_PORT_TO_BASE(X) + 0x60)

#define PCIE_VM_MSG_REQR_REQ		0x00000001


/* AHB Slave Side Band Control Register */
#define PCIE_AHB_SSB(X)		(u32 *)(PCIE_APP_PORT_TO_BASE(X) + 0x70)

#define PCIE_AHB_SSB_REQ_BCM		0x00000001
#define PCIE_AHB_SSB_REQ_EP		0x00000002
#define PCIE_AHB_SSB_REQ_TD		0x00000004
#define PCIE_AHB_SSB_REQ_ATTR		0x00000018
#define PCIE_AHB_SSB_REQ_ATTR_S		3
#define PCIE_AHB_SSB_REQ_TC		0x000000E0
#define PCIE_AHB_SSB_REQ_TC_S		5

/* AHB Master SideBand Ctrl Register */
#define PCIE_AHB_MSB(X)		(u32 *)(PCIE_APP_PORT_TO_BASE(X) + 0x74)

#define PCIE_AHB_MSB_RESP_ATTR		0x00000003
#define PCIE_AHB_MSB_RESP_ATTR_S	0
#define PCIE_AHB_MSB_RESP_BAD_EOT	0x00000004
#define PCIE_AHB_MSB_RESP_BCM		0x00000008
#define PCIE_AHB_MSB_RESP_EP		0x00000010
#define PCIE_AHB_MSB_RESP_TD		0x00000020
#define PCIE_AHB_MSB_RESP_FUN_NUM	0x000003C0
#define PCIE_AHB_MSB_RESP_FUN_NUM_S	6

/* AHB Control Register, fixed bus enumeration exception */
#define PCIE_AHB_CTRL(X)	(u32 *)(PCIE_APP_PORT_TO_BASE(X) + 0x78)

#define PCIE_AHB_CTRL_BUS_ERROR_SUPPRESS	0x00000001

/* Interrupt Enalbe Register */
#define PCIE_IRNEN(X)		(u32 *)(PCIE_APP_PORT_TO_BASE(X) + 0xF4)

#define PCIE_IRNCR(X)		(u32 *)(PCIE_APP_PORT_TO_BASE(X) + 0xF8)

#define PCIE_IRNICR(X)		(u32 *)(PCIE_APP_PORT_TO_BASE(X) + 0xFC)

/* PCIe interrupt enable/control/capture register definition */
#define PCIE_IRN_AER_REPORT		0x00000001
#define PCIE_IRN_AER_MSIX		0x00000002
#define PCIE_IRN_PME			0x00000004
#define PCIE_IRN_HOTPLUG		0x00000008
#define PCIE_IRN_RX_VDM_MSG		0x00000010
#define PCIE_IRN_RX_CORRECTABLE_ERR_MSG	0x00000020
#define PCIE_IRN_RX_NON_FATAL_ERR_MSG	0x00000040
#define PCIE_IRN_RX_FATAL_ERR_MSG	0x00000080
#define PCIE_IRN_RX_PME_MSG		0x00000100
#define PCIE_IRN_RX_PME_TURNOFF_ACK	0x00000200
#define PCIE_IRN_AHB_BR_FATAL_ERR	0x00000400
#define PCIE_IRN_LINK_AUTO_BW_STATUS	0x00000800
#define PCIE_IRN_BW_MGT			0x00001000
#define PCIE_IRN_INTA			0x00002000 /* INTA */
#define PCIE_IRN_INTB			0x00004000 /* INTB */
#define PCIE_IRN_INTC			0x00008000 /* INTC */
#define PCIE_IRN_INTD			0x00010000 /* INTD */
#define PCIE_IRN_WAKEUP			0x00020000 /* Wake up Interrupt */

#define PCIE_RC_CORE_COMBINED_INT  (PCIE_IRN_AER_REPORT | PCIE_IRN_AER_MSIX \
		| PCIE_IRN_PME | PCIE_IRN_HOTPLUG | PCIE_IRN_RX_VDM_MSG \
		| PCIE_IRN_RX_CORRECTABLE_ERR_MSG \
		| PCIE_IRN_RX_NON_FATAL_ERR_MSG | PCIE_IRN_RX_FATAL_ERR_MSG \
		| PCIE_IRN_RX_PME_MSG | PCIE_IRN_RX_PME_TURNOFF_ACK \
		| PCIE_IRN_AHB_BR_FATAL_ERR | PCIE_IRN_LINK_AUTO_BW_STATUS\
		| PCIE_IRN_BW_MGT)

/* PCIe RC Configuration Register */
#define PCIE_VDID(X)		(u32 *)(PCIE_RC_PORT_TO_BASE(X) + 0x00)

/* Bit definition from pci_reg.h */
#define PCIE_PCICMDSTS(X)	(u32 *)(PCIE_RC_PORT_TO_BASE(X) + 0x04)
#define PCIE_CCRID(X)		(u32 *)(PCIE_RC_PORT_TO_BASE(X) + 0x08)

#define PCIE_CLSLTHTBR(X)	(u32 *)(PCIE_RC_PORT_TO_BASE(X) + 0x0C)

/* BAR0, BAR1,Only necessary if the bridges implements a device-specific
   register set or memory buffer */
#define PCIE_BAR0(X)		(u32 *)(PCIE_RC_PORT_TO_BASE(X) + 0x10)

#define PCIE_BAR1(X)		(u32 *)(PCIE_RC_PORT_TO_BASE(X) + 0x14)

#define PCIE_BNR(X)		(u32 *)(PCIE_RC_PORT_TO_BASE(X) + 0x18)
/* Bus Number Register bits */
#define PCIE_BNR_PRIMARY_BUS_NUM	0x000000FF
#define PCIE_BNR_PRIMARY_BUS_NUM_S	0
#define PCIE_PNR_SECONDARY_BUS_NUM	0x0000FF00
#define PCIE_PNR_SECONDARY_BUS_NUM_S	8
#define PCIE_PNR_SUB_BUS_NUM	0x00FF0000
#define PCIE_PNR_SUB_BUS_NUM_S	16

/* IO Base/Limit Register bits */
#define PCIE_IOBLSECS(X)	(u32 *)(PCIE_RC_PORT_TO_BASE(X) + 0x1C)

#define PCIE_IOBLSECS_32BIT_IO_ADDR	0x00000001
#define PCIE_IOBLSECS_IO_BASE_ADDR	0x000000F0
#define PCIE_IOBLSECS_IO_BASE_ADDR_S	4
#define PCIE_IOBLSECS_32BIT_IOLIMT	0x00000100
#define PCIE_IOBLSECS_IO_LIMIT_ADDR	0x0000F000
#define PCIE_IOBLSECS_IO_LIMIT_ADDR_S	12

/* Non-prefetchable Memory Base/Limit Register bit */
#define PCIE_MBML(X)		(u32 *)(PCIE_RC_PORT_TO_BASE(X) + 0x20)

#define PCIE_MBML_MEM_BASE_ADDR		0x0000FFF0
#define PCIE_MBML_MEM_BASE_ADDR_S	4
#define PCIE_MBML_MEM_LIMIT_ADDR	0xFFF00000
#define PCIE_MBML_MEM_LIMIT_ADDR_S	20

/* Prefetchable Memory Base/Limit Register bit */
#define PCIE_PMBL(X)		(u32 *)(PCIE_RC_PORT_TO_BASE(X) + 0x24)
#define PCIE_PMBL_64BIT_ADDR		0x00000001
#define PCIE_PMBL_UPPER_12BIT		0x0000FFF0
#define PCIE_PMBL_UPPER_12BIT_S		4
#define PCIE_PMBL_E64MA			0x00010000
#define PCIE_PMBL_END_ADDR		0xFFF00000
#define PCIE_PMBL_END_ADDR_S		20

#define PCIE_PMBU32(X)		(u32 *)(PCIE_RC_PORT_TO_BASE(X) + 0x28)

#define PCIE_PMLU32(X)		(u32 *)(PCIE_RC_PORT_TO_BASE(X) + 0x2C)

/* I/O Base/Limit Upper 16 bits register */
#define PCIE_IO_BANDL(X)	(u32 *)(PCIE_RC_PORT_TO_BASE(X) + 0x30)

#define PCIE_IO_BANDL_UPPER_16BIT_IO_BASE	0x0000FFFF
#define PCIE_IO_BANDL_UPPER_16BIT_IO_BASE_S	0
#define PCIE_IO_BANDL_UPPER_16BIT_IO_LIMIT	0xFFFF0000
#define PCIE_IO_BANDL_UPPER_16BIT_IO_LIMIT_S	16

#define PCIE_CPR(X)		(u32 *)(PCIE_RC_PORT_TO_BASE(X) + 0x34)

#define PCIE_EBBAR(X)		(u32 *)(PCIE_RC_PORT_TO_BASE(X) + 0x38)

/* Interrupt and Secondary Bridge Control Register */
#define PCIE_INTRBCTRL(X)	(u32 *)(PCIE_RC_PORT_TO_BASE(X) + 0x3C)

#define PCIE_INTRBCTRL_INT_LINE			0x000000FF
#define PCIE_INTRBCTRL_INT_LINE_S		0
#define PCIE_INTRBCTRL_INT_PIN			0x0000FF00
#define PCIE_INTRBCTRL_INT_PIN_S		8
#define PCIE_INTRBCTRL_PARITY_ERR_RESP_ENABLE	0x00010000
#define PCIE_INTRBCTRL_SERR_ENABLE		0x00020000
#define PCIE_INTRBCTRL_ISA_ENABLE		0x00040000
#define PCIE_INTRBCTRL_VGA_ENABLE		0x00080000
#define PCIE_INTRBCTRL_VGA_16BIT_DECODE		0x00100000
#define PCIE_INTRBCTRL_RST_SECONDARY_BUS	0x00400000
/* Others are read only */
enum {
	PCIE_INTRBCTRL_INT_NON = 0,
	PCIE_INTRBCTRL_INTA,
	PCIE_INTRBCTRL_INTB,
	PCIE_INTRBCTRL_INTC,
	PCIE_INTRBCTRL_INTD,
};

#define PCIE_PM_CAPR(X)		(u32 *)(PCIE_RC_PORT_TO_BASE(X) + 0x40)

/* Power Management Control and Status Register */
#define PCIE_PM_CSR(X)		(u32 *)(PCIE_RC_PORT_TO_BASE(X) + 0x44)

#define PCIE_PM_CSR_POWER_STATE		0x00000003 /* Power State */
#define PCIE_PM_CSR_POWER_STATE_S	0
#define PCIE_PM_CSR_SW_RST		0x00000008 /* Soft Reset Enabled */
#define PCIE_PM_CSR_PME_ENABLE		0x00000100 /* PME Enable */
#define PCIE_PM_CSR_PME_STATUS		0x00008000 /* PME status */

/* MSI Capability Register for EP */
#define PCIE_MCAPR(X)		(u32 *)(PCIE_RC_PORT_TO_BASE(X) + 0x50)

#define PCIE_MCAPR_MSI_CAP_ID		0x000000FF
#define PCIE_MCAPR_MSI_CAP_ID_S		0
#define PCIE_MCAPR_MSI_NEXT_CAP_PTR	0x0000FF00
#define PCIE_MCAPR_MSI_NEXT_CAP_PTR_S	8
#define PCIE_MCAPR_MSI_ENABLE		0x00010000
#define PCIE_MCAPR_MULTI_MSG_CAP	0x000E0000
#define PCIE_MCAPR_MULTI_MSG_CAP_S	17
#define PCIE_MCAPR_MULTI_MSG_ENABLE	0x00700000
#define PCIE_MCAPR_MULTI_MSG_ENABLE_S	20
#define PCIE_MCAPR_ADDR64_CAP		0X00800000

/* MSI Message Address Register */
#define PCIE_MA(X)		(u32 *)(PCIE_RC_PORT_TO_BASE(X) + 0x54)

#define PCIE_MA_ADDR_MASK		0xFFFFFFFC /* Message Address */

/* MSI Message Upper Address Register */
#define PCIE_MUA(X)		(u32 *)(PCIE_RC_PORT_TO_BASE(X) + 0x58)

/* MSI Message Data Register */
#define PCIE_MD(X)		(u32 *)(PCIE_RC_PORT_TO_BASE(X) + 0x5C)

#define PCIE_MD_DATA			0x0000FFFF /* Message Data */
#define PCIE_MD_DATA_S			0

/* PCI Express Capability Register */
#define PCIE_XCAP(X)		(u32 *)(PCIE_RC_PORT_TO_BASE(X) + 0x70)

#define PCIE_XCAP_ID			0x000000FF
#define PCIE_XCAP_ID_S			0
#define PCIE_XCAP_NEXT_CAP		0x0000FF00
#define PCIE_XCAP_NEXT_CAP_S		8
#define PCIE_XCAP_VER			0x000F0000
#define PCIE_XCAP_VER_S			16
#define PCIE_XCAP_DEV_PORT_TYPE		0x00F00000
#define PCIE_XCAP_DEV_PORT_TYPE_S	20
#define PCIE_XCAP_SLOT_IMPLEMENTED	0x01000000
#define PCIE_XCAP_MSG_INT_NUM		0x3E000000
#define PCIE_XCAP_MSG_INT_NUM_S		25

/* Device Capability Register */
#define PCIE_DCAP(X)		(u32 *)(PCIE_RC_PORT_TO_BASE(X) + 0x74)

#define PCIE_DCAP_MAX_PAYLOAD_SIZE	0x00000007
#define PCIE_DCAP_MAX_PAYLOAD_SIZE_S	0
#define PCIE_DCAP_PHANTOM_FUNC		0x00000018
#define PCIE_DCAP_PHANTOM_FUNC_S	3
#define PCIE_DCAP_EXT_TAG		0x00000020
#define PCIE_DCAP_EP_L0S_LATENCY	0x000001C0
#define PCIE_DCAP_EP_L0S_LATENCY_S	6
#define PCIE_DCAP_EP_L1_LATENCY		0x00000E00
#define PCIE_DCAP_EP_L1_LATENCY_S	9
#define PCIE_DCAP_ROLE_BASE_ERR_REPORT	0x00008000

/* Maximum payload size supported */
enum {
	PCIE_MAX_PAYLOAD_128 = 0,
	PCIE_MAX_PAYLOAD_256,
	PCIE_MAX_PAYLOAD_512,
	PCIE_MAX_PAYLOAD_1024,
	PCIE_MAX_PAYLOAD_2048,
	PCIE_MAX_PAYLOAD_4096,
};

/* Device Control and Status Register */
#define PCIE_DCTLSTS(X)		(u32 *)(PCIE_RC_PORT_TO_BASE(X) + 0x78)

#define PCIE_DCTLSTS_CORRECTABLE_ERR_EN		0x00000001
#define PCIE_DCTLSTS_NONFATAL_ERR_EN		0x00000002
#define PCIE_DCTLSTS_FATAL_ERR_EN		0x00000004
#define PCIE_DCTLSYS_UR_REQ_EN			0x00000008
#define PCIE_DCTLSTS_RELAXED_ORDERING_EN	0x00000010
#define PCIE_DCTLSTS_MAX_PAYLOAD_SIZE		0x000000E0
#define PCIE_DCTLSTS_MAX_PAYLOAD_SIZE_S		5
#define PCIE_DCTLSTS_EXT_TAG_EN			0x00000100
#define PCIE_DCTLSTS_PHANTOM_FUNC_EN		0x00000200
#define PCIE_DCTLSTS_AUX_PM_EN			0x00000400
#define PCIE_DCTLSTS_NO_SNOOP_EN		0x00000800
#define PCIE_DCTLSTS_MAX_READ_SIZE		0x00007000
#define PCIE_DCTLSTS_MAX_READ_SIZE_S		12
#define PCIE_DCTLSTS_CORRECTABLE_ERR		0x00010000
#define PCIE_DCTLSTS_NONFATAL_ERR		0x00020000
#define PCIE_DCTLSTS_FATAL_ER			0x00040000
#define PCIE_DCTLSTS_UNSUPPORTED_REQ		0x00080000
#define PCIE_DCTLSTS_AUX_POWER			0x00100000
#define PCIE_DCTLSTS_TRANSACT_PENDING	0x00200000

#define PCIE_DCTLSTS_ERR_EN	(PCIE_DCTLSTS_CORRECTABLE_ERR_EN | \
		PCIE_DCTLSTS_NONFATAL_ERR_EN | PCIE_DCTLSTS_FATAL_ERR_EN \
		| PCIE_DCTLSYS_UR_REQ_EN)

/* Link Capability Register */
#define PCIE_LCAP(X)		(u32 *)(PCIE_RC_PORT_TO_BASE(X) + 0x7C)
#define PCIE_LCAP_MAX_LINK_SPEED		0x0000000F
#define PCIE_LCAP_MAX_LINK_SPEED_S		0
#define PCIE_LCAP_MAX_LENGTH_WIDTH		0x000003F0
#define PCIE_LCAP_MAX_LENGTH_WIDTH_S		4
#define PCIE_LCAP_ASPM_LEVEL			0x00000C00
#define PCIE_LCAP_ASPM_LEVEL_S			10
#define PCIE_LCAP_L0S_EIXT_LATENCY		0x00007000
#define PCIE_LCAP_L0S_EIXT_LATENCY_S		12
#define PCIE_LCAP_L1_EXIT_LATENCY		0x00038000
#define PCIE_LCAP_L1_EXIT_LATENCY_S		15
#define PCIE_LCAP_CLK_PM			0x00040000
#define PCIE_LCAP_SDER				0x00080000
#define PCIE_LCAP_DLL_ACTIVE_REPROT		0x00100000
#define PCIE_LCAP_PORT_NUM			0xFF000000
#define PCIE_LCAP_PORT_NUM_S			24

/* Maximum Length width definition */
#define PCIE_MAX_LENGTH_WIDTH_RES		0x00
#define PCIE_MAX_LENGTH_WIDTH_X1		0x01 /* Default */
#define PCIE_MAX_LENGTH_WIDTH_X2		0x02
#define PCIE_MAX_LENGTH_WIDTH_X4		0x04
#define PCIE_MAX_LENGTH_WIDTH_X8		0x08
#define PCIE_MAX_LENGTH_WIDTH_X12		0x0C
#define PCIE_MAX_LENGTH_WIDTH_X16		0x10
#define PCIE_MAX_LENGTH_WIDTH_X32		0x20

/* Active State Link PM definition */
enum {
	PCIE_ASPM_RES0 = 0,
	PCIE_ASPM_L0S_ENTRY_SUPPORT, /* L0s */
	PCIE_ASPM_RES1,
	PCIE_ASPM_L0S_L1_ENTRY_SUPPORT, /* L0s and L1, default */
};

/* L0s Exit Latency definition */
enum {
	PCIE_L0S_EIXT_LATENCY_L64NS = 0, /* < 64 ns */
	PCIE_L0S_EIXT_LATENCY_B64A128,  /* > 64 ns < 128 ns */
	PCIE_L0S_EIXT_LATENCY_B128A256, /* > 128 ns < 256 ns */
	PCIE_L0S_EIXT_LATENCY_B256A512, /* > 256 ns < 512 ns */
	PCIE_L0S_EIXT_LATENCY_B512TO1U, /* > 512 ns < 1 us */
	PCIE_L0S_EIXT_LATENCY_B1A2U, /* > 1 us < 2 us */
	PCIE_L0S_EIXT_LATENCY_B2A4U, /* > 2 us < 4 us */
	PCIE_L0S_EIXT_LATENCY_M4US, /* > 4 us  */
};

/* L1 Exit Latency definition */
enum {
	PCIE_L1_EXIT_LATENCY_L1US = 0, /* < 1 us */
	PCIE_L1_EXIT_LATENCY_B1A2,     /* > 1 us < 2 us */
	PCIE_L1_EXIT_LATENCY_B2A4,     /* > 2 us < 4 us */
	PCIE_L1_EXIT_LATENCY_B4A8,     /* > 4 us < 8 us */
	PCIE_L1_EXIT_LATENCY_B8A16,    /* > 8 us < 16 us */
	PCIE_L1_EXIT_LATENCY_B16A32,   /* > 16 us < 32 us */
	PCIE_L1_EXIT_LATENCY_B32A64,   /* > 32 us < 64 us */
	PCIE_L1_EXIT_LATENCY_M64US,    /* > 64 us */
};

/* Link Control and Status Register */
#define PCIE_LCTLSTS(X)		(u32 *)(PCIE_RC_PORT_TO_BASE(X) + 0x80)
#define PCIE_LCTLSTS_ASPM_ENABLE		0x00000003
#define PCIE_LCTLSTS_ASPM_ENABLE_S		0
#define PCIE_LCTLSTS_RCB128			0x00000008
#define PCIE_LCTLSTS_LINK_DISABLE		0x00000010
#define PCIE_LCTLSTS_RETRIAN_LINK		0x00000020
#define PCIE_LCTLSTS_COM_CLK_CFG		0x00000040
#define PCIE_LCTLSTS_EXT_SYNC			0x00000080
#define PCIE_LCTLSTS_CLK_PM_EN			0x00000100
#define PCIE_LCTLSTS_LINK_SPEED			0x000F0000
#define PCIE_LCTLSTS_LINK_SPEED_S		16
#define PCIE_LCTLSTS_NEGOTIATED_LINK_WIDTH	0x03F00000
#define PCIE_LCTLSTS_NEGOTIATED_LINK_WIDTH_S	20
#define PCIE_LCTLSTS_RETRAIN_PENDING		0x08000000
#define PCIE_LCTLSTS_SLOT_CLK_CFG		0x10000000
#define PCIE_LCTLSTS_DLL_ACTIVE			0x20000000

/* Slot Capabilities Register */
#define PCIE_SLCAP(X)		(u32 *)(PCIE_RC_PORT_TO_BASE(X) + 0x84)

/* Slot Capabilities */
#define PCIE_SLCTLSTS(X)	(u32 *)(PCIE_RC_PORT_TO_BASE(X) + 0x88)

/* Root Control and Capability Register */
#define PCIE_RCTLCAP(X)		(u32 *)(PCIE_RC_PORT_TO_BASE(X) + 0x8C)

#define PCIE_RCTLCAP_SERR_ON_CORRECTABLE_ERR	0x00000001
#define PCIE_RCTLCAP_SERR_ON_NONFATAL_ERR	0x00000002
#define PCIE_RCTLCAP_SERR_ON_FATAL_ERR		0x00000004
#define PCIE_RCTLCAP_PME_INT_EN	0x00000008
#define PCIE_RCTLCAP_SERR_ENABLE	(PCIE_RCTLCAP_SERR_ON_CORRECTABLE_ERR \
		| PCIE_RCTLCAP_SERR_ON_NONFATAL_ERR \
		| PCIE_RCTLCAP_SERR_ON_FATAL_ERR)
/* Root Status Register */
#define PCIE_RSTS(X)		(u32 *)(PCIE_RC_PORT_TO_BASE(X) + 0x90)

#define PCIE_RSTS_PME_REQ_ID		0x0000FFFF
#define PCIE_RSTS_PME_REQ_ID_S		0
#define PCIE_RSTS_PME_STATUS		0x00010000
#define PCIE_RSTS_PME_PENDING		0x00020000

/* PCI Express Enhanced Capability Header */
#define PCIE_ENHANCED_CAP(X)		(u32 *)(PCIE_RC_PORT_TO_BASE(X) + 0x100)

#define PCIE_ENHANCED_CAP_ID			0x0000FFFF
#define PCIE_ENHANCED_CAP_ID_S			0
#define PCIE_ENHANCED_CAP_VER			0x000F0000
#define PCIE_ENHANCED_CAP_VER_S			16
#define PCIE_ENHANCED_CAP_NEXT_OFFSET		0xFFF00000
#define PCIE_ENHANCED_CAP_NEXT_OFFSET_S		20

/* Uncorrectable Error Status Register */
#define PCIE_UES_R(X)		(u32 *)(PCIE_RC_PORT_TO_BASE(X) + 0x104)

#define PCIE_DATA_LINK_PROTOCOL_ERR		0x00000010
#define PCIE_SURPRISE_DOWN_ERROR		0x00000020
#define PCIE_POISONED_TLP			0x00001000
#define PCIE_FC_PROTOCOL_ERR			0x00002000
#define PCIE_COMPLETION_TIMEOUT			0x00004000
#define PCIE_COMPLETOR_ABORT			0x00008000
#define PCIE_UNEXPECTED_COMPLETION		0x00010000
#define PCIE_RECEIVER_OVERFLOW			0x00020000
#define PCIE_MALFORNED_TLP			0x00040000
#define PCIE_ECRC_ERR				0x00080000
#define PCIE_UR_REQ				0x00100000
#define PCIE_ALL_UNCORRECTABLE_ERR	(PCIE_DATA_LINK_PROTOCOL_ERR |\
		PCIE_SURPRISE_DOWN_ERROR | PCIE_POISONED_TLP |\
		PCIE_FC_PROTOCOL_ERR | PCIE_COMPLETION_TIMEOUT | \
		PCIE_COMPLETOR_ABORT | PCIE_UNEXPECTED_COMPLETION |\
		PCIE_RECEIVER_OVERFLOW | PCIE_MALFORNED_TLP | \
		PCIE_ECRC_ERR | PCIE_UR_REQ)

/* Uncorrectable Error Mask Register, Mask means no report */
#define PCIE_UEMR(X)		(u32 *)(PCIE_RC_PORT_TO_BASE(X) + 0x108)

/* Uncorrectable Error Severity Register */
#define PCIE_UESR(X)		(u32 *)(PCIE_RC_PORT_TO_BASE(X) + 0x10C)

/* Correctable Error Status Register */
#define PCIE_CESR(X)		(u32 *)(PCIE_RC_PORT_TO_BASE(X) + 0x110)
#define PCIE_RX_ERR			0x00000001
#define PCIE_BAD_TLP			0x00000040
#define PCIE_BAD_DLLP			0x00000080
#define PCIE_REPLAY_NUM_ROLLOVER	0x00000100
#define PCIE_REPLAY_TIMER_TIMEOUT_ERR	0x00001000
#define PCIE_ADVISORY_NONFTAL_ERR	0x00002000
#define PCIE_CORRECTABLE_ERR	(PCIE_RX_ERR | PCIE_BAD_TLP | PCIE_BAD_DLLP \
		| PCIE_REPLAY_NUM_ROLLOVER | PCIE_REPLAY_TIMER_TIMEOUT_ERR\
		| PCIE_ADVISORY_NONFTAL_ERR)

/* Correctable Error Mask Register */
#define PCIE_CEMR(X)		(u32 *)(PCIE_RC_PORT_TO_BASE(X) + 0x114)

/* Advanced Error Capabilities and Control Register */
#define PCIE_AECCR(X)		(u32 *)(PCIE_RC_PORT_TO_BASE(X) + 0x118)

#define PCIE_AECCR_FIRST_ERR_PTR		0x0000001F
#define PCIE_AECCR_FIRST_ERR_PTR_S		0
#define PCIE_AECCR_ECRC_GEN_CAP			0x00000020
#define PCIE_AECCR_ECRC_GEN_EN			0x00000040
#define PCIE_AECCR_ECRC_CHECK_CAP		0x00000080
#define PCIE_AECCR_ECRC_CHECK_EN		0x00000100

/* Header Log Register 1 */
#define PCIE_HLR1(X)		(u32 *)(PCIE_RC_PORT_TO_BASE(X) + 0x11C)

/* Header Log Register 2 */
#define PCIE_HLR2(X)		(u32 *)(PCIE_RC_PORT_TO_BASE(X) + 0x120)

/* Header Log Register 3 */
#define PCIE_HLR3(X)		(u32 *)(PCIE_RC_PORT_TO_BASE(X) + 0x124)

/* Header Log Register 4 */
#define PCIE_HLR4(X)		(u32 *)(PCIE_RC_PORT_TO_BASE(X) + 0x128)

/* Root Error Command Register */
#define PCIE_RECR(X)		(u32 *)(PCIE_RC_PORT_TO_BASE(X) + 0x12C)

#define PCIE_RECR_CORRECTABLE_ERR_REPORT_EN	0x00000001 /* COR-ERR */
#define PCIE_RECR_NONFATAL_ERR_REPORT_EN	0x00000002 /* Non-Fatal ERR */
#define PCIE_RECR_FATAL_ERR_REPORT_EN		0x00000004 /* Fatal ERR */
#define PCIE_RECR_ERR_REPORT_EN	(PCIE_RECR_CORRECTABLE_ERR_REPORT_EN\
		| PCIE_RECR_NONFATAL_ERR_REPORT_EN |\
		PCIE_RECR_FATAL_ERR_REPORT_EN)

/* Root Error Status Register */
#define PCIE_RESR(X)		(u32 *)(PCIE_RC_PORT_TO_BASE(X) + 0x130)

#define PCIE_RESR_CORRECTABLE_ERR		0x00000001
#define PCIE_RESR_MULTI_CORRECTABLE_ERR		0x00000002
#define PCIE_RESR_FATAL_NOFATAL_ERR		0x00000004
#define PCIE_RESR_MULTI_FATAL_NOFATAL_ERR	0x00000008
#define PCIE_RESR_FIRST_UNCORRECTABLE_FATAL_ERR	0x00000010
#define PCIR_RESR_NON_FATAL_ERR			0x00000020
#define PCIE_RESR_FATAL_ERR			0x00000040
#define PCIE_RESR_AER_INT_MSG_NUM		0xF8000000
#define PCIE_RESR_AER_INT_MSG_NUM_S		27

/* Error Source Indentification Register */
#define PCIE_ESIR(X)		(u32 *)(PCIE_RC_PORT_TO_BASE(X) + 0x134)

#define PCIE_ESIR_CORRECTABLE_ERR_SRC_ID	0x0000FFFF
#define PCIE_ESIR_CORRECTABLE_ERR_SRC_ID_S	0
#define PCIE_ESIR_FATAL_NON_FATAL_SRC_ID	0xFFFF0000
#define PCIE_ESIR_FATAL_NON_FATAL_SRC_ID_S	16

/* VC Enhanced Capability Header */
#define PCIE_VC_ECH(X)		(u32 *)(PCIE_RC_PORT_TO_BASE(X) + 0x140)

/* Port VC Capability Register */
#define PCIE_PVC1(X)		(u32 *)(PCIE_RC_PORT_TO_BASE(X) + 0x144)

#define PCIE_PVC1_EXT_VC_CNT			0x00000007
#define PCIE_PVC1_EXT_VC_CNT_S			0
#define PCIE_PVC1_LOW_PRI_EXT_VC_CNT		0x00000070
#define PCIE_PVC1_LOW_PRI_EXT_VC_CNT_S		4
#define PCIE_PVC1_REF_CLK			0x00000300
#define PCIE_PVC1_REF_CLK_S			8
#define PCIE_PVC1_PORT_ARB_TAB_ENTRY_SIZE	0x00000C00
#define PCIE_PVC1_PORT_ARB_TAB_ENTRY_SIZE_S	10

/* Extended Virtual Channel Count Defintion */
#define PCIE_EXT_VC_CNT_MIN		0
#define PCIE_EXT_VC_CNT_MAX		7

/* Port Arbitration Table Entry Size Definition */
enum {
	PCIE_PORT_ARB_TAB_ENTRY_SIZE_S1BIT = 0,
	PCIE_PORT_ARB_TAB_ENTRY_SIZE_S2BIT,
	PCIE_PORT_ARB_TAB_ENTRY_SIZE_S4BIT,
	PCIE_PORT_ARB_TAB_ENTRY_SIZE_S8BIT,
};

/* Port VC Capability Register 2 */
#define PCIE_PVC2(X)		(u32 *)(PCIE_RC_PORT_TO_BASE(X) + 0x148)

#define PCIE_PVC2_VC_ARB_16P_FIXED_WRR		0x00000001
#define PCIE_PVC2_VC_ARB_32P_WRR		0x00000002
#define PCIE_PVC2_VC_ARB_64P_WRR		0x00000004
#define PCIE_PVC2_VC_ARB_128P_WRR		0x00000008
#define PCIE_PVC2_VC_ARB_WRR			0x0000000F
#define PCIE_PVC2_VC_ARB_TAB_OFFSET		0xFF000000
#define PCIE_PVC2_VC_ARB_TAB_OFFSET_S		24

/* Port VC Control and Status Register */
#define PCIE_PVCCRSR(X)		(u32 *)(PCIE_RC_PORT_TO_BASE(X) + 0x14C)

#define PCIE_PVCCRSR_LOAD_VC_ARB_TAB		0x00000001
#define PCIE_PVCCRSR_VC_ARB_SEL			0x0000000E
#define PCIE_PVCCRSR_VC_ARB_SEL_S		1
#define PCIE_PVCCRSR_VC_ARB_TAB_STATUS		0x00010000

/* VC0 Resource Capability Register */
#define PCIE_VC0_RC(X)		(u32 *)(PCIE_RC_PORT_TO_BASE(X) + 0x150)

#define PCIE_VC0_RC_PORT_ARB_HW_FIXED		0x00000001
#define PCIE_VC0_RC_PORT_ARB_32P_WRR		0x00000002
#define PCIE_VC0_RC_PORT_ARB_64P_WRR		0x00000004
#define PCIE_VC0_RC_PORT_ARB_128P_WRR		0x00000008
#define PCIE_VC0_RC_PORT_ARB_TM_128P_WRR	0x00000010
#define PCIE_VC0_RC_PORT_ARB_TM_256P_WRR	0x00000020
#define PCIE_VC0_RC_PORT_ARB	(PCIE_VC0_RC_PORT_ARB_HW_FIXED |\
		PCIE_VC0_RC_PORT_ARB_32P_WRR | PCIE_VC0_RC_PORT_ARB_64P_WRR |\
		PCIE_VC0_RC_PORT_ARB_128P_WRR |\
		PCIE_VC0_RC_PORT_ARB_TM_128P_WRR |\
		PCIE_VC0_RC_PORT_ARB_TM_256P_WRR)

#define PCIE_VC0_RC_REJECT_SNOOP		0x00008000
#define PCIE_VC0_RC_MAX_TIMESLOTS		0x007F0000
#define PCIE_VC0_RC_MAX_TIMESLOTS_S		16
#define PCIE_VC0_RC_PORT_ARB_TAB_OFFSET		0xFF000000
#define PCIE_VC0_RC_PORT_ARB_TAB_OFFSET_S	24

/* VC0 Resource Control Register */
#define PCIE_VC0_RC0(X)			(u32 *)(PCIE_RC_PORT_TO_BASE(X) + 0x154)

#define PCIE_VC0_RC0_TVM0			0x00000001
#define PCIE_VC0_RC0_TVM1			0x00000002
#define PCIE_VC0_RC0_TVM2			0x00000004
#define PCIE_VC0_RC0_TVM3			0x00000008
#define PCIE_VC0_RC0_TVM4			0x00000010
#define PCIE_VC0_RC0_TVM5			0x00000020
#define PCIE_VC0_RC0_TVM6			0x00000040
#define PCIE_VC0_RC0_TVM7			0x00000080
#define PCIE_VC0_RC0_TC_VC			0x000000FF

#define PCIE_VC0_RC0_LOAD_PORT_ARB_TAB		0x00010000
#define PCIE_VC0_RC0_PORT_ARB_SEL		0x000E0000
#define PCIE_VC0_RC0_PORT_ARB_SEL_S		17
#define PCIE_VC0_RC0_VC_ID			0x07000000
#define PCIE_VC0_RC0_VC_ID_S			24
#define PCIE_VC0_RC0_VC_EN			0x80000000

/* VC0 Resource Status Register */
#define PCIE_VC0_RSR0(X)	(u32 *)(PCIE_RC_PORT_TO_BASE(X) + 0x158)

#define PCIE_VC0_RSR0_PORT_ARB_TAB_STATUS	0x00010000
#define PCIE_VC0_RSR0_VC_NEG_PENDING		0x00020000

/* Ack Latency Timer and Replay Timer Register */
#define PCIE_ALTRT(X)		(u32 *)(PCIE_RC_PORT_TO_BASE(X) + 0x700)

#define PCIE_ALTRT_ROUND_TRIP_LATENCY_LIMIT	0x0000FFFF
#define PCIE_ALTRT_ROUND_TRIP_LATENCY_LIMIT_S	0
#define PCIE_ALTRT_REPLAY_TIME_LIMIT		0xFFFF0000
#define PCIE_ALTRT_REPLAY_TIME_LIMIT_S		16

/* Other Message Register */
#define PCIE_OMR(X)		(u32 *)(PCIE_RC_PORT_TO_BASE(X) + 0x704)

/* Port Force Link Register */
#define PCIE_PFLR(X)		(u32 *)(PCIE_RC_PORT_TO_BASE(X) + 0x708)

#define PCIE_PFLR_LINK_NUM			0x000000FF
#define PCIE_PFLR_LINK_NUM_S			0
#define PCIE_PFLR_FORCE_LINK			0x00008000
#define PCIE_PFLR_LINK_STATE			0x003F0000
#define PCIE_PFLR_LINK_STATE_S			16
#define PCIE_PFLR_LOW_POWER_ENTRY_CNT		0xFF000000
#define PCIE_PFLR_LOW_POWER_ENTRY_CNT_S		24

/* Ack Frequency Register */
#define PCIE_AFR(X)		(u32 *)(PCIE_RC_PORT_TO_BASE(X) + 0x70C)

#define PCIE_AFR_AF			0x000000FF
#define PCIE_AFR_AF_S			0
#define PCIE_AFR_FTS_NUM		0x0000FF00
#define PCIE_AFR_FTS_NUM_S		8
#define PCIE_AFR_COM_FTS_NUM		0x00FF0000
#define PCIE_AFR_COM_FTS_NUM_S		16
#define PCIE_AFR_L0S_ENTRY_LATENCY	0x07000000
#define PCIE_AFR_L0S_ENTRY_LATENCY_S	24
#define PCIE_AFR_L1_ENTRY_LATENCY	0x38000000
#define PCIE_AFR_L1_ENTRY_LATENCY_S	27
#define PCIE_AFR_FTS_NUM_DEFAULT	32
#define PCIE_AFR_L0S_ENTRY_LATENCY_DEFAULT	7
#define PCIE_AFR_L1_ENTRY_LATENCY_DEFAULT	5

/* Port Link Control Register */
#define PCIE_PLCR(X)		(u32 *)(PCIE_RC_PORT_TO_BASE(X) + 0x710)

#define PCIE_PLCR_OTHER_MSG_REQ		0x00000001
#define PCIE_PLCR_SCRAMBLE_DISABLE	0x00000002
#define PCIE_PLCR_LOOPBACK_EN		0x00000004
#define PCIE_PLCR_LTSSM_HOT_RST		0x00000008
#define PCIE_PLCR_DLL_LINK_EN		0x00000020
#define PCIE_PLCR_FAST_LINK_SIM_EN	0x00000080
#define PCIE_PLCR_LINK_MODE		0x003F0000
#define PCIE_PLCR_LINK_MODE_S		16
#define PCIE_PLCR_CORRUPTED_CRC_EN	0x02000000

/* Lane Skew Register */
#define PCIE_LSR(X)		(u32 *)(PCIE_RC_PORT_TO_BASE(X) + 0x714)

#define PCIE_LSR_LANE_SKEW_NUM		0x00FFFFFF
#define PCIE_LSR_LANE_SKEW_NUM_S	0
#define PCIE_LSR_FC_DISABLE		0x01000000
#define PCIE_LSR_ACKNAK_DISABLE		0x02000000
#define PCIE_LSR_LANE_DESKEW_DISABLE	0x80000000

/* Symbol Number Register */
#define PCIE_SNR(X)		(u32 *)(PCIE_RC_PORT_TO_BASE(X) + 0x718)

#define PCIE_SNR_TS			0x0000000F
#define PCIE_SNR_TS_S			0
#define PCIE_SNR_SKP			0x00000700
#define PCIE_SNR_SKP_S			8
#define PCIE_SNR_REPLAY_TIMER		0x0007C000
#define PCIE_SNR_REPLAY_TIMER_S		14
#define PCIE_SNR_ACKNAK_LATENCY_TIMER	0x00F80000
#define PCIE_SNR_ACKNAK_LATENCY_TIMER_S	19
#define PCIE_SNR_FC_TIMER		0x1F000000
#define PCIE_SNR_FC_TIMER_S		28

/* Symbol Timer Register and Filter Mask Register 1 */
#define PCIE_STRFMR(X)		(u32 *)(PCIE_RC_PORT_TO_BASE(X) + 0x71C)

#define PCIE_STRFMR_SKP_INTERVAL		0x000007FF
#define PCIE_STRFMR_SKP_INTERVAL_S		0
#define PCIE_STRFMR_FC_WDT_DISABLE		0x00008000
#define PCIE_STRFMR_TLP_FUNC_MISMATCH_OK	0x00010000
#define PCIE_STRFMR_POISONED_TLP_OK		0x00020000
#define PCIE_STRFMR_BAR_MATCH_OK		0x00040000
#define PCIE_STRFMR_TYPE1_CFG_REQ_OK		0x00080000
#define PCIE_STRFMR_LOCKED_REQ_OK		0x00100000
#define PCIE_STRFMR_CPL_TAG_ERR_RULES_OK	0x00200000
#define PCIE_STRFMR_CPL_REQUESTOR_ID_MISMATCH_OK	0x00400000
#define PCIE_STRFMR_CPL_FUNC_MISMATCH_OK	0x00800000
#define PCIE_STRFMR_CPL_TC_MISMATCH_OK		0x01000000
#define PCIE_STRFMR_CPL_ATTR_MISMATCH_OK	0x02000000
#define PCIE_STRFMR_CPL_LENGTH_MISMATCH_OK	0x04000000
#define PCIE_STRFMR_TLP_ECRC_ERR_OK		0x08000000
#define PCIE_STRFMR_CPL_TLP_ECRC_OK		0x10000000
#define PCIE_STRFMR_RX_TLP_MSG_NO_DROP		0x20000000
#define PCIE_STRFMR_RX_IO_TRANS_ENABLE		0x40000000
#define PCIE_STRFMR_RX_CFG_TRANS_ENABLE		0x80000000

#define PCIE_DEF_SKP_INTERVAL	700 /* 1180 ~1538 , 125MHz * 2, 250MHz * 1 */

/* Filter Masker Register 2 */
#define PCIE_FMR2(X)		(u32 *)(PCIE_RC_PORT_TO_BASE(X) + 0x720)

#define PCIE_FMR2_VENDOR_MSG0_PASSED_TO_TRGT1	0x00000001
#define PCIE_FMR2_VENDOR_MSG1_PASSED_TO_TRGT1	0x00000002

/* Debug Register 0 */
#define PCIE_DBR0(X)		(u32 *)(PCIE_RC_PORT_TO_BASE(X) + 0x728)

/* Debug Register 1 */
#define PCIE_DBR1(X)		(u32 *)(PCIE_RC_PORT_TO_BASE(X) + 0x72C)

/* Transmit Posted FC Credit Status Register */
#define PCIE_TPFCS(X)		(u32 *)(PCIE_RC_PORT_TO_BASE(X) + 0x730)

#define PCIE_TPFCS_TX_P_DATA_FC_CREDITS		0x00000FFF
#define PCIE_TPFCS_TX_P_DATA_FC_CREDITS_S	0
#define PCIE_TPFCS_TX_P_HDR_FC_CREDITS		0x000FF000
#define PCIE_TPFCS_TX_P_HDR_FC_CREDITS_S	12

/* Transmit Non-Posted FC Credit Status */
#define PCIE_TNPFCS(X)		(u32 *)(PCIE_RC_PORT_TO_BASE(X) + 0x734)

#define PCIE_TNPFCS_TX_NP_DATA_FC_CREDITS	0x00000FFF
#define PCIE_TNPFCS_TX_NP_DATA_FC_CREDITS_S	0
#define PCIE_TNPFCS_TX_NP_HDR_FC_CREDITS	0x000FF000
#define PCIE_TNPFCS_TX_NP_HDR_FC_CREDITS_S	12

/* Transmit Complete FC Credit Status Register */
#define PCIE_TCFCS(X)		(u32 *)(PCIE_RC_PORT_TO_BASE(X) + 0x738)

#define PCIE_TCFCS_TX_CPL_DATA_FC_CREDITS	0x00000FFF
#define PCIE_TCFCS_TX_CPL_DATA_FC_CREDITS_S	0
#define PCIE_TCFCS_TX_CPL_HDR_FC_CREDITS	0x000FF000
#define PCIE_TCFCS_TX_CPL_HDR_FC_CREDITS_S	12

/* Queue Status Register */
#define PCIE_QSR(X)		(u32 *)(PCIE_RC_PORT_TO_BASE(X) + 0x73C)

#define PCIE_QSR_WAIT_UPDATE_FC_DLL		0x00000001
#define PCIE_QSR_TX_RETRY_BUF_NOT_EMPTY		0x00000002
#define PCIE_QSR_RX_QUEUE_NOT_EMPTY		0x00000004

/* VC Transmit Arbitration Register 1 */
#define PCIE_VCTAR1(X)		(u32 *)(PCIE_RC_PORT_TO_BASE(X) + 0x740)

#define PCIE_VCTAR1_WRR_WEIGHT_VC0		0x000000FF
#define PCIE_VCTAR1_WRR_WEIGHT_VC1		0x0000FF00
#define PCIE_VCTAR1_WRR_WEIGHT_VC2		0x00FF0000
#define PCIE_VCTAR1_WRR_WEIGHT_VC3		0xFF000000

/* VC Transmit Arbitration Register 2 */
#define PCIE_VCTAR2(X)		(u32 *)(PCIE_RC_PORT_TO_BASE(X) + 0x744)

#define PCIE_VCTAR2_WRR_WEIGHT_VC4		0x000000FF
#define PCIE_VCTAR2_WRR_WEIGHT_VC5		0x0000FF00
#define PCIE_VCTAR2_WRR_WEIGHT_VC6		0x00FF0000
#define PCIE_VCTAR2_WRR_WEIGHT_VC7		0xFF000000

/* VC0 Posted Receive Queue Control Register */
#define PCIE_VC0_PRQCR(X)	(u32 *)(PCIE_RC_PORT_TO_BASE(X) + 0x748)

#define PCIE_VC0_PRQCR_P_DATA_CREDITS		0x00000FFF
#define PCIE_VC0_PRQCR_P_DATA_CREDITS_S		0
#define PCIE_VC0_PRQCR_P_HDR_CREDITS		0x000FF000
#define PCIE_VC0_PRQCR_P_HDR_CREDITS_S		12
#define PCIE_VC0_PRQCR_P_TLP_QUEUE_MODE		0x00E00000
#define PCIE_VC0_PRQCR_P_TLP_QUEUE_MODE_S	20
#define PCIE_VC0_PRQCR_TLP_RELAX_ORDER		0x40000000
#define PCIE_VC0_PRQCR_VC_STRICT_ORDER		0x80000000

/* VC0 Non-Posted Receive Queue Control */
#define PCIE_VC0_NPRQCR(X)	(u32 *)(PCIE_RC_PORT_TO_BASE(X) + 0x74C)

#define PCIE_VC0_NPRQCR_NP_DATA_CREDITS		0x00000FFF
#define PCIE_VC0_NPRQCR_NP_DATA_CREDITS_S	0
#define PCIE_VC0_NPRQCR_NP_HDR_CREDITS		0x000FF000
#define PCIE_VC0_NPRQCR_NP_HDR_CREDITS_S	12
#define PCIE_VC0_NPRQCR_NP_TLP_QUEUE_MODE	0x00E00000
#define PCIE_VC0_NPRQCR_NP_TLP_QUEUE_MODE_S	20

/* VC0 Completion Receive Queue Control */
#define PCIE_VC0_CRQCR(X)	(u32 *)(PCIE_RC_PORT_TO_BASE(X) + 0x750)

#define PCIE_VC0_CRQCR_CPL_DATA_CREDITS		0x00000FFF
#define PCIE_VC0_CRQCR_CPL_DATA_CREDITS_S	0
#define PCIE_VC0_CRQCR_CPL_HDR_CREDITS		0x000FF000
#define PCIE_VC0_CRQCR_CPL_HDR_CREDITS_S	12
#define PCIE_VC0_CRQCR_CPL_TLP_QUEUE_MODE	0x00E00000
#define PCIE_VC0_CRQCR_CPL_TLP_QUEUE_MODE_S	21

/* Applicable to the above three registers */
enum {
	PCIE_VC0_TLP_QUEUE_MODE_STORE_FORWARD = 1,
	PCIE_VC0_TLP_QUEUE_MODE_CUT_THROUGH = 2,
	PCIE_VC0_TLP_QUEUE_MODE_BYPASS = 4,
};

/* VC0 Posted Buffer Depth Register */
#define PCIE_VC0_PBD(X)		(u32 *)(PCIE_RC_PORT_TO_BASE(X) + 0x7A8)

#define PCIE_VC0_PBD_P_DATA_QUEUE_ENTRIES	0x00003FFF
#define PCIE_VC0_PBD_P_DATA_QUEUE_ENTRIES_S	0
#define PCIE_VC0_PBD_P_HDR_QUEUE_ENTRIES	0x03FF0000
#define PCIE_VC0_PBD_P_HDR_QUEUE_ENTRIES_S	16

/* VC0 Non-Posted Buffer Depth Register */
#define PCIE_VC0_NPBD(X)	(u32 *)(PCIE_RC_PORT_TO_BASE(X) + 0x7AC)

#define PCIE_VC0_NPBD_NP_DATA_QUEUE_ENTRIES	0x00003FFF
#define PCIE_VC0_NPBD_NP_DATA_QUEUE_ENTRIES_S	0
#define PCIE_VC0_NPBD_NP_HDR_QUEUE_ENTRIES	0x03FF0000
#define PCIE_VC0_NPBD_NP_HDR_QUEUE_ENTRIES_S	16

/* VC0 Completion Buffer Depth Register */
#define PCIE_VC0_CBD(X)		(u32 *)(PCIE_RC_PORT_TO_BASE(X) + 0x7B0)

#define PCIE_VC0_CBD_CPL_DATA_QUEUE_ENTRIES	0x00003FFF
#define PCIE_VC0_CBD_CPL_DATA_QUEUE_ENTRIES_S	0
#define PCIE_VC0_CBD_CPL_HDR_QUEUE_ENTRIES	0x03FF0000
#define PCIE_VC0_CBD_CPL_HDR_QUEUE_ENTRIES_S	16

/* PHY Status Register,*/
#define PCIE_PHYSR(X)		(u32 *)(PCIE_RC_PORT_TO_BASE(X) + 0x810)

/* PHY Control Register */
#define PCIE_PHYCR(X)		(u32 *)(PCIE_RC_PORT_TO_BASE(X) + 0x814)

/*
 * PCIe PDI PHY register definition, suppose all the following
 * stuff is confidential.
 * XXX, detailed bit definition
 */
#define	PCIE_PHY_PLL_CTRL1(X)	(u32 *)(PCIE_PHY_PORT_TO_BASE(X) + (0x22 << 1))
#define	PCIE_PHY_PLL_CTRL2(X)	(u32 *)(PCIE_PHY_PORT_TO_BASE(X) + (0x23 << 1))
#define	PCIE_PHY_PLL_CTRL3(X)	(u32 *)(PCIE_PHY_PORT_TO_BASE(X) + (0x24 << 1))
#define	PCIE_PHY_PLL_CTRL4(X)	(u32 *)(PCIE_PHY_PORT_TO_BASE(X) + (0x25 << 1))
#define	PCIE_PHY_PLL_CTRL5(X)	(u32 *)(PCIE_PHY_PORT_TO_BASE(X) + (0x26 << 1))
#define	PCIE_PHY_PLL_CTRL6(X)	(u32 *)(PCIE_PHY_PORT_TO_BASE(X) + (0x27 << 1))
#define	PCIE_PHY_PLL_CTRL7(X)	(u32 *)(PCIE_PHY_PORT_TO_BASE(X) + (0x28 << 1))
#define	PCIE_PHY_PLL_A_CTRL1(X)	(u32 *)(PCIE_PHY_PORT_TO_BASE(X) + (0x29 << 1))
#define	PCIE_PHY_PLL_A_CTRL2(X)	(u32 *)(PCIE_PHY_PORT_TO_BASE(X) + (0x2A << 1))
#define	PCIE_PHY_PLL_A_CTRL3(X)	(u32 *)(PCIE_PHY_PORT_TO_BASE(X) + (0x2B << 1))
#define	PCIE_PHY_PLL_STATUS(X)	(u32 *)(PCIE_PHY_PORT_TO_BASE(X) + (0x2C << 1))

#define PCIE_PHY_TX1_CTRL1(X)	(u32 *)(PCIE_PHY_PORT_TO_BASE(X) + (0x30 << 1))
#define PCIE_PHY_TX1_CTRL2(X)	(u32 *)(PCIE_PHY_PORT_TO_BASE(X) + (0x31 << 1))
#define PCIE_PHY_TX1_CTRL3(X)	(u32 *)(PCIE_PHY_PORT_TO_BASE(X) + (0x32 << 1))
#define PCIE_PHY_TX1_A_CTRL1(X)	(u32 *)(PCIE_PHY_PORT_TO_BASE(X) + (0x33 << 1))
#define PCIE_PHY_TX1_A_CTRL2(X)	(u32 *)(PCIE_PHY_PORT_TO_BASE(X) + (0x34 << 1))
#define PCIE_PHY_TX1_MOD1(X)	(u32 *)(PCIE_PHY_PORT_TO_BASE(X) + (0x35 << 1))
#define PCIE_PHY_TX1_MOD2(X)	(u32 *)(PCIE_PHY_PORT_TO_BASE(X) + (0x36 << 1))
#define PCIE_PHY_TX1_MOD3(X)	(u32 *)(PCIE_PHY_PORT_TO_BASE(X) + (0x37 << 1))

#define PCIE_PHY_TX2_CTRL1(X)	(u32 *)(PCIE_PHY_PORT_TO_BASE(X) + (0x38 << 1))
#define PCIE_PHY_TX2_CTRL2(X)	(u32 *)(PCIE_PHY_PORT_TO_BASE(X) + (0x39 << 1))
#define PCIE_PHY_TX2_A_CTRL1(X)	(u32 *)(PCIE_PHY_PORT_TO_BASE(X) + (0x3B << 1))
#define PCIE_PHY_TX2_A_CTRL2(X)	(u32 *)(PCIE_PHY_PORT_TO_BASE(X) + (0x3C << 1))
#define PCIE_PHY_TX2_MOD1(X)	(u32 *)(PCIE_PHY_PORT_TO_BASE(X) + (0x3D << 1))
#define PCIE_PHY_TX2_MOD2(X)	(u32 *)(PCIE_PHY_PORT_TO_BASE(X) + (0x3E << 1))
#define PCIE_PHY_TX2_MOD3(X)	(u32 *)(PCIE_PHY_PORT_TO_BASE(X) + (0x3F << 1))

#define PCIE_PHY_RX1_CTRL1(X)	(u32 *)(PCIE_PHY_PORT_TO_BASE(X) + (0x50 << 1))
#define PCIE_PHY_RX1_CTRL2(X)	(u32 *)(PCIE_PHY_PORT_TO_BASE(X) + (0x51 << 1))
#define PCIE_PHY_RX1_CDR(X)	(u32 *)(PCIE_PHY_PORT_TO_BASE(X) + (0x52 << 1))
#define PCIE_PHY_RX1_EI(X)	(u32 *)(PCIE_PHY_PORT_TO_BASE(X) + (0x53 << 1))
#define PCIE_PHY_RX1_A_CTRL(X)	(u32 *)(PCIE_PHY_PORT_TO_BASE(X) + (0x55 << 1))

/* MSI PIC */
#define MSI_PIC_REG_BASE		(KSEG1 | 0x1F700000)
#define MSI1_PIC_REG_BASE		(KSEG1 | 0x1F500000)
#define MSI2_PIC_REG_BASE		(KSEG1 | 0x1F700600)

#define MSI_PIC_BIG_ENDIAN		1
#define MSI_PIC_LITTLE_ENDIAN		0

#define MSI_PCI_INT_DISABLE		0x80000000
#define MSI_PIC_INT_LINE		0x30000000
#define MSI_PIC_INT_LINE_S		28
#define MSI_PIC_MSG_ADDR		0x0FFF0000
#define MSI_PIC_MSG_ADDR_S		16
#define MSI_PIC_MSG_DATA		0x0000FFFF
#define MSI_PIC_MSG_DATA_S		0x0

#define PCIE_INTA			(INT_NUM_IM4_IRL0 + 8)
#define PCIE_INTB			(INT_NUM_IM4_IRL0 + 9)
#define PCIE_INTC			(INT_NUM_IM4_IRL0 + 10)
#define PCIE_INTD			(INT_NUM_IM4_IRL0 + 11)
#define PCIE_IR				(INT_NUM_IM4_IRL0 + 25)
#define PCIE_WAKE			(INT_NUM_IM4_IRL0 + 26)
#define PCIE_MSI_IR0			(INT_NUM_IM4_IRL0 + 27)
#define PCIE_MSI_IR1			(INT_NUM_IM4_IRL0 + 28)
#define PCIE_MSI_IR2			(INT_NUM_IM4_IRL0 + 29)
#define PCIE_MSI_IR3			(INT_NUM_IM0_IRL0 + 30)
#define PCIE_L3_INT			(INT_NUM_IM3_IRL0 + 16)

#define PCIE1_INTA			(INT_NUM_IM0_IRL0 + 9)
#define PCIE1_INTB			(INT_NUM_IM0_IRL0 + 10)
#define PCIE1_INTC			(INT_NUM_IM0_IRL0 + 11)
#define PCIE1_INTD			(INT_NUM_IM0_IRL0 + 12)
#define PCIE1_IR			(INT_NUM_IM1_IRL0 + 17)
#define PCIE1_WAKE			(INT_NUM_IM1_IRL0 + 18)
#define PCIE1_MSI_IR0			(INT_NUM_IM1_IRL0 + 9)
#define PCIE1_MSI_IR1			(INT_NUM_IM1_IRL0 + 10)
#define PCIE1_MSI_IR2			(INT_NUM_IM1_IRL0 + 11)
#define PCIE1_MSI_IR3			(INT_NUM_IM1_IRL0 + 12)
#define PCIE1_L3_INT			(INT_NUM_IM1_IRL0 + 13)

#define PCIE2_INTA			(INT_NUM_IM0_IRL0 + 19)
#define PCIE2_INTB			(INT_NUM_IM1_IRL0 + 31)
#define PCIE2_INTC			(INT_NUM_IM2_IRL0 + 17)
#define PCIE2_INTD			(INT_NUM_IM2_IRL0 + 18)
#define PCIE2_IR			(INT_NUM_IM1_IRL0 + 21)
#define PCIE2_WAKE			(INT_NUM_IM1_IRL0 + 23)
#define PCIE2_MSI_IR0			(INT_NUM_IM2_IRL0 + 12)
#define PCIE2_MSI_IR1			(INT_NUM_IM2_IRL0 + 13)
#define PCIE2_MSI_IR2			(INT_NUM_IM2_IRL0 + 14)
#define PCIE2_MSI_IR3			(INT_NUM_IM2_IRL0 + 15)
#define PCIE2_L3_INT			(INT_NUM_IM2_IRL0 + 30)

#define INT_NUM_IM4_IRL31		(INT_NUM_IM4_IRL0 + 31)

#define RCU_AHB_ENDIAN			0x004C
#define RCU_RST_REQ			0x0010
#define RCU_AHB_BE_PCIE_PDI		0x00000080
#define RCU_RST_STAT2			0x0024
#define RCU_RST_REQ2			0x0048

#define RCU_PCIE_ARBITER_MASK		0x00000C00
#define RCU_PCIE_ARBITER_RC0		0x00000000
#define RCU_PCIE_ARBITER_RC0_RC1	0x00000800
#define RCU_PCIE_ARBITER_RC0_RC1_RC2	0x00000400

#define RCU_BE_AHB4S			0x00000001
#define RCU_BE_AHB3M			0x00000002
#define RCU_BE_USIF			0x00000004
#define RCU_BE_AHB2S			0x00000008
#define RCU_BE_PCIE0S			0x00000010
#define RCU_BE_PCIE0_DBI		0x00000020
#define RCU_BE_DCDC_PDI			0x00000040
#define RCU_BE_PCIE0_PDI		0x00000080
#define RCU_BE_PCIE1S			0x00000100
#define RCU_BE_PCIE1_DBI		0x00000200
#define RCU_BE_PCIE1_PDI		0x00000400
#define RCU_BE_AHB1S			0x00000800
#define RCU_BE_PCIE0M			0x00001000
#define RCU_BE_PCIE1M			0x00002000

#define RCU_BE_PCIE2M			0x00004000
#define RCU_BE_PCIE2_DBI		0x00008000
#define RCU_BE_PCIE2_PDI		0x00010000
#define RCU_BE_PCIE2S			0x00020000

#define RCU_VR9_BE_PCIE0M		0x00000001
#define RCU_VR9_BE_AHB1S		0x00000008
#define RCU_VR9_BE_PCIE0S		0x00000010
#define RCU_VR9_BE_AHB2M		0x00000002

/* PCIe Address Mapping Base */
#if defined(CONFIG_LANTIQ_PCIE_1ST_CORE)
#define PCIE_CFG_PHY_BASE	0x1D000000UL
#define PCIE_CFG_BASE		(KSEG1 + PCIE_CFG_PHY_BASE)
#define PCIE_CFG_SIZE		(8 * 1024 * 1024)

#define PCIE_MEM_PHY_BASE	0x1C000000UL
#define PCIE_MEM_BASE		(KSEG1 + PCIE_MEM_PHY_BASE)
#define PCIE_MEM_SIZE		(16 * 1024 * 1024)
#define PCIE_MEM_PHY_END	(PCIE_MEM_PHY_BASE + PCIE_MEM_SIZE - 1)

#define PCIE_IO_PHY_BASE	0x1D800000UL
#define PCIE_IO_BASE		(KSEG1 + PCIE_IO_PHY_BASE)
#define PCIE_IO_SIZE		(1 * 1024 * 1024)
#define PCIE_IO_PHY_END		(PCIE_IO_PHY_BASE + PCIE_IO_SIZE - 1)

#define PCIE_RC_CFG_BASE	(KSEG1 + 0x1D900000)
#define PCIE_APP_LOGIC_REG	(KSEG1 + 0x1E100900)
#define PCIE_MSI_PHY_BASE	0x1F600000UL

#define PCIE_PDI_PHY_BASE	0x1F106800UL
#define PCIE_PDI_BASE		(KSEG1 + PCIE_PDI_PHY_BASE)
#define PCIE_PDI_SIZE		0x200
#endif /* CONFIG_LANTIQ_PCIE_1ST_CORE */

#if defined(CONFIG_LANTIQ_PCIE_2ND_CORE)
#define PCIE1_CFG_PHY_BASE	0x19000000UL
#define PCIE1_CFG_BASE		(KSEG1 + PCIE1_CFG_PHY_BASE)
#define PCIE1_CFG_SIZE		(8 * 1024 * 1024)

#define PCIE1_MEM_PHY_BASE	0x18000000UL
#define PCIE1_MEM_BASE		(KSEG1 + PCIE1_MEM_PHY_BASE)
#define PCIE1_MEM_SIZE		(16 * 1024 * 1024)
#define PCIE1_MEM_PHY_END	(PCIE1_MEM_PHY_BASE + PCIE1_MEM_SIZE - 1)

#define PCIE1_IO_PHY_BASE	0x19800000UL
#define PCIE1_IO_BASE		(KSEG1 + PCIE1_IO_PHY_BASE)
#define PCIE1_IO_SIZE		(1 * 1024 * 1024)
#define PCIE1_IO_PHY_END	(PCIE1_IO_PHY_BASE + PCIE1_IO_SIZE - 1)

#define PCIE1_RC_CFG_BASE	(KSEG1 + 0x19900000)
#define PCIE1_APP_LOGIC_REG	(KSEG1 + 0x1E100700)
#define PCIE1_MSI_PHY_BASE	0x1F400000UL

#define PCIE1_PDI_PHY_BASE	0x1F700400UL
#define PCIE1_PDI_BASE		(KSEG1 + PCIE1_PDI_PHY_BASE)
#define PCIE1_PDI_SIZE		0x200
#endif /* CONFIG_LANTIQ_PCIE_2ND_CORE */

#if defined(CONFIG_LANTIQ_PCIE_3RD_CORE)
#define PCIE2_CFG_PHY_BASE	0x1A800000UL
#define PCIE2_CFG_BASE		(KSEG1 + PCIE2_CFG_PHY_BASE)
#define PCIE2_CFG_SIZE		(8 * 1024 * 1024)

#define PCIE2_MEM_PHY_BASE	0x1B000000UL
#define PCIE2_MEM_BASE		(KSEG1 + PCIE2_MEM_PHY_BASE)
#define PCIE2_MEM_SIZE		(16 * 1024 * 1024)
#define PCIE2_MEM_PHY_END	(PCIE2_MEM_PHY_BASE + PCIE2_MEM_SIZE - 1)

#define PCIE2_IO_PHY_BASE	0x19A00000UL
#define PCIE2_IO_BASE		(KSEG1 + PCIE2_IO_PHY_BASE)
#define PCIE2_IO_SIZE		(1 * 1024 * 1024)
#define PCIE2_IO_PHY_END	(PCIE2_IO_PHY_BASE + PCIE2_IO_SIZE - 1)

#define PCIE2_RC_CFG_BASE	(KSEG1 + 0x19B00000)
#define PCIE2_APP_LOGIC_REG	(KSEG1 + 0x1E100400)
#define PCIE2_MSI_PHY_BASE	0x1F700A00UL

#define PCIE2_PDI_PHY_BASE	0x1F106A00UL
#define PCIE2_PDI_BASE		(KSEG1 + PCIE2_PDI_PHY_BASE)
#define PCIE2_PDI_SIZE		0x200
#endif /* CONFIG_LANTIQ_PCIE_3RD_CORE */

/* Subject to change, DT is preferred */
#define PCIE_GPIO_RESET		238 /* VR9 */
#define PCIE_RC0_LED_RST	181
#define PCIE_RC1_LED_RST	182

#define PCIE_RC2_LED_RST	171

static int pcie_port_to_rst_pin[] = {
	PCIE_RC0_LED_RST,
	PCIE_RC1_LED_RST,
	PCIE_RC2_LED_RST,
};


#endif /* PCIE_LANTIQ_H */
