#include <linux/kernel.h>
#include <linux/module.h>
#include <linux/version.h>
#include <linux/types.h>
#include <linux/hrtimer.h>
#include <linux/ktime.h>
#include <linux/skbuff.h>
#include <linux/etherdevice.h>
#include <linux/errno.h>
#include <linux/interrupt.h>
#include <net/xfrm.h>
#include <asm/cacheflush.h>

#include <net/ppa_stack_al.h>

#include "vrx320_common.h"
#include "vrx320_ptm_common.h"
#include "vrx320_e1_addr_def.h"
#include "lantiq_wrapper.h"
#include "unified_qos_ds_be.h"
#include <linux/crc32.h>

#ifdef QCA_NSS_REDIRECT
#include <linux/if_vlan.h>
#include <nss_api_if.h>
#endif

int g_rx_empty_cnt = 0;
#ifdef QCA_NSS_REDIRECT
/*NSS Global context*/
static void * g_nssctx;

int g_use_nss_path=1;
module_param(g_use_nss_path, int, 0644);
MODULE_PARM_DESC(g_use_nss_path,"PTM NSS Redirect 1=Enable 0=Disble");

static int g_vlanid=-1;
module_param(g_vlanid,int, 0644);
MODULE_PARM_DESC(g_vlanid,"PTM VlanId -1=NO_VLAN other >=0 VLAN_ID");

static int nss_pkt_count=0;
module_param(nss_pkt_count,int,0644);

void vrx320_nss_redirect_register(struct net_device *dev);
void vrx320_nss_redirect_unregister(void);
void vrx320_nss_redirect_vlan_tag_remove(struct sk_buff *skb);
void * alloc_skb_dataptr_nss_redirect(int len);
#endif

extern void *ppa_callback_get(e_ltq_mei_cb_type type);
extern dma_addr_t alloc_dataptr_fragment(unsigned int bytes);
extern void *alloc_dataptr_fragment_notrack(unsigned int bytes);
extern dma_addr_t alloc_dataptr_skb(void);
extern int ppa_callback_set(e_ltq_mei_cb_type type, void *func);
static int in_showtime(void);
static int vrx320_poll(struct napi_struct *napi, int budget);
extern int g_dsl_bonding;
extern void dev_kfree_skb_any(struct sk_buff *skb);
static void dump_skb(struct sk_buff *skb, u32 len, const char *title, int port, int ch, int is_tx);
static int vrx320_ptm_cpu_us_desc_init(void);
static int vrx320_ptm_cpu_us_desc_exit(void);
#ifdef VRX320_DEBUG
unsigned int g_intr_cnt, g_fake_isr, g_repoll_cnt, g_desc_reown_cnt;
unsigned int g_wd_min=100, g_wd_max, g_wd_avg, g_wd_cnt;
unsigned int g_tx_nodesc_cnt;
#endif

#define ETH_WATCHDOG_TIMEOUT                    (10 * HZ)

#define DMA_PACKET_SIZE                         1600	//  ((1518 + 8 <2 VLAN> + 62 <PPE FW> + 8 <SW Header>) + 31) & ~31
#define DMA_ALIGNMENT                           32

#define ETH_MIN_TX_PACKET_LENGTH                ETH_ZLEN

//Maximum 64 Descriptors
#define CPU_TO_WAN_TX_DESC_BASE                 ((volatile struct tx_descriptor *)(g_dsl_bonding?SOC_US_FASTPATH_DES_BASE_VIRT:SOC_US_CPUPATH_DES_BASE_VIRT))
#define CPU_TO_WAN_TX_DESC_NUM                  SOC_US_CPUPATH_DES_NUM

#define PTM_PORT                                7

//  MIB counter
#define RECEIVE_NON_IDLE_CELL_CNT(i,base)       SOC_ACCESS_VRX218_ADDR(SB_BUFFER(0x34A0 + (i)), base)
#define RECEIVE_IDLE_CELL_CNT(i,base)           SOC_ACCESS_VRX218_ADDR(SB_BUFFER(0x34A2 + (i)), base)
#define TRANSMIT_CELL_CNT(i,base)               SOC_ACCESS_VRX218_ADDR(SB_BUFFER(0x34A4 + (i)), base)



/*
 *  Mailbox IGU0 Registers
 */
// VRX218 US Master IGU0 Interrupt
#if 0				/* AKRONITE related changes */
#define MBOX_IGU0_ISRS                          SOC_ACCESS_VRX218_ADDR(PPE_REG_ADDR(0x0200), g_vrx218_dev_us.membase)
#define MBOX_IGU0_ISRC                          SOC_ACCESS_VRX218_ADDR(PPE_REG_ADDR(0x0201), g_vrx218_dev_us.membase)
#define MBOX_IGU0_ISR                           SOC_ACCESS_VRX218_ADDR(PPE_REG_ADDR(0x0202), g_vrx218_dev_us.membase)
#define MBOX_IGU0_IER                           SOC_ACCESS_VRX218_ADDR(PPE_REG_ADDR(0x0203), g_vrx218_dev_us.membase)

// VRX218 DS Master IGU0 Interrupt
#define MBOX_IGU0_DSM_ISRS                      SOC_ACCESS_VRX218_ADDR(PPE_REG_ADDR(0x0200), g_vrx218_dev_ds.membase)
#define MBOX_IGU0_DSM_ISRC                      SOC_ACCESS_VRX218_ADDR(PPE_REG_ADDR(0x0201), g_vrx218_dev_ds.membase)
#define MBOX_IGU0_DSM_ISR                       SOC_ACCESS_VRX218_ADDR(PPE_REG_ADDR(0x0202), g_vrx218_dev_ds.membase)
#define MBOX_IGU0_DSM_IER                       SOC_ACCESS_VRX218_ADDR(PPE_REG_ADDR(0x0203), g_vrx218_dev_ds.membase)

/*
 *  Mailbox IGU1 Registers
 */
// VRX218 US Master IGU1 Interrupt
#define MBOX_IGU1_ISRS                          SOC_ACCESS_VRX218_ADDR(PPE_REG_ADDR(0x0204), g_vrx218_dev_us.membase)
#define MBOX_IGU1_ISRC                          SOC_ACCESS_VRX218_ADDR(PPE_REG_ADDR(0x0205), g_vrx218_dev_us.membase)
#define MBOX_IGU1_ISR                           SOC_ACCESS_VRX218_ADDR(PPE_REG_ADDR(0x0206), g_vrx218_dev_us.membase)
#define MBOX_IGU1_IER                           SOC_ACCESS_VRX218_ADDR(PPE_REG_ADDR(0x0207), g_vrx218_dev_us.membase)

// VRX218 DS Master IGU1 Interrupt
#define MBOX_IGU1_DSM_ISRS                      SOC_ACCESS_VRX218_ADDR(PPE_REG_ADDR(0x0204), g_vrx218_dev_ds.membase)
#define MBOX_IGU1_DSM_ISRC                      SOC_ACCESS_VRX218_ADDR(PPE_REG_ADDR(0x0205), g_vrx218_dev_ds.membase)
#define MBOX_IGU1_DSM_ISR                       SOC_ACCESS_VRX218_ADDR(PPE_REG_ADDR(0x0206), g_vrx218_dev_ds.membase)
#define MBOX_IGU1_DSM_IER                       SOC_ACCESS_VRX218_ADDR(PPE_REG_ADDR(0x0207), g_vrx218_dev_ds.membase)

/*
 *  IMCU Registers
 */
#define IMCU_IMER_BASE_ADDR                     0x1E000044
#define IMCU_USM_IMER                           SOC_ACCESS_VRX218_ADDR(IMCU_IMER_BASE_ADDR, g_vrx218_dev_us.membase)
#define IMCU_DSM_IMER                           SOC_ACCESS_VRX218_ADDR(IMCU_IMER_BASE_ADDR, g_vrx218_dev_ds.membase)
#else
#define MBOX_IGU0_ISRS                          SOC_ACCESS_VRX218_ADDR(PPE_REG_ADDR(0x0200), g_vrx218_dev_us.membase)
#define MBOX_IGU0_ISRC                          SOC_ACCESS_VRX218_ADDR(PPE_REG_ADDR(0x0201), g_vrx218_dev_us.membase)
#define MBOX_IGU0_ISR                           SOC_ACCESS_VRX218_ADDR(PPE_REG_ADDR(0x0202), g_vrx218_dev_us.membase)
#define MBOX_IGU0_IER                           SOC_ACCESS_VRX218_ADDR(PPE_REG_ADDR(0x0203), g_vrx218_dev_us.membase)

// VRX218 DS Master IGU0 Interrupt
#define MBOX_IGU0_DSM_ISRS                      SOC_ACCESS_VRX218_ADDR(PPE_REG_ADDR(0x0200), g_vrx218_dev_ds.membase)
#define MBOX_IGU0_DSM_ISRC                      SOC_ACCESS_VRX218_ADDR(PPE_REG_ADDR(0x0201), g_vrx218_dev_ds.membase)
#define MBOX_IGU0_DSM_ISR                       SOC_ACCESS_VRX218_ADDR(PPE_REG_ADDR(0x0202), g_vrx218_dev_ds.membase)
#define MBOX_IGU0_DSM_IER                       SOC_ACCESS_VRX218_ADDR(PPE_REG_ADDR(0x0203), g_vrx218_dev_ds.membase)

