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
	$(INSTALL_DIR) $(1)/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/igmpproxy $(1)/sbin/
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/igmpproxy.init $(1)/etc/init.d/
	$(INSTALL_DIR) $(1)/$(CONFIG_DGC_DNI_CMD_DIR)
	$(INSTALL_BIN) ./files/cmd_igmp $(1)/$(CONFIG_DGC_DNI_CMD_DIR)
endef

$(eval $(call BuildPackage,igmpproxy))
