#
#	Copyright (C) 2007-2008 Delta Networks Inc.
#

include $(TOPRULE)
include $(NETCGI_CONF)

FILES = main.o httpd.o lang.o apply.o asp.o auth.o action.o print.o
FILES += upgrade.o util.o detwan.o ftp.o resolv.o unicode.o
FILES += wireless.o
FILES += basic_home_asp.o menu_asp.o adv_index_asp.o
ifeq ($(SOAP_ON), 1)
FILES += sw_soap.o sw_devconfig.o sw_devinfo.o sw_wanip.o \
	sw_wanethlink.o sw_lanconfig.o sw_wlanconfig.o \
	sw_parentalctl.o sw_auth.o\
	sw_time.o sw_agent.o sw_base64.o sw_wepkey.o
ifeq ($(HAVE_WIRELESS_AN), 1)
	FILES += sw_wlanconfig_an.o
endif
ifeq ($(HNAP_ON), 1)
FILES += hnap_agent.o hnap_general.o hnap_router.o hnap_soap.o hnap_wireless.o
endif
ifeq ($(HAVE_ACCESS_CONTROL), 1)
	FILES += sw_devconfig_access.o
endif
endif
FILES += hijack_action.o hijack_apply.o hijack_asp.o
FILES += pagetag_asp.o forwarding_apply.o triggering_apply.o block_service_apply.o
FILES += internet_setup_apply.o wlan_apply.o wan_setup_apply.o block_service_asp.o
FILES += home_apply.o wps_apply.o wladv_apply.o forwarding_asp.o triggering_asp.o
FILES += lan_apply.o top_apply.o upnp_apply.o hidden_page_apply.o hidden_page_asp.o
FILES += wlan_asp.o home_asp.o internet_setup_asp.o cfg_asp.o lan_asp.o
FILES += detfirmware.o schedule_apply.o email_apply.o dns_asp.o dns_apply.o
FILES += logs_apply.o logs_asp.o remote_apply.o attached_devices_asp.o passwd_apply.o
FILES += static_route_apply.o static_route_asp.o upnp_asp.o wireless_repeating_asp.o
FILES += wladv_asp.o wps_asp.o top_asp.o upgrade_asp.o lang_upgrade.o email_asp.o ssid_passph_to_sec.o
FILES += dni_system.o
FILES += rae_apply.o rae_asp.o
FILES += vpn_apply.o vpn_asp.o
FILES += nc_config.o
FILES += wless_schedule_apply.o wless_schedule_asp.o wless_schedule_action.o
FILES += led_apply.o
FILES += bridge_mode_apply.o 
FILES += fb_wifi_apply.o fbwifi_asp.o

CFLAGS += -DREADYCLOUD=$(READYCLOUD)
CFLAGS += -DGENIECLOUD=$(GENIECLOUD)
CFLAGS += -DAP_MODE_DETECTION=$(AP_MODE_DETECTION)
CFLAGS += -DGUEST_MANAGE=$(GUEST_MANAGE)
CFLAGS += -DDSL_WIZARD=$(DSL_WIZARD)
CFLAGS += -DAPP_SYSTEM=$(APP_SYSTEM)
CFLAGS += -DHAVE_DEBUG=$(HAVE_DEBUG)
CFLAGS += -DSOAP_ON=$(SOAP_ON)

ifeq ($(SINGLE_FIRMWARE), 0)
CFLAGS += -DSINGLE_FIRMWARE=0
else
CFLAGS += -DSINGLE_FIRMWARE=1
endif

ifeq ($(PPPOA_INTRANET), 1)
CFLAGS += -DPPPOA_INTRANET
endif
ifeq ($(HAVE_PRIORITY_ZONE), 1)
FILES += priority_zone_apply.o priority_zone_asp.o
CFLAGS += -DHAVE_PRIORITY_ZONE
endif
ifeq ($(USE_EXTERNAL_DETWAN), 1)
CFLAGS += -DUSE_EXTERNAL_DETWAN
CFLAGS += -DDETWAN_PATH=$(DETWAN_PATH)
endif
ifeq ($(HAVE_TRAFFIC_METER), 1)
FILES += traffic_apply.o traffic_asp.o
CFLAGS += -DHAVE_TRAFFIC_METER
endif
ifeq ($(HAVE_IPv6), 1)
FILES += ipv6.o ipv6_apply.o ipv6_asp.o
CFLAGS += -DHAVE_IPv6
endif
ifeq ($(HAVE_MAP_T), 1)
CFLAGS += -DHAVE_MAP_T=$(HAVE_MAP_T)
endif

ifeq ($(HAVE_QOS), 1)
FILES += qos_apply.o qos_asp.o
CFLAGS += -DHAVE_QOS
ifeq ($(QOS_TRUSTED_IP), 1)
CFLAGS += -DQOS_TRUSTED_IP
endif
endif
ifeq ($(HAVE_ADVANCED_QOS), 1)
FILES += qos_apply.o qos_asp.o
CFLAGS += -DHAVE_ADVANCED_QOS
endif


