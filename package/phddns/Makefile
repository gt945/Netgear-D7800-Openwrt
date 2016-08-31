# 
#  Copyright (C) 2011 Delta Networks Inc.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=phddns
PKG_RELEASE:=1
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)

include $(INCLUDE_DIR)/package.mk

define Package/phddns
	SECTION:=utils
	CATEGORY:=Network
	TITLE:=Oray DDNS utility.
	MENU:=1
endef

define Build/Prepare
	$(CP) $(GIT_HOME)/phddns.git/* $(PKG_BUILD_DIR)/
endef

$(eval $(call PKG/config/CommonModule,$(PKG_NAME)))

define Package/phddns/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/phddns $(1)/usr/sbin/
	$(INSTALL_DIR) $(1)/$(CONFIG_DGC_DNI_CMD_DIR)
	$(INSTALL_BIN) ./files/cmd_oray_ddns $(1)/$(CONFIG_DGC_DNI_CMD_DIR)
endef

$(eval $(call BuildPackage,phddns))