/*
 *  Mailbox IGU1 Registers
 */
// VRX218 US Master IGU1 Interrupt
#define MBOX_IGU1_ISRS                          SOC_ACCESS_VRX218_ADDR(PPE_REG_ADDR(0x0204), g_vrx218_dev_us.membase)
#define MBOX_IGU1_ISRC                          SOC_ACCESS_VRX218_ADDR(PPE_REG_ADDR(0x0205), g_vrx218_dev_us.membase)
#define MBOX_IGU1_ISR                           SOC_ACCESS_VRX218_ADDR(PPE_REG_ADDR(0x0206), g_vrx218_dev_us.membase)
#define MBOX_IGU1_IER                           SOC_ACCESS_VRX218_ADDR(PPE_REG_ADDR(0x0207), g_vrx218_dev_us.membase)

// VRX218 DS Master IGU1 Interrupt
#define MBOX_IGU1_DSM_ISRS                      SOC_ACCESS_VRX218_ADDR(PPE_REG_ADDR(0x0204), g_vrx218_dev_ds.membase)
#define MBOX_IGU1_DSM_ISRC                      SOC_ACCESS_VRX218_ADDR(PPE_REG_ADDR(0x0205), g_vrx218_dev_ds.membase)
#define MBOX_IGU1_DSM_ISR                       SOC_ACCESS_VRX218_ADDR(PPE_REG_ADDR(0x0206), g_vrx218_dev_ds.membase)
#define MBOX_IGU1_DSM_IER                       SOC_ACCESS_VRX218_ADDR(PPE_REG_ADDR(0x0207), g_vrx218_dev_ds.membase)

/*
 *  IMCU Registers
 */
#define IMCU_IMER_BASE_ADDR                     0x1E000044
#define IMCU_USM_IMER                           SOC_ACCESS_VRX218_ADDR(IMCU_IMER_BASE_ADDR, g_vrx218_dev_us.membase)
#define IMCU_DSM_IMER                           SOC_ACCESS_VRX218_ADDR(IMCU_IMER_BASE_ADDR, g_vrx218_dev_ds.membase)

#endif

/*
 *  Internal Structure of Devices (ETH/ATM)
 */
struct eth_priv_data {
	struct net_device_stats stats;

	unsigned int rx_packets;
	unsigned int rx_bytes;
	unsigned int rx_dropped;
	unsigned int tx_packets;
	unsigned int tx_bytes;
	unsigned int tx_errors;
	unsigned int tx_dropped;

	unsigned int dev_id;
};

struct tx_descriptor {
#if defined(__LITTLE_ENDIAN_BITFIELD)
	unsigned int datalen:14;
	unsigned int small:1;
	unsigned int res:4;
	unsigned int qos:4;
	unsigned int byteoff:5;
	unsigned int eop:1;
	unsigned int sop:1;
	unsigned int c:1;
	unsigned int own:1;
#elif defined (__BIG_ENDIAN_BITFIELD)
	unsigned int own:1;
	unsigned int c:1;
	unsigned int sop:1;
	unsigned int eop:1;
	unsigned int byteoff:5;
	unsigned int qos:4;
	unsigned int res:4;
	unsigned int small:1;
	unsigned int datalen:14;
#else
#error  "Please fix <asm/byteorder.h>"
#endif

	unsigned int dataptr:32;
};



/*
 *  Network Operations
 */
static void ptm_setup(struct net_device *);
static struct net_device_stats *ptm_get_stats(struct net_device *);
static int ptm_open(struct net_device *);
static int ptm_stop(struct net_device *);
static int ptm_qos_hard_start_xmit(struct sk_buff *, struct net_device *);
static int ptm_qos_hard_start_xmit_bondsw(struct sk_buff *,
					  struct net_device *);
#ifdef LANTIQ_ENV
static int ptm_qos_hard_start_xmit_b(struct sk_buff *, struct net_device *);
#endif
static int ptm_set_mac_address(struct net_device *, void *);
static int ptm_ioctl(struct net_device *, struct ifreq *, int);
static void ptm_tx_timeout(struct net_device *);
int ptm_push(struct sk_buff *skb, struct flag_header *header, unsigned int ifid);
static int vrx320_memcpy_swap(unsigned char *dest_data, unsigned char *src_data, int len);
/*
 *  External Functions
 */
static unsigned int g_cpu_to_wan_rx_desc_pos;
struct napi_struct vrx320_napi;
static int vrx320_enable_rx_intr(void);
static int vrx320_disable_rx_intr(void);
static int vrx320_napi_recv(void *data, int len);



/*
 *  DSL Data LED
 */
#ifdef CONFIG_IFX_LED
static void dsl_led_flash(void);
static void dsl_led_polling(unsigned long);
#endif



/*
 *  Mailbox handler
 */
static irqreturn_t mailbox_vrx218_dsm_irq_handler(int irq, void *dev_id);

/*
 *  Debug functions
 */
static void dump_skb(struct sk_buff *skb, u32 len, const char *title, int port,
		     int ch, int is_tx);
#ifdef LANTIQ_ENV
static int swap_mac(unsigned char *data);
#endif

/* Global definitions */
#define MS_TO_NS(x)	(x * 1E6L)
#define US_TO_NS(x)	(x * 1E3L)
#define NUM_DESC 32
#define POLL_TIME_IN_MS 1000

extern struct host_desc_mem g_host_desc_base;
extern unsigned int vrx320_timer_poll_bondsw(unsigned int *rxbytes);
int	g_bonding_rx_poll=0;

extern int 	g_poll_interval_ms;

static int timer_started=0;
static struct hrtimer hr_timer;

unsigned int vrx320_hrpoll_stop(void);
/*******************************************************************************
Description: vrx320_hrtimer_callback - Callback called when high resolution timer expires
Arguments:
Note:
*******************************************************************************/

enum hrtimer_restart vrx320_hrtimer_callback( struct hrtimer *timer )
{
	extern struct napi_struct vrx320_napi;
  ktime_t ktime,now;
/*
	unsigned int rxbytes = 0;
	int work_done;
*/
	napi_schedule(&vrx320_napi);
	if(g_bonding_rx_poll == 1) {
		ktime = ktime_set( 0, (1000*g_poll_interval_ms) );
		now = hrtimer_cb_get_time(timer);
		hrtimer_forward(timer, now, ktime);
 		return HRTIMER_RESTART;
	} else {
		//vrx320_hrpoll_stop();
		vrx320_enable_rx_intr();
		return HRTIMER_NORESTART;
	}
}

/*******************************************************************************
Description: vrx320_hrpoll_start
Arguments:
Note:
*******************************************************************************/

unsigned int vrx320_hrpoll_start(void)
{
  struct timespec tp;
  ktime_t ktime;
  unsigned long resolution=0;

  if(timer_started==0){
    timer_started=1;

    /* Get the hr timer resolution */
    hrtimer_get_res(CLOCK_MONOTONIC, &tp);	
    if(tp.tv_sec > 0 || !tp.tv_nsec) {
      printk(KERN_ERR "hrpoll: Invalid resolution %u.%09u",(unsigned)tp.tv_sec, (unsigned)tp.tv_nsec);
		  return -EINVAL;
    }	
    resolution = tp.tv_nsec;

    /* ktime = ktime_set( 0, MS_TO_NS(delay_in_ms) ); */
    ktime = ktime_set( 0, (1000*g_poll_interval_ms) );
    hrtimer_init( &hr_timer, CLOCK_MONOTONIC, HRTIMER_MODE_REL );
    hr_timer.function = &vrx320_hrtimer_callback;
    /* printk( "Starting timer to fire in %dus (%ld)\n", g_poll_interval_ms, jiffies ); */
  	hrtimer_start( &hr_timer, ktime, HRTIMER_MODE_REL );
  } else {
		vrx320_hrpoll_stop();
		vrx320_hrpoll_start();
	}
  return 0;
}

/*******************************************************************************
Description: vrx320_hrpoll_stop
Arguments:
Note:
*******************************************************************************/

unsigned int vrx320_hrpoll_stop(void)
{
  int ret;
  ret = hrtimer_cancel(&hr_timer);
/*
  if (ret) 
		printk("The timer was still in use...\n");
*/
  timer_started=0;
  return 0;
}








static int vrx320_memcpy_swap(unsigned char *dest_data, unsigned char *src_data, int len)
{

	int i = 0, j;
	int unaligned_bytes = len % 4;
	int dw_max_index = len / 4;
	unsigned int *d = (unsigned int *)dest_data;
	unsigned int *s = (unsigned int *)src_data;

	if (unaligned_bytes) {
		for (j = 0; j < (4 - unaligned_bytes); j++) {
			dest_data[len + j] = '\0';
		}
	}
#if 0
	for (i = 0,j=0; j < dw_max_index/8;j++) {
		d[i] = cpu_to_be32(s[i++]);
		d[i] = cpu_to_be32(s[i++]);
		d[i] = cpu_to_be32(s[i++]);
		d[i] = cpu_to_be32(s[i++]);
		d[i] = cpu_to_be32(s[i++]);
		d[i] = cpu_to_be32(s[i++]);
		d[i] = cpu_to_be32(s[i++]);
		d[i] = cpu_to_be32(s[i++]);
	}
	for (; i <= (dw_max_index) + 1; i++) {
		d[i] = cpu_to_be32(s[i]);
	}
#else
	for (i=0; i <= (dw_max_index) + 1; i++) {
		d[i] = cpu_to_be32(s[i]);
	}
#endif
	if (unaligned_bytes)
		return (4 - unaligned_bytes);
	else
		return 0;
}


