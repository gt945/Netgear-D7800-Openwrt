# 
#  Copyright (C) 2007-2008 Delta Networks Inc.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=net-wall
PKG_RELEASE:=3
PKG_BUILD_DEPENDS:=datalib
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)

include $(INCLUDE_DIR)/package.mk

define Package/$(PKG_NAME)
  SECTION:=utils
  CATEGORY:=Network
  TITLE:=Mini Firewall for Embedded Router.
  MENU:=1
endef

define Build/Prepare
	$(CP) $(GIT_HOME)/net-wall.git/* $(PKG_BUILD_DIR)/
endef

define Build/Compile
endef

$(eval $(call PKG/config/CommonModule,$(PKG_NAME)))

define Package/$(PKG_NAME)/install
	$(MAKE) -C $(PKG_BUILD_DIR) install PREFIX=$(1)
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) ./files/firewall.sh $(1)/usr/sbin/
endef

$(eval $(call BuildPackage,$(PKG_NAME)))
