# 
#  Copyright (C) 2007-2008 Delta Networks Inc.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=detwan
PKG_VERSION:=1.0
PKG_RELEASE:=1
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)

include $(INCLUDE_DIR)/package.mk

define Package/$(PKG_NAME)
	SECTION:=utils
	CATEGORY:=Network
	TITLE:=Detection of Internet Connection Type
	MENU:=1
endef

define Build/Prepare
	$(CP) $(GIT_HOME)/wan-detection.git/* $(PKG_BUILD_DIR)/
endef

$(eval $(call PKG/config/CommonModule,$(PKG_NAME)))

define Package/$(PKG_NAME)/install
	$(MAKE) -C $(PKG_BUILD_DIR) install PREFIX=$(1)
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) ./files/detwan.sh $(1)/usr/sbin/
endef

$(eval $(call BuildPackage,$(PKG_NAME)))