static ltq_pcie_ep_dev_t g_vrx218_dev_us, g_vrx218_dev_ds;

static int g_cpu_to_wan_tx_desc_pos = 0;
static DEFINE_SPINLOCK(g_cpu_to_wan_tx_desc_lock);

struct net_device *g_ptm_net_dev[1] = { 0 };

#if !defined(CONFIG_LANTIQ_ETH_FRAMEWORK) && LINUX_VERSION_CODE >= KERNEL_VERSION(2,6,32)
static struct net_device_ops g_ptm_netdev_ops[1] = {
	{
	 .ndo_open = ptm_open,
	 .ndo_stop = ptm_stop,
	 .ndo_get_stats = ptm_get_stats,
	 .ndo_set_mac_address = ptm_set_mac_address,
	 .ndo_start_xmit = ptm_qos_hard_start_xmit,
	 .ndo_tx_timeout = ptm_tx_timeout,
	 .ndo_do_ioctl = ptm_ioctl,
	 },
};
#endif

#define LINE_NUMBER       2
int g_showtime[LINE_NUMBER] = { 0 };

#ifdef CONFIG_IFX_LED
static unsigned int g_wrx_bc_user_cw = 0;
static unsigned int g_total_tx_cw = 0;
static struct timer_list g_dsl_led_polling_timer;
static void *g_data_led_trigger = NULL;
#endif

#ifndef CONFIG_LANTIQ_ETH_FRAMEWORK
#define ifx_eth_fw_alloc_netdev(size, ifname, dummy)      alloc_netdev(size, ifname, ether_setup)
#define ifx_eth_fw_free_netdev(netdev, dummy)             free_netdev(netdev)
#define ifx_eth_fw_register_netdev(netdev)                register_netdev(netdev)
#define ifx_eth_fw_unregister_netdev(netdev, dummy)       unregister_netdev(netdev)
#define ifx_eth_fw_netdev_priv(netdev)                    netdev_priv(netdev)
#endif

static uint32_t g_pcie_reset_sig = (uint32_t) 0;

static int vrx320_enable_rx_intr(void)
{
  //*MBOX_IGU1_ISRC = 0x20;
	*MBOX_IGU1_DSM_IER |= 0x20;
	return 0;
}
static int vrx320_disable_rx_intr(void)
{
	*MBOX_IGU1_DSM_IER &= ~0x20;
	return 0;
}

#ifdef QCA_NSS_REDIRECT
void vrx320_nss_redirect_register(struct net_device *dev)
{
	g_nssctx = nss_create_virt_if(dev);
	if(g_nssctx) {
		printk("VRX320 PTM: NSS redirect  OK ctx 0x%08x\n",(u32)g_nssctx);
		g_use_nss_path = 1;
	} else {
		printk("VRX320 PTM: NSS redirect register FAILED!!\n");
		g_use_nss_path=0;
	}
}
void vrx320_nss_redirect_unregister(void)
{
	if(g_nssctx) {
		nss_destroy_virt_if(g_nssctx);
	}
	g_use_nss_path=0;
	g_nssctx=NULL;
}
void * alloc_skb_dataptr_nss_redirect(int len)
{
	struct sk_buff * skb;

	len = (len + DMA_ALIGNMENT - 1) & ~(DMA_ALIGNMENT - 1);

	skb = dev_alloc_skb(len);
	if ( skb )
	{
		/*For NSS redirect: allign Eth Header on 2bytes and Ip header at word boundry*/
		skb_reserve(skb, (32+2));
		if ( ((u32)skb->data & 3) != 2 ) {
			panic("%s:%d: NSS redirect unaligned address - skb->data = 0x%08x!", __FUNCTION__, __LINE__, (u32)skb->data);
		}

		*((u32 *)skb->data - 1) = (u32)skb;
		return skb->data;
	}
	return NULL;
}
void vrx320_nss_redirect_vlan_tag_remove(struct sk_buff *skb)
{
	/*
	* Remove the the VLAN tag
	* By default VLAN would be present
	* If no VLAN tag preset the this function should not be called
	*
	* copy src->macaddress and repleace at src-mac_address+4 
	*/
	char buf[12];

	memcpy(buf,skb->data,12);
	memcpy(skb->data+VLAN_HLEN, buf, 12);
	skb->data += VLAN_HLEN;
	skb->len -= VLAN_HLEN;
}
#endif

int vrx320_napi_recv(void *data, int len)
{
	struct sk_buff *skb = NULL;

	skb = get_skb_pointer((unsigned int)virt_to_dma(NULL, data));

	if (!skb) {
		printk(KERN_ERR "%s Invalid skb pointer \n", __func__);
		return 0;
	}

	skb->tail = skb->data + len;
	skb->len = len;

	len -= 4;		//remove flag header 
	ASSERT(len >= 60, "packet is too small: %d", len);

	skb->data += 4;
	skb->tail = skb->data + len;
	skb->len = len;

	if (ptm_push(skb, NULL, 0x7) == 0) {
		return 0;
	}

	dev_kfree_skb_any(skb);
	return 0;
}

static int gather_data(volatile rx_descriptor_t * dst, volatile rx_descriptor_t * src, int flag)
{
	char *srcdata, *dstdata;

	dstdata = (char *)dst->dataptr + dst->data_len;
	srcdata = (char *)dma_to_virt(NULL, src->dataptr);
	switch (flag) {
	case 1:		//sop
		vrx320_memcpy_swap(dstdata, srcdata, src->data_len);
		dst->data_len += src->data_len;
		break;
	case 2:		//no sop, eop
		vrx320_memcpy_swap(dstdata, srcdata + 4, src->data_len);
		dst->data_len += src->data_len;
		break;
	case 3:		//eop
		vrx320_memcpy_swap(dstdata, srcdata + 4, src->data_len + 4);
		dst->data_len += src->data_len;
	}

	return 0;
}


static int vrx320_poll_bondsw(struct napi_struct *napi, int budget)
{
	volatile rx_descriptor_t *rx_descriptor;
	volatile static rx_descriptor_t gather_descriptor;
	volatile rx_descriptor_t *gather_desc = &gather_descriptor;
	volatile rx_descriptor_t *rx_desc;
	int work_done = 0;
#ifdef VRX320_DEBUG
	int recheck_flag = 1;
  g_intr_cnt++;
#endif
	rx_descriptor = (volatile rx_descriptor_t *)g_host_desc_base.ds_des_base_virt;

	do {
		rx_desc = &rx_descriptor[g_cpu_to_wan_rx_desc_pos];
		if (rx_desc->own == 0) {

#ifdef VRX320_DEBUG
      if(recheck_flag==1) { 
				g_desc_reown_cnt++;
				recheck_flag = 0;
			}
#endif

			dma_sync_single_for_cpu(NULL, rx_desc->dataptr, 1600, DMA_FROM_DEVICE);
			if ((rx_desc->sop == 1) && (rx_desc->eop == 1)) {
#ifdef QCA_NSS_REDIRECT
			char *data = alloc_skb_dataptr_nss_redirect(2000);
#else
			char *data = alloc_dataptr_fragment_notrack(1600);
#endif
				if (data == NULL) {
					napi_complete(&vrx320_napi);
					if(g_bonding_rx_poll == 1) {
						vrx320_hrpoll_start();
					} else {
						vrx320_enable_rx_intr();
					}

					break;	/*      No buffer, give more time for memory reclaim */
				}

				/* dma_unmap_single(NULL, rx_desc->dataptr, 1600, DMA_FROM_DEVICE); */
				vrx320_memcpy_swap(data, (char *)dma_to_virt(NULL, rx_desc->dataptr), rx_desc->data_len + 4);
				vrx320_napi_recv(data, rx_desc->data_len);

				/* rx_desc->dataptr = dma_map_single(NULL, dataptr, 1600, DMA_FROM_DEVICE); */
				rx_desc->data_len = 1600;
				rx_desc->own = 1;
				work_done++;
				wmb();
			} else {
				/* Process or gather the packet */
				if (rx_desc->sop != 1) {
					/* Gather the pending packet here */
					if (rx_desc->eop == 1) {
						gather_data(gather_desc, rx_desc, 3);
					} else {
						gather_data(gather_desc, rx_desc, 2);
					}

					/* Change ownership of descriptor and proceed */
					/* rx_desc->dataptr = dma_map_single(NULL, dma_to_virt(NULL, rx_desc->dataptr), 1600, DMA_FROM_DEVICE); */
					rx_desc->data_len = 1600;
					rx_desc->own = 1;
					wmb();
				} else { 		/* SOP is set */
					/* Alloc a new packet */
#ifdef QCA_NSS_REDIRECT
					char *data = alloc_skb_dataptr_nss_redirect(2000);
#else
					char *data = alloc_dataptr_fragment_notrack(1600);
#endif
					if (data == NULL) {
						napi_complete(&vrx320_napi);
						if(g_bonding_rx_poll == 1) {
							vrx320_hrpoll_start();
						} else {
							vrx320_enable_rx_intr();
						}
						break;	/*      No buffer, give more time for memory reclaim */
					}
					gather_desc->dataptr = (unsigned int) data;
					gather_desc->data_len = 0;
					/* Call gather data */
					gather_data(gather_desc, rx_desc, 1);
					/* rx_desc->dataptr = dma_map_single(NULL, dma_to_virt(NULL, rx_desc.dataptr), 1600, DMA_FROM_DEVICE); */
					rx_desc->data_len = 1600;
					rx_desc->own = 1;
				}
				/* Normal packets should go here */
				if (rx_desc->eop == 1) {
					/* Complete packet is available so call ptm_push */
					vrx320_napi_recv((void *)gather_desc->dataptr, gather_desc->data_len);
          work_done++;
				}
			}
		} else {
     	if((*MBOX_IGU1_DSM_ISR & 0x20)==0x20){
        *MBOX_IGU1_DSM_ISRC=0x20;
#ifdef VRX320_DEBUG
        g_repoll_cnt++;
				recheck_flag=1;
#endif
        continue;
      }
			napi_complete(&vrx320_napi);
			if(g_bonding_rx_poll == 1) {
					vrx320_hrpoll_start();
			} else {
					vrx320_enable_rx_intr();
			}

			break;
		}
		g_cpu_to_wan_rx_desc_pos = (g_cpu_to_wan_rx_desc_pos + 1) % SOC_DS_DES_NUM;
		//work_done++;
	} while (work_done < budget);
#ifdef VRX320_DEBUG
  if(work_done==0) 
		g_fake_isr++;
  if(work_done < g_wd_min) 
		g_wd_min=work_done;
  if(work_done > g_wd_max) 
		g_wd_max=work_done;
  g_wd_avg += work_done;
  g_wd_cnt++;
#endif
	if(work_done == 0) {
		g_rx_empty_cnt++;
		if(g_rx_empty_cnt > 5) {
			g_bonding_rx_poll = 0;
			g_rx_empty_cnt=0;
		}
	} else {
			g_bonding_rx_poll = 1;
	}
	return work_done;
}


