# 
#  Copyright (C) 2007 Delta Networks Inc.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=igmpproxy
PKG_RELEASE:=1

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)
CONFIG_DIR=${shell pwd}
include $(INCLUDE_DIR)/package.mk

define Package/igmpproxy
	SECTION:=utils
	CATEGORY:=Network
	DEPENDS:=+libpcap
	TITLE:=igmp for Embedded Router.
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
	$(CP) ./src/* $(PKG_BUILD_DIR)
endef

define Package/igmpproxy/install
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./files/igmpproxy.config $(1)/etc/config/igmpproxy
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/igmpproxy.init $(1)/etc/init.d/igmpproxy
	$(INSTALL_DIR) $(1)/etc/hotplug.d/iface
	$(INSTALL_DATA) ./files/igmpproxy.hotplug $(1)/etc/hotplug.d/iface/50-igmpproxy
	$(INSTALL_DIR) $(1)/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/igmpproxy $(1)/sbin/
	$(INSTALL_BIN) ./files/cmdigmp $(1)/sbin/
endef

$(eval $(call BuildPackage,igmpproxy))
