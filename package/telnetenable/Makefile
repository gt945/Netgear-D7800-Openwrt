# 
# Copyright (C) 2008 OpenWrt.org
#

include $(TOPDIR)/rules.mk

PKG_NAME:=telnetenable
PKG_RELEASE:=1

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)

include $(INCLUDE_DIR)/package.mk

define Package/$(PKG_NAME)
	SECTION:=utils
	CATEGORY:=Network
	TITLE:=unlocking the utelnetd.
	MENU:=1
endef

$(eval $(call PKG/config/CommonModule,$(PKG_NAME)))

define Build/Prepare
	$(CP) $(GIT_HOME)/telnetenable.git/* $(PKG_BUILD_DIR)/
endef

define Package/$(PKG_NAME)/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/telnetenable $(1)/usr/sbin/telnetenable
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/telnet.init $(1)/etc/init.d/telnet
	$(INSTALL_DIR) $(1)/usr/etc/functions
	$(INSTALL_BIN) ./files/telnetenable-control  $(1)/usr/etc/functions/telnetenable-control
endef

$(eval $(call BuildPackage,$(PKG_NAME)))
