# 
# Copyright (C) 2006 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
# $Id: Makefile,v 1.1.2.3 2007/01/12 02:45:49 ronger Exp $

include $(TOPDIR)/rules.mk

PKG_NAME:=lltd
PKG_VERSION:=0.1
PKG_RELEASE:=1

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk

define Package/$(PKG_NAME)
  SECTION:=net
  CATEGORY:=Base system
  TITLE:=Link Layer Topology Discovery Daemon
  URL:=http://lltd.sourceforge.net/
  MENU:=1
endef

$(eval $(call PKG/config/CommonModule,$(PKG_NAME)))

define Build/Prepare
	$(CP) $(GIT_HOME)/lltd.git/* $(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)/
endef

define Build/Compile
endef

MAKE_PATH:=native-linux

define Package/$(PKG_NAME)/install
	install -d -m0755 $(1)/etc/init.d
	install -m0755 ./files/lltd.init $(1)/etc/init.d/lltd
	install -m0755 -d $(1)/usr/sbin
	install -m0755 $(PKG_BUILD_DIR)/$(MAKE_PATH)/lld2d $(1)/usr/sbin/
	install -m0755 -d $(1)/etc
	install -m0755 $(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)/files/lld2d.conf  $(1)/etc/
	install -m0755 ./files/large.ico  $(1)/etc/
	install -m0755 ./files/icon.ico $(1)/etc/
endef

$(eval $(call BuildPackage,$(PKG_NAME)))