static int vrx320_poll(struct napi_struct *napi, int budget)
{
	volatile rx_descriptor_t *rx_descriptor;
	int work_done = 0;
#ifdef VRX320_DEBUG
	int recheck_flag = 1;
  g_intr_cnt++;
#endif
	rx_descriptor = (volatile rx_descriptor_t *)g_host_desc_base.ds_des_base_virt;

	do {
		volatile rx_descriptor_t *desc = &rx_descriptor[g_cpu_to_wan_rx_desc_pos];
		if (desc->own == 0) {
#ifdef QCA_NSS_REDIRECT
			char *data = alloc_skb_dataptr_nss_redirect(2000);
#else
			char *data = alloc_dataptr_fragment_notrack(1600);
#endif
#ifdef VRX320_DEBUG
      if(recheck_flag==1) { 
				g_desc_reown_cnt++;
				recheck_flag = 0;
			}
#endif
			if (data == NULL) {
				napi_complete(&vrx320_napi);
	  		if(g_bonding_rx_poll == 1) {
					vrx320_hrpoll_start();
				} else {
					vrx320_enable_rx_intr();
				}
				break;	
			}

			dma_sync_single_for_cpu(NULL, desc->dataptr, 1600, DMA_FROM_DEVICE);
			/* dma_unmap_single(NULL, desc->dataptr, 1600, DMA_FROM_DEVICE); */
			vrx320_memcpy_swap(data, (char *)dma_to_virt(NULL, desc->dataptr), desc->data_len + 4);

			vrx320_napi_recv(data, desc->data_len);

			/* desc->dataptr = dma_map_single(NULL, dma_to_virt(NULL, desc->dataptr), 1600, DMA_FROM_DEVICE); */
			desc->data_len = 1600;
			desc->own = 1;
			wmb();
		} else {
      if((*MBOX_IGU1_ISR & 0x20)==0x20){
        *MBOX_IGU1_ISRC=0x20;
#ifdef VRX320_DEBUG
        g_repoll_cnt++;
				recheck_flag=1;
#endif
        continue;
      }
			napi_complete(&vrx320_napi);
	  	if(g_bonding_rx_poll == 1) {
				vrx320_hrpoll_start();
			} else {
				vrx320_enable_rx_intr();
			}
			break;
		}
		g_cpu_to_wan_rx_desc_pos = (g_cpu_to_wan_rx_desc_pos + 1) % SOC_DS_DES_NUM;
		work_done++;
	} while (work_done < budget);
#ifdef VRX320_DEBUG
  if(work_done==0) 
		g_fake_isr++;
  if(work_done < g_wd_min) 
		g_wd_min=work_done;
  if(work_done > g_wd_max) 
		g_wd_max=work_done;
  g_wd_avg += work_done;
  g_wd_cnt++;
#endif
	if(work_done == 0) {
		g_rx_empty_cnt++;
		if(g_rx_empty_cnt > 5) {
			g_bonding_rx_poll = 0;
			g_rx_empty_cnt=0;
		}
	} else {
			g_bonding_rx_poll = 1;
	}
	return work_done;
}

static void ptm_setup(struct net_device *dev)
{
	struct eth_priv_data *priv = ifx_eth_fw_netdev_priv(dev);
	int val;
	int i;

#ifndef CONFIG_LANTIQ_ETH_FRAMEWORK
#if LINUX_VERSION_CODE < KERNEL_VERSION(2,6,32)
	dev->get_stats = ptm_get_stats;
	dev->open = ptm_open;
	dev->stop = ptm_stop;
	dev->hard_start_xmit = g_dsl_bonding ? ptm_qos_hard_start_xmit_b : ptm_qos_hard_start_xmit;
	dev->set_mac_address = ptm_set_mac_address;
	dev->do_ioctl = ptm_ioctl;
	dev->tx_timeout = ptm_tx_timeout;
#else
	if (g_dsl_bonding)
		g_ptm_netdev_ops[0].ndo_start_xmit = ptm_qos_hard_start_xmit_bondsw;
	dev->netdev_ops = &g_ptm_netdev_ops[0];
#endif
	dev->watchdog_timeo = ETH_WATCHDOG_TIMEOUT;
#endif
	priv->dev_id = 7;	//  DSL

	for (i = 0, val = 0; i < 6; i++)
		val += dev->dev_addr[i];
	if (val == 0) {
		dev->dev_addr[0] = 0x00;
		dev->dev_addr[1] = 0x20;
		dev->dev_addr[2] = 0xda;
		dev->dev_addr[3] = 0x86;
		dev->dev_addr[4] = 0x23;
		dev->dev_addr[5] = 0xee;
	}
}

static struct net_device_stats *ptm_get_stats(struct net_device *dev)
{
	struct eth_priv_data *priv = ifx_eth_fw_netdev_priv(dev);

#if 0
	int port = 7;

	priv->stats.rx_packets = priv->rx_packets
	    + ITF_MIB_TBL(port)->ig_fast_brg_pkts
	    + ITF_MIB_TBL(port)->ig_fast_rt_ipv4_udp_pkts
	    + ITF_MIB_TBL(port)->ig_fast_rt_ipv4_tcp_pkts
	    + ITF_MIB_TBL(port)->ig_fast_rt_ipv4_mc_pkts
	    + ITF_MIB_TBL(port)->ig_fast_rt_ipv6_udp_pkts
	    + ITF_MIB_TBL(port)->ig_fast_rt_ipv6_tcp_pkts;
	priv->stats.rx_bytes = priv->rx_bytes
	    + ITF_MIB_TBL(port)->ig_fast_brg_bytes
	    + ITF_MIB_TBL(port)->ig_fast_rt_ipv4_bytes
	    + ITF_MIB_TBL(port)->ig_fast_rt_ipv6_bytes;
	priv->stats.rx_errors = 0;
	priv->stats.rx_dropped = priv->rx_dropped
	    + ITF_MIB_TBL(port)->ig_drop_pkts;

	priv->stats.tx_packets =
	    priv->tx_packets + ITF_MIB_TBL(port)->eg_fast_pkts;
	priv->stats.tx_bytes = priv->tx_bytes;
	priv->stats.tx_errors = priv->tx_errors;
	priv->stats.tx_dropped = priv->tx_dropped;
#else
	priv->stats.rx_packets = priv->rx_packets;
	priv->stats.rx_bytes = priv->rx_bytes;
	priv->stats.rx_errors = 0;
	priv->stats.rx_dropped = priv->rx_dropped;

	priv->stats.tx_packets = priv->tx_packets;
	priv->stats.tx_bytes = priv->tx_bytes;
	priv->stats.tx_errors = priv->tx_errors;
	priv->stats.tx_dropped = priv->tx_dropped;
#endif

	return &priv->stats;
}

