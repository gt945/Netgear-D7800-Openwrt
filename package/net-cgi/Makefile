# 
# Copyright (C) 2009 OpenWrt.org
#

include $(TOPDIR)/rules.mk

PKG_NAME:=net-cgi
PKG_RELEASE:=1
PKG_BUILD_DIR := $(BUILD_DIR)/$(PKG_NAME)

WEB_PATH:=www

include $(INCLUDE_DIR)/package.mk

define Package/$(PKG_NAME)
  SECTION:=utils
  CATEGORY:=Base system
  DEFAULT:=y
  TITLE:=The mini_httpd CGI interface
  MENU:=1
endef

config-$(CONFIG_net-cgi_USE_NEW_SOURCE)	+= "--use_new_source"
config-$(CONFIG_net-cgi_HAVE_DSL)	+= "--have_dsl"
config-$(CONFIG_net-cgi_HAVE_BROADBAND)	+= "--have_broadband"
config-$(CONFIG_net-cgi_HAVE_LTE)	+= "--have_lte"
config-$(CONFIG_net-cgi_HAVE_IPv6)	+= "--have_ipv6"
config-$(CONFIG_net-cgi_MULTI_OPMODE)	+= "--have_multi_opmode"
config-$(CONFIG_net-cgi_HAVE_QoS)	+= "--have_qos"
config-$(CONFIG_net-cgi_SOAP_ON)	+= "--have_soap"
config-$(CONFIG_net-cgi_HAVE_TR069)	+= "--have_tr069"
config-$(CONFIG_net-cgi_USB_STORAGE)	+= "--have_usb"
config-$(CONFIG_net-cgi_HAVE_VLAN)	+= "--have_vlan"
config-$(CONFIG_net-cgi_HAVE_VPN)	+= "--have_vpn"
config-$(CONFIG_net-cgi_CD_LESS)	+= "--have_cd_less"
config-$(CONFIG_net-cgi_HAVE_WIFI)	+= "--have_wifi"
config-$(CONFIG_net-cgi_HAVE_SECURITY)	+= "--have_security"
config-$(CONFIG_net-cgi_HAVE_ADVANCED)	+= "--have_advanced"
config-$(CONFIG_net-cgi_HAVE_WAN)	+= "--have_wan"

js=$(shell ls -m ./www/ | sed 's/\ //g')

define Build/Prepare
	$(CP) $(GIT_HOME)/net-cgi.git/* $(PKG_BUILD_DIR)/
endef

$(eval $(call PKG/config/CommonModule,$(PKG_NAME)))

define Build/Configure
	(cd $(PKG_BUILD_DIR) && \
		./configure $(config-y) \
	)
endef

define Package/$(PKG_NAME)/install
	$(MAKE) -C $(PKG_BUILD_DIR) install INS_DIR_PRE=$(1)

	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/net-cgi.init $(1)/etc/init.d/net-cgi

	$(PKG_BUILD_DIR)/files/create_soap_list.sh $(TOPDIR)/bin/support_soap_list

	# why create openvpn files in net-cgi???
	$(LN) /tmp/openvpn/windows.zip $(1)/$(WEB_PATH)/windows.zip
	$(LN) /tmp/openvpn/nonwindows.zip $(1)/$(WEB_PATH)/nonwindows.zip
	$(LN) /tmp/openvpn/smart_phone.zip $(1)/$(WEB_PATH)/smart_phone.zip
endef

$(eval $(call BuildPackage,$(PKG_NAME)))
