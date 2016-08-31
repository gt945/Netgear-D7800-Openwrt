# 
# Copyright (C) 2006 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
# $Id: Makefile,v 1.1.2.2 2006/12/06 00:48:30 ronger Exp $

include $(TOPDIR)/rules.mk

PKG_NAME:=ez-ipupdate
PKG_VERSION:=3.0.10
PKG_RELEASE:=1

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)

include $(INCLUDE_DIR)/package.mk

MAKE_FLAGS += CFLAGS="$(TARGET_CFLAGS) $(EXTRA_CFLAGS) \
			  -DNETGEAR_PROJECT -DEXPERIMENTAL"

define Package/$(PKG_NAME)
  SECTION:=net
  CATEGORY:=Base system
  TITLE:=Dynamic DNS application
  URL:=http://ez-ipupdate.com/
  MENU:=1
endef

define Build/Prepare
	$(CP) $(GIT_HOME)/ez-ipupdate.git/* $(PKG_BUILD_DIR)/
endef

$(eval $(call PKG/config/CommonModule,$(PKG_NAME)))

define Package/$(PKG_NAME)/install
	install -m0755 -d $(1)/usr/sbin
	install -m0755 $(PKG_BUILD_DIR)/ez-ipupdate $(1)/usr/sbin/
	install -m0755 -d $(1)/$(CONFIG_DGC_DNI_CMD_DIR)
	install -m0755 ./files/cmd_ez_ipddns $(1)/$(CONFIG_DGC_DNI_CMD_DIR)
	install -m0755 -d $(1)/etc
	install -m0755 ./files/ez-ipupdate.script $(1)/etc/ez-ipupdate.script
endef

$(eval $(call BuildPackage,$(PKG_NAME)))