static int ptm_open(struct net_device *dev)
{

#ifdef LANTIQ_ENV		//MURALI
	if (ifx_ppa_drv_datapath_mac_entry_setting) {
		ifx_ppa_drv_datapath_mac_entry_setting(dev->dev_addr, 0, 6, 10, 1, 1);
	}
	turn_on_dma_rx(port);
#endif


#ifndef CONFIG_LANTIQ_ETH_FRAMEWORK
	netif_start_queue(dev);
#endif

#ifdef CONFIG_IFX_LED
	g_wrx_bc_user_cw = *RECEIVE_NON_IDLE_CELL_CNT(0, g_vrx218_dev_us.membase) +
	    *RECEIVE_NON_IDLE_CELL_CNT(1, g_vrx218_dev_us.membase);
	g_total_tx_cw = *TRANSMIT_CELL_CNT(0, g_vrx218_dev_us.membase) + *TRANSMIT_CELL_CNT(1,
	     g_vrx218_dev_us.  membase);
	if (g_dsl_bonding) {
		g_wrx_bc_user_cw += *RECEIVE_NON_IDLE_CELL_CNT(0, g_vrx218_dev_ds.membase) +
		    *RECEIVE_NON_IDLE_CELL_CNT(1, g_vrx218_dev_ds.membase);
		g_total_tx_cw += *TRANSMIT_CELL_CNT(0, g_vrx218_dev_ds.membase) +
		    *TRANSMIT_CELL_CNT(1, g_vrx218_dev_ds.membase);
	}
	g_dsl_led_polling_timer.expires = jiffies + HZ / 10;	//  100ms
	add_timer(&g_dsl_led_polling_timer);
#endif

	return 0;
}

static int ptm_stop(struct net_device *dev)
{

#ifdef CONFIG_IFX_LED
	del_timer(&g_dsl_led_polling_timer);
#endif

#ifdef LANTIQ_ENV
	turn_off_dma_rx(port);
#endif

#ifndef CONFIG_LANTIQ_ETH_FRAMEWORK
	netif_stop_queue(dev);
#endif

#ifdef LANTIQ_ENV
	if (ifx_ppa_drv_datapath_mac_entry_setting) {
		ifx_ppa_drv_datapath_mac_entry_setting(dev->dev_addr, 0, 6, 10,
						       1, 2);
	}
#endif

	return 0;
}


int ptm_qos_hard_start_xmit_bondsw(struct sk_buff *skb, struct net_device *dev)
{
	int qid;
	unsigned long sys_flag;
	volatile struct tx_descriptor *desc;
	struct tx_descriptor reg_desc;
	int padding = 0;
	int len;
	u32 fcs;
	struct eth_priv_data *priv = ifx_eth_fw_netdev_priv(dev);
	int r = 0;
	char *data=NULL;

	if ( !in_showtime() ) {
		goto ETH_XMIT_DROP;
	}
#ifdef QCA_NSS_REDIRECT
	if ( skb->cb[13] != 0x5A ) {
		if( (g_vlanid >= 0) && (__vlan_put_tag(skb,g_vlanid) == NULL) ) {
			printk("VRX320 PTM: Vlan tag insert failed\n"); 
			priv->tx_dropped++; 
			dev_kfree_skb_any(skb);
			return 0; 
		}
	}
#endif

	dump_skb(skb, skb->len, "ptm_qos_hard_start_xmit_bondsw - raw", 0, 0, 1);

	len = skb->len <= ETH_MIN_TX_PACKET_LENGTH ? ETH_MIN_TX_PACKET_LENGTH : skb->len;

	if ( skb->cb[13] == 0x5A )  //  magic number indicating forcing QId (e.g. directpath)
		qid = skb->cb[15];
	else
		qid = get_qid_by_priority(PTM_PORT , skb->priority);

	padding = 4 - (skb->len & 3);
	if(padding != 4 && len == skb->len)
		len += padding;

	spin_lock_irqsave(&g_cpu_to_wan_tx_desc_lock, sys_flag);
	desc = (volatile struct tx_descriptor *)(CPU_TO_WAN_TX_DESC_BASE + g_cpu_to_wan_tx_desc_pos);
	if ( !desc->own )    //  PPE hold
	{
		spin_unlock_irqrestore(&g_cpu_to_wan_tx_desc_lock, sys_flag);
		goto NO_FREE_DESC;
	}
	if ( ++g_cpu_to_wan_tx_desc_pos == CPU_TO_WAN_TX_DESC_NUM )
		g_cpu_to_wan_tx_desc_pos = 0;
	spin_unlock_irqrestore(&g_cpu_to_wan_tx_desc_lock, sys_flag);


	data = kmalloc(len + 8, GFP_ATOMIC);
	if ( !data ) {
		goto ALLOC_SKB_TX_FAIL;
	}

	memcpy(data, skb->data, skb->len);
	if(len > skb->len) {
		memset(data + skb->len, '\0', len - skb->len);
	}

	fcs = ether_crc_le(len, data);
	*((u32 *)(data + len)) = ~fcs;

	if(desc->dataptr) {
			r = vrx320_memcpy_swap((char *)dma_to_virt(NULL, desc->dataptr), data, len+4);
			len += (4 + r);
	} else {
			goto ETH_XMIT_DROP;
	}
	if(data) {
		kfree(data);
		data = NULL;
	}

	wmb();
	dev_kfree_skb_any(skb);
	/*  load descriptor from memory */
	reg_desc = *desc;


#ifdef LANTIQ_ENV
	put_skb_to_dbg_pool(skb);
#endif
	skb = NULL;

	dma_sync_single_for_device(NULL, reg_desc.dataptr, 1600, DMA_TO_DEVICE);
	/*  update descriptor   */
	reg_desc.byteoff    = 0;
	reg_desc.datalen    = (len);
	reg_desc.qos        = qid;
	reg_desc.own        = 0;
	reg_desc.c          = 0;
	reg_desc.sop = reg_desc.eop = 1;


	/*  update MIB  */

	dev->trans_start = jiffies;
	priv->tx_packets++;
	priv->tx_bytes += len;

	/*  write discriptor to memory and write back cache */
	*((volatile u32 *)desc + 1) = *((u32 *)&reg_desc + 1);
	*(volatile u32 *)desc = *(u32 *)&reg_desc;
	wmb();

	
	return 0;
NO_FREE_DESC:
ALLOC_SKB_TX_FAIL:
ETH_XMIT_DROP:
	dev_kfree_skb_any(skb);
	priv->tx_dropped++;
	if(data) {
		kfree(data);
	}
	return 0;
}


static int ptm_qos_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
{
	int qid;
	unsigned long sys_flag;
	volatile struct tx_descriptor *desc;
	struct tx_descriptor reg_desc;
	//int byteoff;
	int len;
	int snd_len;
	struct eth_priv_data *priv = ifx_eth_fw_netdev_priv(dev);
	int r = 0;

	if ( !in_showtime() ) {
		goto ETH_XMIT_DROP;
	}

#ifdef QCA_NSS_REDIRECT
if(skb->cb[13] != 0x5A){
	if( (g_vlanid >= 0) && (__vlan_put_tag(skb,g_vlanid) == NULL) ) { 
		printk("VRX320 PTM: Vlan tag insert failed\n"); 
		priv->tx_dropped++; 
		dev_kfree_skb_any(skb);
		return 0; 
	}
}
#endif


	if ( skb->cb[13] == 0x5A )  //  magic number indicating forcing QId (e.g. directpath)
		qid = skb->cb[15];
	else
		qid = get_qid_by_priority(PTM_PORT , skb->priority);


	/*  allocate descriptor */
	spin_lock_irqsave(&g_cpu_to_wan_tx_desc_lock, sys_flag);
	desc = (volatile struct tx_descriptor *)(CPU_TO_WAN_TX_DESC_BASE + g_cpu_to_wan_tx_desc_pos);
	if ( desc->own ) {
		spin_unlock_irqrestore(&g_cpu_to_wan_tx_desc_lock, sys_flag);
#ifdef VRX320_DEBUG
    g_tx_nodesc_cnt++;
#endif
		goto NO_FREE_DESC;
	}

	if ( ++g_cpu_to_wan_tx_desc_pos == CPU_TO_WAN_TX_DESC_NUM )
		g_cpu_to_wan_tx_desc_pos = 0;
	spin_unlock_irqrestore(&g_cpu_to_wan_tx_desc_lock, sys_flag);

	dump_skb(skb, skb->len, "ptm_qos_hard_start_xmit - raw", 0, 0, 1);

	if(desc->dataptr) {
		r = vrx320_memcpy_swap((char *)dma_to_virt(NULL, desc->dataptr), skb->data, skb->len);
		len = skb->len + r;
	} else {
		goto ETH_XMIT_DROP;
	}

	dump_skb(skb, skb->len, "ptm_qos_hard_start_xmit - swap", 0, 0, 1);

	/*  load descriptor from memory */
	reg_desc = *desc;

	len = skb->len <= ETH_MIN_TX_PACKET_LENGTH ? ETH_MIN_TX_PACKET_LENGTH : skb->len;
	//byteoff = (u32)skb->data & (DMA_ALIGNMENT - 1);
	reg_desc.small      = (unsigned int)skb->end - (unsigned int)skb->data < DMA_PACKET_SIZE ? 1 : 0;

	dev_kfree_skb_any(skb);
	snd_len = len;





	/*  update descriptor   */
	dma_sync_single_for_device(NULL, reg_desc.dataptr, snd_len, DMA_TO_DEVICE);

	reg_desc.byteoff    = 0;
	reg_desc.datalen    = (snd_len);
	reg_desc.qos        = qid;
	reg_desc.own        = 1;
	reg_desc.c          = 0;
	reg_desc.sop = reg_desc.eop = 1;

	/*  update MIB  */

	dev->trans_start = jiffies;
	priv->tx_packets++;
	priv->tx_bytes += len;

	/*  write discriptor to memory and write back cache */
	*((volatile u32 *)desc + 1) = *((u32 *)&reg_desc + 1);
	*(volatile u32 *)desc = *(u32 *)&reg_desc;

	return 0;

NO_FREE_DESC:
ETH_XMIT_DROP:
	dev_kfree_skb_any(skb);
	priv->tx_dropped++;
	return 0;
}

