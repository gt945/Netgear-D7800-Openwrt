# 
# Copyright (C) 2013 Delta Networks Inc.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=ntgrddns
PKG_VERSION:=1
PKG_RELEASE:=1
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)

include $(INCLUDE_DIR)/package.mk

define Package/$(PKG_NAME)
  SECTION:=utils
  CATEGORY:=Network
  TITLE:=Tiny ddns util for Netgear Home Router
  MENU:=1
endef

define Package/$(PKG_NAME)/description
	This package contains a tiny ddns util for Netgear Home Router.
endef

define Build/Prepare
	$(CP) ./src/* $(PKG_BUILD_DIR)/
endef

define Build/Compile
endef

$(eval $(call PKG/config/CommonModule,$(PKG_NAME)))

define Package/$(PKG_NAME)/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/ntgrddns $(1)/usr/sbin/
	$(INSTALL_DIR) $(1)/$(CONFIG_DGC_DNI_CMD_DIR)
	$(INSTALL_BIN) ./files/cmd_ddns  $(1)/$(CONFIG_DGC_DNI_CMD_DIR)/
	$(INSTALL_BIN) ./files/ddns.init  $(1)/etc/init.d/ddns
endef

$(eval $(call BuildPackage,$(PKG_NAME)))
