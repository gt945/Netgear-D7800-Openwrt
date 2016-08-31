#
# Copyright (C) 2007-2008 Delta Networks Inc.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=datalib
PKG_VERSION:=1.0
PKG_RELEASE:=1

config-$(CONFIG_datalib_WITH_nvram)		+= --with_nvram
config-$(CONFIG_datalib_WITH_readycloud_nvram)	+= --with_readycloud_nvram
ifneq ($(CONFIG_datalib_SPACE_SIZE),)
config-y					+= --config_space $(CONFIG_datalib_SPACE_SIZE)
endif

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)

include $(INCLUDE_DIR)/package.mk

define Package/$(PKG_NAME)
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=Small application for saving data on embedded system
  MENU:=1
endef

define Build/Prepare
	$(CP) ./datalib_src/* $(PKG_BUILD_DIR)/
endef

define Build/Compile
endef

$(eval $(call PKG/config/CommonModule,$(PKG_NAME)))

define Build/Configure
endef

define Build/InstallDev
	mkdir -p $(STAGING_DIR)/usr/lib
	$(CP) $(PKG_BUILD_DIR)/src/libconfig.so $(STAGING_DIR)/usr/lib/
endef

define Build/UninstallDev
	rm -f $(STAGING_DIR)/usr/lib/libconfig.so
endef

define Package/$(PKG_NAME)/install
	PREFIX=$(1) $(MAKE) -C $(PKG_BUILD_DIR) install
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/datalib.init $(1)/etc/init.d/datalib
endef

$(eval $(call BuildPackage,$(PKG_NAME)))