#ifdef LANTIQ_ENV
static int ptm_qos_hard_start_xmit_b(struct sk_buff *skb, struct net_device *dev)
{
	int qid;

	skb->dev = dev;
	if ( skb->cb[13] == 0x5A )  //  magic number indicating forcing QId (e.g. directpath)
		qid = skb->cb[15];
	else
	qid = get_qid_by_priority(PTM_PORT, skb->priority);
	dump_skb(skb, skb->len, __FUNCTION__, 0, 0, 1);
	swap_mac(skb->data);
	eth_xmit(skb, PTM_PORT /* DSL */, 2, 2, get_class_by_qid(PTM_PORT, qid));
	return 0;
}
#endif

static int ptm_set_mac_address(struct net_device *dev, void *p)
{
	struct sockaddr *addr = (struct sockaddr *)p;
#ifdef ROUT_MAC_CFG_TBL
	u32 addr1, addr2;
	int i;
#endif

#ifdef ROUT_MAC_CFG_TBL
	addr1 = (((u32) dev->dev_addr[0] & 0xFF) << 24) | (((u32) dev-> dev_addr[1] & 0xFF) << 16) | 
		(((u32) dev-> dev_addr[2] & 0xFF) << 8) | ((u32) dev->dev_addr[3] & 0xFF);
	addr2 = (((u32) dev->dev_addr[4] & 0xFF) << 24) | (((u32) dev-> dev_addr[5] & 0xFF) << 16);
	for (i = 0; i < 16; i++)
		if (ROUT_MAC_CFG_TBL(i)[0] == addr1 && ROUT_MAC_CFG_TBL(i)[1] == addr2) {
			ROUT_MAC_CFG_TBL(i)[0] = (((u32) addr-> sa_data[0] & 0xFF) << 24) | (((u32) addr-> sa_data[1] & 0xFF) << 16) | 
			(((u32) addr-> sa_data[2] & 0xFF) << 8) | ((u32) addr-> sa_data [3] & 0xFF);
			ROUT_MAC_CFG_TBL(i)[1] = (((u32) addr-> sa_data[4] & 0xFF) << 24) | (((u32) addr-> sa_data[5] & 0xFF) << 16);
			break;
		}
#endif

	memcpy(dev->dev_addr, addr->sa_data, dev->addr_len);

	return 0;
}

static int ptm_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
{
	switch (cmd) {
#if 0
	case IFX_PTM_MIB_CW_GET:
		((PTM_CW_IF_ENTRY_T *) ifr->ifr_data)->ifRxNoIdleCodewords =
		    PTM_MIB_TABLE(0)->wrx_nonidle_cw +
		    PTM_MIB_TABLE(1)->wrx_nonidle_cw;
		((PTM_CW_IF_ENTRY_T *) ifr->ifr_data)->ifRxIdleCodewords =
		    PTM_MIB_TABLE(0)->wrx_idle_cw +
		    PTM_MIB_TABLE(1)->wrx_idle_cw;
		((PTM_CW_IF_ENTRY_T *) ifr->ifr_data)->ifRxCodingViolation =
		    PTM_MIB_TABLE(0)->wrx_err_cw + PTM_MIB_TABLE(1)->wrx_err_cw;
		((PTM_CW_IF_ENTRY_T *) ifr->ifr_data)->ifTxNoIdleCodewords = 0;	//  not available
		((PTM_CW_IF_ENTRY_T *) ifr->ifr_data)->ifTxIdleCodewords = 0;	//  not available
		break;
	case IFX_PTM_MIB_FRAME_GET:
		{
			PTM_FRAME_MIB_T data = { 0 };

			data.RxCorrect =
			    PTM_MIB_TABLE(0)->wrx_correct_pdu +
			    PTM_MIB_TABLE(1)->wrx_correct_pdu;
			data.RxDropped =
			    PTM_MIB_TABLE(0)->wrx_nodesc_drop_pdu +
			    PTM_MIB_TABLE(0)->wrx_len_violation_drop_pdu +
			    PTM_MIB_TABLE(1)->wrx_nodesc_drop_pdu +
			    PTM_MIB_TABLE(1)->wrx_len_violation_drop_pdu;
			data.TxSend =
			    PTM_MIB_TABLE(0)->wtx_total_pdu +
			    PTM_MIB_TABLE(1)->wtx_total_pdu;
			data.TC_CrcError = 0;	//  not available

			*((PTM_FRAME_MIB_T *) ifr->ifr_data) = data;
		}
		break;
	case IFX_PTM_CFG_GET:
		//  use bear channel 0 preemption gamma interface settings
		((IFX_PTM_CFG_T *) ifr->ifr_data)->RxEthCrcPresent =
		    PTM_CRC_CFG->wrx_fcs_crc_vld;
		((IFX_PTM_CFG_T *) ifr->ifr_data)->RxEthCrcCheck =
		    PTM_CRC_CFG->wrx_fcs_crc_chk;
		((IFX_PTM_CFG_T *) ifr->ifr_data)->RxTcCrcCheck =
		    PTM_CRC_CFG->wrx_tc_crc_chk;
		((IFX_PTM_CFG_T *) ifr->ifr_data)->RxTcCrcLen =
		    PTM_CRC_CFG->wrx_tc_crc_len;
		((IFX_PTM_CFG_T *) ifr->ifr_data)->TxEthCrcGen =
		    PTM_CRC_CFG->wtx_fcs_crc_gen;
		((IFX_PTM_CFG_T *) ifr->ifr_data)->TxTcCrcGen =
		    PTM_CRC_CFG->wtx_tc_crc_gen;
		((IFX_PTM_CFG_T *) ifr->ifr_data)->TxTcCrcLen =
		    PTM_CRC_CFG->wtx_tc_crc_len;
		break;
	case IFX_PTM_CFG_SET:
		PTM_CRC_CFG->wrx_fcs_crc_vld =
		    ((IFX_PTM_CFG_T *) ifr->ifr_data)->RxEthCrcPresent;
		PTM_CRC_CFG->wrx_fcs_crc_chk =
		    ((IFX_PTM_CFG_T *) ifr->ifr_data)->RxEthCrcCheck;
		PTM_CRC_CFG->wrx_tc_crc_chk =
		    ((IFX_PTM_CFG_T *) ifr->ifr_data)->RxTcCrcCheck;
		PTM_CRC_CFG->wrx_tc_crc_len =
		    ((IFX_PTM_CFG_T *) ifr->ifr_data)->RxTcCrcLen;
		PTM_CRC_CFG->wtx_fcs_crc_gen =
		    ((IFX_PTM_CFG_T *) ifr->ifr_data)->TxEthCrcGen;
		PTM_CRC_CFG->wtx_tc_crc_gen =
		    ((IFX_PTM_CFG_T *) ifr->ifr_data)->TxTcCrcGen;
		PTM_CRC_CFG->wtx_tc_crc_len =
		    ((IFX_PTM_CFG_T *) ifr->ifr_data)->TxTcCrcLen;
		break;
	case IFX_PTM_MAP_PKT_PRIO_TO_Q:
		break;
#endif
	default:
		return -EOPNOTSUPP;
	}

	return 0;
}

static void ptm_tx_timeout(struct net_device *dev)
{
	struct eth_priv_data *priv = ifx_eth_fw_netdev_priv(dev);

	priv->tx_errors++;

	netif_wake_queue(dev);

	return;
}