ifeq ($(HDD_MULTI_USER), 1)
CFLAGS += -DHDD_MULTI_USER
FILES += hdd_action.o hdd_apply.o hdd_asp.o
endif

ifeq ($(CD_LESS_DOWNLOAD), 1)
CFLAGS += -DCD_LESS_DOWNLOAD
FILES += hdd_apply.o hdd_asp.o
endif

READY_SHARE_SUPPORTED_LEVEL:=0
ifeq ($(HAVE_USB_STORAGE), 1)
FILES += usb.o usbdisk.o usb_apply.o usb_asp.o
CFLAGS += -DHAVE_USB_STORAGE
CFLAGS += -D_FILE_OFFSET_BITS=64
READY_SHARE_SUPPORTED_LEVEL:=$(shell expr $(READY_SHARE_SUPPORTED_LEVEL) + 1)
ifeq ($(GREEN_DOWNLOAD), 1)
FILES += green_apply.o green_asp.o green_upgrade.o
CFLAGS += -DGREEN_DOWNLOAD
endif
endif
ifeq ($(READYSHARE_PRINT), 1)
CFLAGS += -DREADYSHARE_PRINT
READY_SHARE_SUPPORTED_LEVEL:=$(shell expr $(READY_SHARE_SUPPORTED_LEVEL) + 4)
endif
ifeq ($(HAVE_VAULT), 1)
CFLAGS += -DHAVE_VAULT
READY_SHARE_SUPPORTED_LEVEL:=$(shell expr $(READY_SHARE_SUPPORTED_LEVEL) + 8)
endif
ifeq ($(READYCLOUD), 1)
READY_SHARE_SUPPORTED_LEVEL:=$(shell expr $(READY_SHARE_SUPPORTED_LEVEL) + 16)
endif
CFLAGS += -DREADY_SHARE_SUPPORTED_LEVEL=$(READY_SHARE_SUPPORTED_LEVEL)

ifeq ($(HAVE_L2TP), 1)
CFLAGS += -DHAVE_L2TP
endif
ifeq ($(HAVE_BIGPOND), 1)
CFLAGS += -DHAVE_BIGPOND
endif
ifeq ($(HAVE_WIRELESS_AN), 1)
CFLAGS += -DHAVE_WIRELESS_AN
endif
ifeq ($(HAVE_GUEST_NETWORK), 1)
FILES += guest_apply.o
CFLAGS += -DHAVE_GUEST_NETWORK
endif
ifeq ($(HAVE_WDS), 1)
FILES += wireless_repeating_apply.o
CFLAGS += -DHAVE_WDS
endif
ifeq ($(HAVE_BLOCK_SITES), 1)
FILES += block_sites_apply.o
CFLAGS += -DHAVE_BLOCK_SITES
endif
ifeq ($(HAVE_TR069), 1)
FILES += tr069_apply.o
CFLAGS += -DHAVE_TR069
endif
ifeq ($(HAVE_PLC), 1)
FILES += plc_devs.o plc_devs_action.o plc_devs_apply.o plc_devs_asp.o
CFLAGS += -DHAVE_PLC
endif
ifeq ($(HAVE_ACCESS_CONTROL), 1)
FILES += access_control_apply.o access_control_devices_asp.o
CFLAGS += -DHAVE_ACCESS_CONTROL
endif
CFLAGS += -DSHOW_ACCESS_CONTROL_EDIT
ifeq ($(HAVE_TIVO), 1)
CFLAGS += -DHAVE_TIVO
endif

ifeq ($(HAVE_JP), 1)
CFLAGS += -DHAVE_JP
FILES += multipppoe_apply.o multipppoe_asp.o
endif

