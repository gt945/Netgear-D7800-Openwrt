# 
# Copyright (C) 2006 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
# $Id: Makefile,v 1.1.2.2 2007/01/31 06:23:51 ronger Exp $

include $(TOPDIR)/rules.mk

PKG_NAME:=miniupnpd
PKG_VERSION:=20070127
PKG_RELEASE:=3

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)

include $(INCLUDE_DIR)/package.mk

config-y					= --with-friendly_name=$(CONFIG_MINIUPNPD_FRIENDLYNAME)
config-y					+= --with-model_name=$(CONFIG_MINIUPNPD_MODELNAME)
config-y					+= --with-model_number=$(CONFIG_MINIUPNPD_MODELNUMBER)
config-y					+= --with-universal_product_code=$(CONFIG_MINIUPNPD_DEVUPC)
config-y					+= --with-model_url=$(CONFIG_MINIUPNPD_MODELURL)
config-y					+= --with-wan_ifname=$(CONFIG_WAN_IFNAME)
config-$(CONFIG_MINIUPNPD_SUPPORT_PNPX)		+= --enable-support_pnpx
config-$(CONFIG_MINIUPNPD_SUPPORT_PNPX)		+= --with-pnpx_hwid=$(CONFIG_MINIUPNPD_PNPX_HWID)

define Package/$(PKG_NAME)
  SECTION:=net
  CATEGORY:=Network
  TITLE:=Miniupnpd Daemon
  URL:=http://pptpclient.sourceforge.net/
  MENU:=1
endef

define Build/Prepare
	$(CP) ./src/* $(PKG_BUILD_DIR)/
endef

$(eval $(call PKG/config/CommonModule,$(PKG_NAME)))

define Build/Configure
endef

define Build/Compile
endef

define Package/$(PKG_NAME)/install
	install -d -m0755 $(1)/usr/sbin
	install -m0755 $(PKG_BUILD_DIR)/miniupnpd $(1)/usr/sbin/
	install -d -m0755 $(1)/sbin
	install -m0755 $(PKG_BUILD_DIR)/cmdupnp $(1)/sbin/
	install -d -m0755 $(1)/etc/init.d
	install -m0755 ./files/upnp.init $(1)/etc/init.d/upnp

endef

$(eval $(call BuildPackage,$(PKG_NAME)))
