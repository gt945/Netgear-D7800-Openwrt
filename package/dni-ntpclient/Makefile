# 
# Copyright (C) 2006 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
# $Id: Makefile,v 1.1.4.3 2007/02/27 03:06:36 ronger Exp $

include $(TOPDIR)/rules.mk

PKG_NAME:=ntpclient
PKG_RELEASE:=4
PKG_BUILD_DIR := $(BUILD_DIR)/$(PKG_NAME)

include $(INCLUDE_DIR)/package.mk

define Package/$(PKG_NAME)
  SECTION:=utils
  CATEGORY:=Base system
  TITLE:=The CGI interface
  MENU:=1
endef

define Package/$(PKG_NAME)/description
	The CGI interface
endef

define Build/Prepare
	$(CP) $(GIT_HOME)/ntpclient.git/* $(PKG_BUILD_DIR)/
endef

$(eval $(call PKG/config/CommonModule,$(PKG_NAME)))

define Package/$(PKG_NAME)/install
	PREFIX=$(1) $(MAKE) -C $(PKG_BUILD_DIR) install
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) ./files/ntpclient.init $(1)/etc/init.d/ntpclient
	$(INSTALL_BIN) ./files/ntp_updated.sh $(1)/usr/sbin/ntp_updated
endef

$(eval $(call BuildPackage,$(PKG_NAME)))