ifeq ($(MODE_IS_300_OR_150), 1)
CFLAGS += -DMODE_IS_300_OR_150
endif
ifeq ($(TXCTL_63_33), 1)
CFLAGS += -DTXCTL_63_33
endif
ifeq ($(PPPOA_INTRANET), 1)
CFLAGS += -DPPPOA_INTRANET
endif
ifeq ($(HNAP_ON), 1)
CFLAGS += -DHNAP_ON
endif
ifeq ($(HAVE_AP_MODE), 1)
FILES += apmode_apply.o
CFLAGS += -DHAVE_AP_MODE
endif
ifneq ($(ROUTER_AP_EXTENDER), 0)
FILES += apmode_apply.o
CFLAGS += -DROUTER_AP_EXTENDER=$(ROUTER_AP_EXTENDER)
endif
ifeq ($(HAVE_BROADBAND), 1)
CFLAGS += -DHAVE_BROADBAND
FILES += broadband_apply.o
FILES += 3g_apply.o 3g_asp.o sw_wan3g.o
endif
ifeq ($(HAVE_LTE),1)
CFLAGS += -DHAVE_LTE
FILES += lte_broadband_apply.o lte_apply.o lte_asp.o
endif
ifeq ($(HAVE_FAST_LANE), 1)
CFLAGS += -DHAVE_FAST_LANE
FILES += fastlane_apply.o
endif
ifeq ($(IP_MAC), 1)
CFLAGS += -DIP_MAC
endif
ifeq ($(WDS_SUPPORT_WPA), 1)
CFLAGS += -DWDS_SUPPORT_WPA
endif
ifeq ($(FORWARD_RANGE),1)
CFLAGS += -DFORWARD_RANGE
endif
ifeq ($(FAN_PROBE_SET),1)
CFLAGS += -DFAN_PROBE_SET
endif
ifeq ($(READYSHARE_MOBILE),1)
CFLAGS += -DREADYSHARE_MOBILE
FILES += readyshare_mobile_apply.o readyshare_mobile_asp.o
endif
ifeq ($(HAVE_VPN),1)
CFLAGS += -DHAVE_VPN
endif
CFLAGS += -DHAVE_PPTP_VPN=$(HAVE_PPTP_VPN)

ifeq ($(HAVE_VLAN),1)
CFLAGS += -DHAVE_VLAN  
FILES += vlan_apply.o vlan_asp.o
endif

ifeq ($(HAVE_DEVICE_NAME), 1)
CFLAGS += -DHAVE_DEVICE_NAME
endif

ifdef WLAN_BOOTTIME 
CFLAGS += -DWLAN_BOOTTIME=$(WLAN_BOOTTIME)
endif

ifeq ($(HAVE_DYNA_QOS), 1)
FILES += streamboost_apply.o streamboost_asp.o sw_advancedQoS.o
CFLAGS += -DHAVE_DYNA_QOS
endif

ifeq ($(QTN_API_STATISTICS), 1)
CFLAGS += -DQTN_API_STATISTICS
endif

ifeq ($(APP_SYSTEM), 1)
FILES += sw_app.o
endif

CFLAGS += -DUSE_MTD_UTIL=$(USE_MTD_UTIL)

CFLAGS += -I$(STAGING_DIR)/usr/lib/libiconv/include
CFLAGS += -Wall -Wunused -g -O2

LDFLAGS += -L$(STAGING_DIR)/usr/lib/libiconv/lib

.PHONY: all install clean
all : net-cgi usb_cfg inetd detplc remote_smb_conf remote_user_conf remote_share_conf readycloud_unregister

net-cgi : $(FILES)
	$(CC) $(CFLAGS) $^ -o $@ $(EXTRA_LDFLAGS) $(LDFLAGS) -lconfig -lpthread -liconv
	@echo "make $@ finished on `date`"

usb_cfg : usbdisk.o usb_cfg.o print.o nc_config.o
	$(CC) $(CFLAGS) $^ -o $@ $(EXTRA_LDFLAGS) $(LDFLAGS) -lconfig -liconv	

inetd : http_scan.o
	$(CC) $(CFLAGS) $^ -o $@ $(EXTRA_LDFLAGS) $(LDFLAGS)

remote_smb_conf remote_user_conf remote_share_conf readycloud_unregister: usbdisk.o remote_smb_conf.o print.o nc_config.o
	$(CC) $(CFLAGS) $^ -o $@ $(EXTRA_LDFLAGS) $(LDFLAGS) -lconfig -liconv

detplc: plc_devs_detect.o
	$(CC) $(CFLAGS) $^ -o $@ $(EXTRA_LDFLAGS) $(LDFLAGS) -lconfig

%.o : %.c
	$(CC) $(CFLAGS) -c $<

install:
	$(INSTALL_BIN)	net-cgi		$(INS_BIN_DIR)
	$(INSTALL_BIN)	inetd		$(INS_BIN_DIR)
ifeq ($(HAVE_USB_STORAGE),1)
	$(INSTALL_BIN)	usb_cfg		$(INS_BIN_DIR)
endif
ifeq ($(HAVE_PLC),1)
	$(INSTALL_BIN)	detplc		$(INS_BIN_DIR)
endif
ifeq ($(GENIECLOUD),1)
	$(INSTALL_BIN)	remote_smb_conf		$(INS_BIN_DIR)
	$(INSTALL_BIN)	remote_user_conf	$(INS_BIN_DIR)
	$(INSTALL_BIN)	remote_share_conf	$(INS_BIN_DIR)
	$(INSTALL_BIN)	readycloud_unregister	$(INS_BIN_DIR)
endif

clean:
	rm -f *.o 
	rm -f net-cgi usb_cfg inetd detplc remote_smb_conf remote_user_conf remote_share_conf readycloud_unregister
