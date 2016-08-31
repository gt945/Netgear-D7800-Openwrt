# 
#  Copyright (C) 2012 Delta Networks Inc.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=noip2
PKG_RELEASE:=1
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)

include $(INCLUDE_DIR)/package.mk

define Package/$(PKG_NAME)
	SECTION:=utils
	CATEGORY:=Network
	TITLE:=no-ip DDNS utility.
	MENU:=1
endef

define Build/Prepare
	$(CP) $(GIT_HOME)/noip2.git/* $(PKG_BUILD_DIR)/
endef

$(eval $(call PKG/config/CommonModule,$(PKG_NAME)))

define Package/$(PKG_NAME)/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/noip2 $(1)/usr/sbin/
	$(INSTALL_DIR) $(1)/$(CONFIG_DGC_DNI_CMD_DIR)
	$(INSTALL_BIN) ./files/cmd_noip_ddns $(1)/$(CONFIG_DGC_DNI_CMD_DIR)
endef

$(eval $(call BuildPackage,$(PKG_NAME)))
