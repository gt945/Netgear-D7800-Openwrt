#ifndef _HTTPD_H
#define _HTTPD_H

#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include <string.h>
#include <syslog.h>
#include <errno.h>
#include <fcntl.h>
#include <time.h>
#include <ctype.h>
#include <unistd.h>
#include <dirent.h>
#include <features.h>
#include <netinet/in.h>
#include <netinet/ip.h>
#include <netinet/udp.h>
#include <arpa/inet.h>
#include <sys/wait.h>
#include <sys/time.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <sys/signal.h>
#include <sys/sysinfo.h>
#include <sys/statfs.h>
#include <sys/ioctl.h>
#include <linux/if.h>
#include <linux/if_arp.h>
#include <net/ethernet.h>
#include <linux/if_packet.h>
#include <setjmp.h>
#include "config_file.h"

extern int dni_system(const char *output, const char *cmd, ...);

/*************************** Smart Wizard 3.0 **************************
  * This module refers to BOA-0.94.11 SOAP implemented by DNI's Xinwei.Niu. Thanks
  * very much for his hard work, so I can finish the task in so short time. Thanks again!
  *														--- DNI's ^_*
  *******************************************************************/


/************************** Smart Wizard 3.0 **************************/

/*********************************************************************
  * When accessing via HTTP or FTP, to avoid conflict with the existing administration GUI
  * all the Network Folders will be located in a subfolder called 'shares' e.g:
  * http://192.168.0.1/shares
  *
  * And the USB shared folders will be displayed in the standard basic directory browsing
  * style.
  *********************************************************************/


#if 0
#define HTTPUSB_DEBUGP(format, args...) printf(format, ## args)
#else
#define HTTPUSB_DEBUGP(format, args...)
#endif


extern int usb_enableHTTP;
extern int usb_enableHvia;
extern char usb_inetport[];

extern int remote_enable;
extern char remote_port[];

extern void http_access_type(char *host, int *direction, char **service, struct in_addr fromip);




#if 0
#define USB_DEBUGP(format, args...) printf(format, ## args)
#else
#define USB_DEBUGP(format, args...)
#endif

typedef unsigned int  uint32;
typedef unsigned short uint16;
typedef unsigned char uint8;

struct cgi_set
{
	char *cgi_name;	/* the item name on form page */
	char *cfg_name;	/* the item name in configuring */
};

enum {
	AUTH_OK,
	AUTH_TIMEOUT,
	AUTH_MULTI
};

extern char accept_lang[];
extern char lang_status[];
extern int new_lang_tbl;

extern int refresh_top;
extern char *refresh_url;
extern char *refresh_time;

extern long nullpass;
extern long need_auth;
extern struct in_addr login_ip;

extern int connValid;

extern char new_region[32];
extern char gui_region[32];

extern struct in_addr from_ip;

extern char *wan_if_name;
extern char *external_detwan_path;
extern char *ctl_mod;
extern char *upg_mod;
extern char *host_name;
extern char *uk_sky_option61;
#define rep_getchar(__len, __fp)	\
({	\
	while (__len--) {	\
		if (fgetc(__fp) == EOF) break;	\
	}	\
})

/*
  *  IE 7.0 sends `POST` request with two more '\r\n', but its 'Content-Length' doesn't
  * count these two more characters. Then writing to this 'fp' will fail on socket.
  */
#define Rep_GetTwoChars(__fp)	\
({	\
	int __fd = fileno(__fp);	\
	int __flags = fcntl(__fd, F_GETFL);	\
	if (__flags != -1 && fcntl(__fd, F_SETFL, __flags |O_NONBLOCK) != -1) {	\
		if (fgetc(__fp) != EOF)	\
			fgetc(__fp);	\
		fcntl(__fd, F_SETFL, __flags);	\
	}	\
})
			
/*********************************************************************/


struct disk_entry
{
	int is_mounted;
	char dev_name[32];	/* /dev/sda1 */
	char part_name[32];	/* sda1*/
	char mnt_path[32];		/* normal such as: /mnt/sda1 */
	char vol_name[31];		/* Volume Name */
	char lable;

	char *fs_type;	/* FileSystem Type */
	char vendor[128]; /* Device Name, such as `FUJITSU MHV2080BH ` */

