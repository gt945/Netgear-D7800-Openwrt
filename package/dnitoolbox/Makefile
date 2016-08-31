#
# Copyright (C) 2015 Delta Networks Inc.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=dnitoolbox
PKG_VERSION:=0.1
PKG_RELEASE:=1

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)

include $(INCLUDE_DIR)/package.mk

define Package/$(PKG_NAME)
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=a set of dni common tools
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
	cp -rf ./src/* $(PKG_BUILD_DIR)
endef

define Package/$(PKG_NAME)/install
	PREFIX=$(1) $(MAKE) -C $(PKG_BUILD_DIR) install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) ./files/fw_upg.sh $(1)/usr/sbin/
endef

$(eval $(call BuildPackage,$(PKG_NAME)))
