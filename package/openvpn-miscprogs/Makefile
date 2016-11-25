#
# Copyright (C) 2007-2012 OpenWrt.org
# Copyright (C) 2010 Vertical Communications
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=openvpn-miscprogs
PKG_RELEASE:=1.0


include $(INCLUDE_DIR)/package.mk


define Package/openvpn-miscprogs
  SECTION:=net
  CATEGORY:=Network
  DEPENDS:=+libc
  TITLE:=openvpn-miscprogs
  URL:=http://openwrt.org/
  VERSION:=$(PKG_RELEASE)
endef

define Package/openvpn-miscprogs/description
 misc programs for openvpn
endef


define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
endef

define Build/Compile/Default

endef

define Package/openvpn-miscprogs/install
	$(CP) -r ./files/* $(1)
endef


$(eval $(call BuildPackage,openvpn-miscprogs))