int ptm_push(struct sk_buff *skb, struct flag_header *header, unsigned int ifid)
{
	struct eth_priv_data *priv;
	u32 fcs;

	if ( ifid != 7 ) {
		printk(KERN_ERR "ifid != 7\n");
		return -EINVAL;
	}

	if ( !g_ptm_net_dev[0] ) {    //  Ethernet WAN mode, PTM device is not initialized, but it might get ingress packet, just drop the packet.
		printk(KERN_ERR "WAN mode is not PTM\n");
		return -EIO;
	}

/*
	r = rx_swap_data(skb->data, skb->len);
	if(r) {
		skb->len += r;
	}
*/
	dump_skb(skb, skb->len, __FUNCTION__, 0, 0, 0);
	priv = ifx_eth_fw_netdev_priv(g_ptm_net_dev[0]);

	/*FCS verification */ 
	if(g_dsl_bonding != 0){   
		fcs = ether_crc_le(skb->len-4, skb->data);
		if(~fcs != *((u32 *)(skb->tail-4))){
			if (printk_ratelimit())
				printk(KERN_DEBUG "FCS mismatch Computed=%#x Received=%#x\n", ~fcs, *((u32 *) (skb->tail - 4)));
			priv->rx_dropped++;
			dev_kfree_skb_any(skb);
			return 0;
		}
		/* Remove the fcs */
		skb->len -= 4;
	}

	if ( netif_running(g_ptm_net_dev[0]) ) {
#ifdef QCA_NSS_REDIRECT
		if(g_vlanid >= 0){
		/*VLAN Tag present remove it as it could cause trouble with NSS redirect*/
		vrx320_nss_redirect_vlan_tag_remove(skb);
		}
#endif

		skb->dev = g_ptm_net_dev[0];
		skb->protocol = eth_type_trans(skb, g_ptm_net_dev[0]);

#ifdef QCA_NSS_REDIRECT
		/*
		 * Attempt to pass the packet to NSS
		 * As of now bonding not supported
		 */
/*
		if(g_dsl_bonding != 0) {
			goto pass_to_host;
		}
*/

		if( g_use_nss_path && g_nssctx) {
			if(nss_tx_virt_if_rxbuf(g_nssctx, skb)) {
				/*NSS redirect failed, send packet to host*/		
				goto pass_to_host;
			} else {
				priv->rx_packets++;
				priv->rx_bytes += skb->len;
				nss_pkt_count++;
			}
			return 0;
		}
pass_to_host:
#endif

		if ( netif_receive_skb(skb) == NET_RX_DROP ) {
			priv->rx_dropped++;
		} else {
			priv->rx_packets++;
			priv->rx_bytes += skb->len;
		}
	} else {
		dev_kfree_skb_any(skb);
		priv->rx_dropped++;
	}

	return 0;
}

#ifdef CONFIG_IFX_LED
static void dsl_led_flash(void)
{
	if (g_data_led_trigger != NULL)
		ifx_led_trigger_activate(g_data_led_trigger);
}

static void dsl_led_polling(unsigned long arg)
{
	unsigned int wrx_bc_user_cw, total_tx_cw;

	wrx_bc_user_cw = *RECEIVE_NON_IDLE_CELL_CNT(0, g_vrx218_dev_us.membase) +
	    *RECEIVE_NON_IDLE_CELL_CNT(1, g_vrx218_dev_us.membase);
	total_tx_cw = *TRANSMIT_CELL_CNT(0, g_vrx218_dev_us.membase) + 
		*TRANSMIT_CELL_CNT(1, g_vrx218_dev_us.  membase);
	if (g_dsl_bonding) {
		wrx_bc_user_cw += *RECEIVE_NON_IDLE_CELL_CNT(0, g_vrx218_dev_ds.membase) +
		    *RECEIVE_NON_IDLE_CELL_CNT(1, g_vrx218_dev_ds.membase);
		total_tx_cw += *TRANSMIT_CELL_CNT(0, g_vrx218_dev_ds.membase) +
		    *TRANSMIT_CELL_CNT(1, g_vrx218_dev_ds.membase);
	}

	if (wrx_bc_user_cw != g_wrx_bc_user_cw || total_tx_cw != g_total_tx_cw) {
		g_wrx_bc_user_cw = wrx_bc_user_cw;
		g_total_tx_cw = total_tx_cw;

		dsl_led_flash();
	}

	if (g_ptm_net_dev[0] != NULL && netif_running(g_ptm_net_dev[0])) {
		g_dsl_led_polling_timer.expires = jiffies + HZ / 10;	//  100ms
		add_timer(&g_dsl_led_polling_timer);
	}
}
#endif


static irqreturn_t mailbox_vrx218_dsm_irq_handler(int irq, void *dev_id)
{
	u32 mailbox0_signal = 0;
	u32 mailbox1_signal = 0;
	volatile uint32_t peer_state;

	*IMCU_DSM_IMER &= ~0x03;

	while ((mailbox1_signal = *MBOX_IGU1_DSM_ISR & *MBOX_IGU1_DSM_IER) != 0) {
		*MBOX_IGU1_DSM_ISRC = mailbox1_signal;

		if ((mailbox1_signal & 0x01)) {	//Bit 0
			*MBOX_IGU1_DSM_IER &= ~0x01;
#ifdef LANTIQ_ENV
			enable_vrx218_dma_tx(1);
#endif
		}

		if ((mailbox1_signal & 0x04)) {	//Bit 2
			/* TODO: swap queue */
		}

		if ((mailbox1_signal & 0x08)) {	//Bit 3  EDMA HANG
			g_pcie_reset_sig = 1;
		}

		if ((mailbox1_signal & 0x10)) {	//Bit 4  Peer to Peer link state update
			peer_state =
			    *SOC_ACCESS_VRX218_SB(__PEER_GIF_LINK_STATE_TMP,
						  g_vrx218_dev_ds.membase);
			*SOC_ACCESS_VRX218_SB(__PEER_GIF_LINK_STATE,
					      g_vrx218_dev_us.membase) =
			    peer_state;
		}
		if ((mailbox1_signal & 0x20)) {	//Bit 5  Interrupt to indicate packet arrival
			vrx320_disable_rx_intr();
			napi_schedule(&vrx320_napi);
		}
	}

	/* Clear TX interrupt at this moment.
	 * Implement flow control mechansim if there is specific requirement.
	 */
	mailbox0_signal = *MBOX_IGU0_DSM_ISR & *MBOX_IGU0_DSM_IER;
	*MBOX_IGU0_DSM_ISRC = mailbox0_signal;

	*IMCU_DSM_IMER |= 0x03;

	return IRQ_HANDLED;
}


int proc_read_pcie_rst(struct seq_file *seq, void *v)
{
	int len = 0;

	seq_printf(seq, "%d\n", g_pcie_reset_sig);

	return len;
}

static void dump_skb(struct sk_buff *skb, u32 len, const char *title, int port,
		     int ch, int is_tx)
{
#if defined(DEBUG_DUMP_SKB) && DEBUG_DUMP_SKB
	int i;

	if (!g_dump_cnt
	    || !(g_dbg_enable &
		 (is_tx ? DBG_ENABLE_MASK_DUMP_SKB_TX :
		  DBG_ENABLE_MASK_DUMP_SKB_RX)))
		return;

	if (g_dump_cnt > 0)
		g_dump_cnt--;

	if (skb->len < len)
		len = skb->len;

	if (ch >= 0)
		printk("%s (port %d, ch %d)\n", title, port, ch);
	else
		printk("%s\n", title);
	printk("  skb->data = %08X, skb->tail = %08X, skb->len = %d\n",
	       (u32) skb->data, (u32) skb->tail, (int)skb->len);
	for (i = 1; i <= len; i++) {
		if (i % 16 == 1)
			printk("  %4d:", i - 1);
		printk(" %02X", (int)(*((char *)skb->data + i - 1) & 0xFF));
		if (i % 16 == 0)
			printk("\n");
	}
	if ((i - 1) % 16 != 0)
		printk("\n");
#endif
}

#ifdef LANTIQ_ENV
static int swap_mac(unsigned char *data)
{
#if defined(DEBUG_SWAP_MAC) && DEBUG_SWAP_MAC
	int ret = 0;

	if ((g_dbg_enable & DBG_ENABLE_MASK_MAC_SWAP)) {
		unsigned char tmp[8];
		unsigned char *p = data;

		if (p[12] == 0x08 && p[13] == 0x06) {	//  arp
			if (p[14] == 0x00 && p[15] == 0x01 && p[16] == 0x08
			    && p[17] == 0x00 && p[20] == 0x00
			    && p[21] == 0x01) {
				//  dest mac
				memcpy(p, p + 6, 6);
				//  src mac
				p[6] = p[7] = 0;
				memcpy(p + 8, p + 38, 4);
				//  arp reply
				p[21] = 0x02;
				//  sender mac
				memcpy(p + 22, p + 6, 6);
				//  sender IP
				memcpy(tmp, p + 28, 4);
				memcpy(p + 28, p + 38, 4);
				//  target mac
				memcpy(p + 32, p, 6);
				//  target IP
				memcpy(p + 38, tmp, 4);

				ret = 42;
			}
		} else if (!(p[0] & 0x01)) {	//  bypass broadcast/multicast
			//  swap MAC
			memcpy(tmp, p, 6);
			memcpy(p, p + 6, 6);
			memcpy(p + 6, tmp, 6);
			p += 12;

			//  bypass VLAN
			while (p[0] == 0x81 && p[1] == 0x00)
				p += 4;

			//  IP
			if (p[0] == 0x08 && p[1] == 0x00) {
				p += 14;
				memcpy(tmp, p, 4);
				memcpy(p, p + 4, 4);
				memcpy(p + 4, tmp, 4);
				p += 8;
			}

            ret = (int)((unsigned long)p - (unsigned long)data);
        }
    }

	return ret;
#else
	return 0;
#endif
}
#endif

static int in_showtime(void) 
{
	int i;

	for (i = 0; i < LINE_NUMBER; i++) {
		if (g_showtime[i]) {
			return 1;
		}
	}

	return 0;
}

