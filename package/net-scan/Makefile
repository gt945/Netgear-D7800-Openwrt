# 
#  Copyright (C) 2007-2009 Delta Networks Inc.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=net-scan
PKG_RELEASE:=1

config-$(CONFIG_net-scan_SUPPORT_STREAMBOOST)	+= --support_streamboost

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)

include $(INCLUDE_DIR)/package.mk

define Package/$(PKG_NAME)
	SECTION:=utils
	CATEGORY:=Network
	TITLE:=Scanning the attached devices according to NETGEAR's spec.
	MENU:=1
endef

define Build/Prepare
	$(CP) $(GIT_HOME)/net-scan.git/* $(PKG_BUILD_DIR)/
endef

define Build/Configure
	(cd $(PKG_BUILD_DIR); \
		./configure $(config-y) \
	)
endef

$(eval $(call PKG/config/CommonModule,$(PKG_NAME)))

define Package/$(PKG_NAME)/install
	PREFIX=$(1) $(MAKE) -C $(PKG_BUILD_DIR) install
	install -d -m0755 $(1)/etc/init.d
	install -m0755 ./files/net-scan.init $(1)/etc/init.d/net-scan
endef

$(eval $(call BuildPackage,$(PKG_NAME)))
