# 
# Copyright (C) 2006 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
# $Id: Makefile,v 1.1.2.3 2007/03/11 05:08:58 agui Exp $

include $(TOPDIR)/rules.mk

PKG_NAME:=pot
PKG_RELEASE:=4

PKG_BUILD_DIR := $(BUILD_DIR)/$(PKG_NAME)

include $(INCLUDE_DIR)/package.mk

define Package/$(PKG_NAME)
  SECTION:=net
  CATEGORY:=Network
  TITLE:=POT
endef

define Build/Prepare
	$(CP) $(GIT_HOME)/pot.git/* $(PKG_BUILD_DIR)/
endef

$(eval $(call PKG/config/CommonModule,$(PKG_NAME)))

define Package/pot/install
	$(MAKE) -C $(PKG_BUILD_DIR) install INS_DIR_PRE=$(1)
	install -m0755 ./files/pot.init $(1)/etc/init.d/pot
endef

$(eval $(call BuildPackage,$(PKG_NAME)))