	unsigned long long capacity; /* capacity size in MB */
	unsigned long long dev_cap;
	unsigned long long avail;	/* free data size in MB */
};


extern struct disk_entry *scan_disk_entries(int *num);
extern int check_approved(struct disk_entry *diskparts, int i);
extern void format_capacity(char *buf, int buflen, unsigned long long mbytes);
extern int is_sda(char * dev);
/*********************************************************************/

/************************** main.c **************************/
typedef void (*cmd_func) (void);
extern void safe_fork(void);
extern void do_cmd(char * cmd);
extern void sys_cmd(cmd_func cmd);

/************************** libconfig.so **************************/
extern void init_libconfig(void); /* NOTE: when successfully `fork()', calling this to re-initialized the lib-config. */
extern void config_set(char *name, char *value);
extern void config_unset(char *name);
extern void config_default(void);
extern void config_commit(void);
extern char *config_get(char *name);
extern int config_backup(char *ofile); /* 0 : success; 1 : fail. */
extern int config_restore(char * ifile); /* 0 : success; 1 : file error; 2 : csum err; 3 : unknown. */
extern int config_match(char *name, char *match);
extern int config_invmatch(char *name, char *match);

/************************** util.c **************************/
enum {
	IF_NONE = 0,
	IF_UP,
	IF_DOWN
};

extern int ifconfig(char *ifname, int flags, char *addr, char *mask);
extern struct in_addr get_ipaddr(char *ifname);
extern struct in_addr get_netmask(char *ifname);
extern struct in_addr get_dst_ipaddr(char *ifname);
extern char *get_mac(char *ifname, char *eabuf);
extern void arp_mac(struct in_addr ip, char *mac, char *dev);
extern char *cat_file(char *name);
extern void echo_set(char *value, char *file);
extern int readw(char *file);
extern char readc(char *file);
extern int writew(char * file, int value);
extern long uptime(void);
extern inline int eth_up(void);
extern inline int bpa_up(void);
extern inline int ppp_up(void);
extern int eth_alive(void);
extern int bpa_alive(void);
extern int ppp_alive(void);
extern int ppp_mode(void);
extern int wds_on(void);
extern int wds_ip_conflict_flag(void);
extern char *mtu_name(void);
extern int port_reservation(char *proto, int min_port, int max_port, char *host);

extern void reserve_free_kbytes(int flag);
extern int active_ppp_link(void);
extern int active_bigpond_link(void);

/************************** resolv.c **************************/
extern unsigned int resolve_dns(char *host);

/************************** ftp.c **************************/

/* void (*dl_status) (int percent) is used to deal with the percent of downloading */
extern int ftp_transfer(char *full_url, char *ofile, void (*dl_status) (int));

/************************* ipv6.c *******************************/
extern void get_ipv6(char * inface_name, char * * ip_pointer);

/************************** detwan.c **************************/
extern int Internet_Valid(void);
extern void Internet_Detection(void);
extern char *SmartWizardDetection(void);


/************************** unicode.c **************************/
extern int iconv(char *filename);

/****************************usb.c ***************************/
extern void page_cannot_show(FILE *stream);
extern void format_capacity(char *buf, int buflen, unsigned long long megabytes);


/************************** wireless.c **************************/
extern int wl_freq_info(char *pre);
extern void wl_station_list(FILE *stream, char *mode);
extern char *wlname(char *prefix, char *item, char *buf);
extern void wds_macnode(FILE *stream, char *ath);

/************************** Smart Wizard 3.0 **************************/

enum {
	CONFIG_STARTED = 1,
	CONFIG_FINISHED
};

enum {
	SOAP_NET_PPP = 1,
	SOAP_NET_OTHER	// BPA & DHCP & StaticIP
};

struct var_entry 
{
	char 	*name;
	char 	*value;
};

struct method_struct
{
	const char *methodName;

	/* 
	  * If it is set `1`, it doesn't need to call `ParseSoapItems`, 
	  * and parsing the XML by the `methodImpl` itself.
	  */
	int needNoParse;

	void (*methodImpl)(FILE *, int, struct var_entry *);
};

struct action_struct
{
	char *name;

	struct method_struct *methods;
};



#if 0
#define SW_DEBUGP(format, args...) printf(format, ## args)
#else
#define SW_DEBUGP(format, args...)
#endif


#endif

