#
# Copyright (C) 2008 Delta Networks Inc.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=dni-ripd
PKG_VERSION:=0.01
PKG_RELEASE:=1
PKG_BUILD_DEPENDS:=datalib
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)

include $(INCLUDE_DIR)/package.mk

define Package/$(PKG_NAME)
  SECTION:=dni
  CATEGORY:=DNI-Package
  TITLE:=ripd
  MENU:=1
endef

define Build/Prepare
	$(CP) ./src/* $(PKG_BUILD_DIR)/
endef

define Build/Compile
endef

$(eval $(call PKG/config/CommonModule,$(PKG_NAME)))

define Package/$(PKG_NAME)/install
	install -d -m0755 $(1)/usr
	install -d -m0755 $(1)/usr/sbin
	install -m0755 $(PKG_BUILD_DIR)/ripd $(1)/usr/sbin/
	install -d -m0755 $(1)/usr/etc
	install -d -m0755 $(1)/usr/etc/functions
	$(INSTALL_BIN) ./files/ripd_functions $(1)/usr/etc/functions/
endef

$(eval $(call BuildPackage,$(PKG_NAME)))