static int dsl_showtime_enter(const unsigned char line_idx,
			      struct port_cell_info *port_cell,
			      void *xdata_addr)
{
	ASSERT(line_idx < LINE_NUMBER,
	       "line_idx: %d large than max line num: %d", line_idx,
	       LINE_NUMBER);
  if(line_idx < LINE_NUMBER){
	  g_showtime[line_idx] = 1;
  }

	dbg("enter showtime");

	if(line_idx == 1) {
		int peer_state = *SOC_ACCESS_VRX218_SB(__PEER_GIF_LINK_STATE_TMP, g_vrx218_dev_ds.membase);
		*SOC_ACCESS_VRX218_SB(__PEER_GIF_LINK_STATE, g_vrx218_dev_us.membase) = peer_state;
		/* printk("line %d : peer_state = %#x\n", line_idx, peer_state); */
	}
  /*else if(line_idx == 0) {
		int peer_state = *SOC_ACCESS_VRX218_SB(__PEER_GIF_LINK_STATE_TMP, g_vrx218_dev_us.membase);
		*SOC_ACCESS_VRX218_SB(__PEER_GIF_LINK_STATE, g_vrx218_dev_ds.membase) = peer_state;
		printk("line %d : peer_state = %#x\n", line_idx, peer_state);
	}*/

	printk("line %d entered showtime\n", line_idx);
	return IFX_SUCCESS;
}

static int dsl_showtime_exit(const unsigned char line_idx)
{
	if (!g_showtime[line_idx])
		return IFX_ERROR;

	g_showtime[line_idx] = 0;

	dbg("leave showtime");
	printk("Line %d leave showtime\n", line_idx);
	if(line_idx == 1) {
		int peer_state = *SOC_ACCESS_VRX218_SB(__PEER_GIF_LINK_STATE_TMP, g_vrx218_dev_ds.membase);
		*SOC_ACCESS_VRX218_SB(__PEER_GIF_LINK_STATE, g_vrx218_dev_us.membase) = peer_state;
		/* printk("line %d : peer_state = %#x\n", line_idx, peer_state); */
	}
  /*else if(line_idx == 0) {
		int peer_state = *SOC_ACCESS_VRX218_SB(__PEER_GIF_LINK_STATE_TMP, g_vrx218_dev_us.membase);
		*SOC_ACCESS_VRX218_SB(__PEER_GIF_LINK_STATE, g_vrx218_dev_ds.membase) = peer_state;
		printk("line %d : peer_state = %#x\n", line_idx, peer_state);
	}*/

	return IFX_SUCCESS;
}

static void check_showtime(void)
{
	int i;
	struct port_cell_info port_cell = { 0 };
	int showtime = 0;
	void *xdata_addr = NULL;
	int ret = -1;
	ltq_mei_atm_showtime_check_t ltq_mei_atm_showtime_check = NULL;

	ltq_mei_atm_showtime_check =
	    (ltq_mei_atm_showtime_check_t)
	    ppa_callback_get(LTQ_MEI_SHOWTIME_CHECK);
	if (!ltq_mei_atm_showtime_check) {
		return;
	}

	for (i = 0; i < LINE_NUMBER; i++) {
		ret = ltq_mei_atm_showtime_check(i, &showtime, &port_cell, &xdata_addr);
		if (!ret && showtime) {
			dsl_showtime_enter(i, &port_cell, &xdata_addr);
		}
	}

	return;
}

static int vrx320_ptm_cpu_us_desc_init(void)
{
	int i = 0;
	volatile struct tx_descriptor *desc = CPU_TO_WAN_TX_DESC_BASE;
	for(i = 0; i < CPU_TO_WAN_TX_DESC_NUM; i++) {
		desc[i].dataptr = alloc_dataptr_skb();
		desc[i].datalen = 1600;
	}
	wmb();
	return 0;
}
static int vrx320_ptm_cpu_us_desc_exit(void)
{
	/* 
		free_dataptr_fragments(); will free all memory during exit 
	*/

	return 0;
}

int __init vrx218_ptm_datapath_init(const ltq_pcie_ep_dev_t * p_vrx218_dev_us,
				    const ltq_pcie_ep_dev_t * p_vrx218_dev_ds)
{
	int ret;
	/* struct port_cell_info port_cell = {0}; */
	/* void *xdata_addr = NULL; */
#ifdef CONFIG_LANTIQ_ETH_FRAMEWORK
	struct ifx_eth_fw_netdev_ops ptm_ops = {
		.get_stats = ptm_get_stats,
		.open = ptm_open,
		.stop = ptm_stop,
		.start_xmit = ptm_qos_hard_start_xmit,
		.set_mac_address = ptm_set_mac_address,
		.do_ioctl = ptm_ioctl,
		.tx_timeout = ptm_tx_timeout,
		.watchdog_timeo = ETH_WATCHDOG_TIMEOUT,
	};
#endif
	/* ltq_mei_atm_showtime_check_t ltq_mei_atm_showtime_check = NULL; */
	vrx320_ptm_cpu_us_desc_init();
	g_vrx218_dev_us = *p_vrx218_dev_us;
	g_vrx218_dev_ds = *p_vrx218_dev_ds;

	if (g_vrx218_dev_us.phy_membase != g_vrx218_dev_ds.phy_membase) {
		g_dsl_bonding = 2;
#ifdef CONFIG_LANTIQ_ETH_FRAMEWORK
		ptm_ops.start_xmit = ptm_qos_hard_start_xmit_b;
#endif
	}
#ifdef CONFIG_IFX_LED
	setup_timer(&g_dsl_led_polling_timer, dsl_led_polling, 0);
#endif

	g_ptm_net_dev[0] = ifx_eth_fw_alloc_netdev(sizeof(struct eth_priv_data), "ptm0", &ptm_ops);
	if (g_ptm_net_dev[0] == NULL) {
		ret = -ENOMEM;
		goto ALLOC_NETDEV_PTM_FAIL;
	}
	ptm_setup(g_ptm_net_dev[0]);
	ret = ifx_eth_fw_register_netdev(g_ptm_net_dev[0]);
	if (ret != 0)
		goto RETISTER_NETDEV_PTM_FAIL;

	/* request irq (enable by default) */
	if (g_dsl_bonding) {
		netif_napi_add(g_ptm_net_dev[0], &vrx320_napi, vrx320_poll_bondsw, 32);
	} else {
		netif_napi_add(g_ptm_net_dev[0], &vrx320_napi, vrx320_poll, 64);
	}
	napi_enable(&vrx320_napi);
	/* For Akronite BIT5 of IGU1 is sued to indicate the arrival of packet so request_irq in any case */
	ret = request_irq(g_vrx218_dev_ds.irq, mailbox_vrx218_dsm_irq_handler,
			IRQF_DISABLED, "vrx318_ppe_isr", NULL);
	if (ret != 0) {
		printk(KERN_ERR "Failed to request PCIe MSI irq %s:%u\n",
		       "vrx318 DS ", g_vrx218_dev_ds.irq);
		goto REQUEST_IRQ_FAIL;
	}

#ifdef LANTIQ_ENV
	enable_vrx218_swap(1, 0, g_dsl_bonding);
	enable_vrx218_dma_rx(1);
	g_smartphy_push_fn = ptm_push;
	g_smartphy_port_num = 1;
#endif
	/* call enable_vrx218_dma_tx(1); in mailbox_irq_handler in vrx218_ptm_main.c */


	check_showtime();
	ppa_callback_set(LTQ_MEI_SHOWTIME_ENTER, dsl_showtime_enter);
	ppa_callback_set(LTQ_MEI_SHOWTIME_EXIT, dsl_showtime_exit);

#ifdef CONFIG_IFX_LED
	ifx_led_trigger_register("dsl_data", &g_data_led_trigger);
#endif
#ifdef QCA_NSS_REDIRECT
	vrx320_nss_redirect_register(g_ptm_net_dev[0]);
#endif

	return 0;

REQUEST_IRQ_FAIL:
	printk("PTM datapath initialization fail!!!\n");
	ifx_eth_fw_unregister_netdev(g_ptm_net_dev[0], 0);
RETISTER_NETDEV_PTM_FAIL:
	ifx_eth_fw_free_netdev(g_ptm_net_dev[0], 0);
	g_ptm_net_dev[0] = NULL;
ALLOC_NETDEV_PTM_FAIL:
	return ret;
}

void __exit vrx218_ptm_datapath_exit(void)
{
#ifdef CONFIG_IFX_LED
	del_timer(&g_dsl_led_polling_timer);
	ifx_led_trigger_deregister(g_data_led_trigger);
	g_data_led_trigger = NULL;
#endif

	ppa_callback_set(LTQ_MEI_SHOWTIME_ENTER, (void *)NULL);
	ppa_callback_set(LTQ_MEI_SHOWTIME_EXIT, (void *)NULL);

#ifdef LANTIQ_ENV
	g_smartphy_port_num = 0;
	g_smartphy_push_fn = NULL;
#endif

#ifdef LANTIQ_ENV
	enable_vrx218_dma_tx(0);
	enable_vrx218_dma_rx(0);
	enable_vrx218_swap(0, 0, 0);
#endif

	free_irq(g_vrx218_dev_ds.irq, NULL);
#ifdef QCA_NSS_REDIRECT
	vrx320_nss_redirect_unregister();
#endif

	ifx_eth_fw_unregister_netdev(g_ptm_net_dev[0], 0);
	ifx_eth_fw_free_netdev(g_ptm_net_dev[0], 0);
	g_ptm_net_dev[0] = NULL;
	vrx320_ptm_cpu_us_desc_exit();

}
