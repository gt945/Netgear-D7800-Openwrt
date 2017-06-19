# 
#  Copyright (C) 2007 Delta Networks Inc.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=greendownload
PKG_RELEASE:=1
PKG_VERSION:=V1.0.0

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)


include $(INCLUDE_DIR)/package.mk

define Package/$(PKG_NAME)
	SECTION:=utils
	CATEGORY:=Network
	DEPENDS:= amule +wget +transmission
	TITLE:=Green Download core manager
	MENU:=1
endef


define Build/Prepare
	$(CP) ./src/* $(PKG_BUILD_DIR)
	$(CP) ./files/* $(PKG_BUILD_DIR)
endef

$(eval $(call PKG/config/CommonModule,$(PKG_NAME)))

define Build/Compile
endef

define Package/$(PKG_NAME)/install
	install -d -m0755 $(1)/usr/sbin
	install -m0755 $(PKG_BUILD_DIR)/dlclient $(1)/usr/sbin/
	install -m0755 $(PKG_BUILD_DIR)/remote_fsize $(1)/usr/sbin/
	install -m0755 $(PKG_BUILD_DIR)/greendownload $(1)/usr/sbin/
	install -m0755 $(PKG_BUILD_DIR)/green_download.sh $(1)/usr/sbin/
	install -m0755 $(PKG_BUILD_DIR)/green_download_upgrade.sh $(1)/usr/sbin/
	install -m0755 $(PKG_BUILD_DIR)/emule_firewall $(1)/usr/sbin/
	install -d -m0755 $(1)/etc/init.d
#	install -m0755 $(PKG_BUILD_DIR)/green_download_init $(1)/etc/init.d/
	install -m0755 $(PKG_BUILD_DIR)/glboot $(1)/etc/init.d/
	
endef

$(eval $(call BuildPackage,$(PKG_NAME)))
