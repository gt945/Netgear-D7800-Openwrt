
include $(TOPRULE)
include $(NETCGI_CONF)

# opt_folders is a string list of all selected folders' name in www
opt_folders:=

ifeq ($(CD_LESS),1)
  opt_folders+=browser_hijack
  ifeq ($(CD_LESS_DOWNLOAD),1)
    opt_folders+=cd_less_download
  endif
endif
ifeq ($(HAVE_USB_STORAGE),1)
  opt_folders+=usb_storage
  ifeq ($(GREEN_DOWNLOAD),1)
    opt_folders+=green_download
  endif
  ifeq ($(HDD_MULTI_USER),1)
    opt_folders+=user_hdd_storage
  endif
endif
ifeq ($(GENIECLOUD),1)
  opt_folders+=readyshare_remote
endif
ifeq ($(READYSHARE_PRINT),1)
  opt_folders+=readyshare_print
endif
ifeq ($(HAVE_VAULT),1)
  opt_folders+=readyshare_vault
endif
ifeq ($(HAVE_L2TP),1)
  opt_folders+=l2tp
endif
ifeq ($(HAVE_BIGPOND),1)
  opt_folders+=bigpond
endif
ifeq ($(HAVE_GUEST_NETWORK),1)
  opt_folders+=guest
endif
ifeq ($(HAVE_QOS),1)
  opt_folders+=qos
endif
ifeq ($(HAVE_DYNA_QOS),1)
  opt_folders+=dynamic_qos
  ifeq ($(HAVE_ADVANCED_QOS),1)
    opt_folders+=advanced_qos
  endif
endif
ifeq ($(HAVE_WDS),1)
  opt_folders+=wds
endif
ifeq ($(HAVE_IPv6),1)
  opt_folders+=ipv6
endif
ifeq ($(HAVE_VPN),1)
  opt_folders+=vpn
endif
ifeq ($(HAVE_PPTP_VPN),1)
  opt_folders+=vpn_pptp
endif
ifeq ($(HAVE_TRAFFIC_METER),1)
  opt_folders+=traffic
endif
ifeq ($(HAVE_BLOCK_SITES),1)
  opt_folders+=block_sites
endif
ifeq ($(HAVE_ACCESS_CONTROL),1)
  opt_folders+=access_control
endif
ifeq ($(HAVE_DEVICE_NAME),1)
  opt_folders+=device_name
endif
ifeq ($(HAVE_TR069),1)
  opt_folders+=tr069
endif
ifeq ($(HAVE_PLC),1)
  opt_folders+=plc
endif
ifeq ($(HAVE_AP_MODE),1)
  opt_folders+=apmode
endif
ifeq ($(HAVE_JP),1)
  opt_folders+=multipppoe
endif
ifeq ($(NETGEAR_DDNS),1)
  opt_folders+=netgear_ddns
endif
ifeq ($(HAVE_VLAN),1)
  opt_folders+=vlan
endif
ifneq ($(ROUTER_AP_EXTENDER),0)
  opt_folders+=rae
endif
ifeq ($(HAVE_FAST_LANE),1)
  opt_folders+=fastlane
endif
ifneq ($(HAVE_WIRELESS_AN),1)
  opt_folders+=bgn_wireless
endif
ifeq ($(FORWARD_RANGE),1)
  opt_folders+=forwarding_range
endif
ifeq ($(READYSHARE_MOBILE),1)
  opt_folders+=readyshare_mobile
endif
ifeq ($(HAVE_BROADBAND),1)
  opt_folders+=3g
  opt_folders+=browser_hijack_3g
endif
ifeq ($(HAVE_LTE),1)
  opt_folders+=lte
  opt_folders+=browser_hijack_lte
endif
ifeq ($(GREEN_DOWNLOAD),1)
  opt_folders+=green_download
endif
ifeq ($(AP_MODE_DETECTION),1)
  opt_folders+=browser_hijack_ap
endif
ifeq ($(DSL_WIZARD),1)
  opt_folders+=dsl_wiard
endif
ifeq ($(GUEST_MANAGE),1)
  opt_folders+=guest_manage
endif
ifeq ($(HAVE_DEBUG),1)
  opt_folders+=debug
endif

define copy_folder
	$(CP) $(1)/* $(WWW_OUT_DIR);
endef

.PHONY: all install clean
all:
	echo $(opt_folders)
	$(INSTALL_DIR)		$(WWW_OUT_DIR)
	$(CP) *.*		$(WWW_OUT_DIR)
	$(CP) image/		$(WWW_OUT_DIR)
	$(CP) style/		$(WWW_OUT_DIR)
	$(CP) help/		$(WWW_OUT_DIR)
	$(CP) cgi-bin/		$(WWW_OUT_DIR)
	$(CP) language/		$(WWW_OUT_DIR)
#	$(CP) script/		$(WWW_OUT_DIR)
	$(foreach n,$(strip $(opt_folders)),$(call copy_folder,$(n)))

install:
	$(CP) $(WWW_OUT_DIR)/* $(INS_WWW_DIR)

clean:
	rm -rf $(WWW_OUT_DIR)
