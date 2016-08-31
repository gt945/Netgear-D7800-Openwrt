# 
#  Copyright (C) 2007-2009 Delta Networks Inc.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=acl
PKG_RELEASE:=1

PKG_BUILD_DEPENDS:=datalib
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)

include $(INCLUDE_DIR)/package.mk

define Package/$(PKG_NAME)
	SECTION:=utils
	CATEGORY:=Network
	TITLE:=Manage ACL.
	MENU:=1
endef

define Build/Prepare
	$(CP) $(GIT_HOME)/acl.git/* $(PKG_BUILD_DIR)/
endef

define Build/Compile
endef

$(eval $(call PKG/config/CommonModule,$(PKG_NAME)))

define Package/$(PKG_NAME)/install
	PREFIX=$(1) $(MAKE) -C $(PKG_BUILD_DIR) install
endef

$(eval $(call BuildPackage,$(PKG_NAME)))
