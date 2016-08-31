# 
# Copyright (C) 2006 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
# $Id: Makefile,v 1.1.2.2 2007/02/06 13:52:33 anderson Exp $

include $(TOPDIR)/rules.mk

PKG_NAME:=trafficmeter
PKG_RELEASE:=1

PKG_BUILD_DIR := $(BUILD_DIR)/$(PKG_NAME)

include $(INCLUDE_DIR)/package.mk

define Package/$(PKG_NAME)
  SECTION:=utils
  CATEGORY:=Base system
  TITLE:=Update utility for trx firmware images
  MENU:=1
endef

$(eval $(call PKG/config/CommonModule,$(PKG_NAME)))

define Build/Prepare
	$(CP) ./src/* $(PKG_BUILD_DIR)/
endef

define Build/Compile
endef

define Package/$(PKG_NAME)/install
	$(INSTALL_DIR) $(1)/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/traffic_meter $(1)/sbin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/tfm_led $(1)/sbin/

	$(INSTALL_DIR) $(1)/usr/traffic_meter
	$(INSTALL_BIN) ./files/traffic_meter $(1)/usr/traffic_meter/
	$(INSTALL_BIN) ./files/traffic_statistics $(1)/usr/traffic_meter/

	$(INSTALL_DIR) $(1)/$(CONFIG_DGC_DNI_CMD_DIR)/
	$(INSTALL_BIN) ./files/cmd_traffic_meter $(1)/$(CONFIG_DGC_DNI_CMD_DIR)/

	ln -s /tmp/ppp/ppp_last_conn_time $(1)/usr/traffic_meter/last_conn_time
	ln -s /tmp/ppp/ppp_last_stop_time $(1)/usr/traffic_meter/last_stop_time
	ln -s /tmp/ppp/ppp0-status $(1)/usr/traffic_meter/network_status
endef

$(eval $(call BuildPackage,$(PKG_NAME)))
