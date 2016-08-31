# 
# Copyright (C) 2008 OpenWrt.org
#

include $(TOPDIR)/rules.mk

PKG_NAME:=wlan-common
PKG_VERSION:=2.5
PKG_RELEASE:=1

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/kernel.mk

define Package/$(PKG_NAME)
  SECTION:=net
  CATEGORY:=Network
  TITLE:=DNI wlan common scripts
  MENU:=1
endef

PLATFORM_PATCH_DIR:=./patches-$(BOARD)

$(eval $(call PKG/config/CommonModule,$(PKG_NAME)))

define Build/Prepare
	$(CP) $(GIT_HOME)/wlan-common.git/* $(PKG_BUILD_DIR)/
endef

define Build/Compile
endef

define Package/$(PKG_NAME)/install
	$(INSTALL_DIR) $(1)/etc
	cp -af $(PKG_BUILD_DIR)/etc/* $(1)/etc
	if [ -f $(PKG_BUILD_DIR)/etc/ath/wifi.conf ]; then \
		sed -i 's/vht_11ng=.*/vht_11ng="on"/g' $(1)/etc/ath/wifi.conf; \
		sed -i 's/g_device=.*/g_device="wifi1"/g' $(1)/etc/ath/wifi.conf; \
		sed -i 's/a_device=.*/a_device="wifi0"/g' $(1)/etc/ath/wifi.conf; \
	fi
	$(INSTALL_DIR) $(1)/sbin
	cp -af $(PKG_BUILD_DIR)/sbin/* $(1)/sbin
	$(INSTALL_DIR) $(1)/lib/wifi/
	cp -af $(PKG_BUILD_DIR)/lib/wifi/* $(1)/lib/wifi
	install -d -m0755 $(1)/etc/config
endef

$(eval $(call BuildPackage,$(PKG_NAME)))
