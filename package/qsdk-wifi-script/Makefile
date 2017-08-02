include $(TOPDIR)/rules.mk

PKG_NAME=qsdk-wifi-script
PKG_VERSION=1
PKG_RELEASE=1

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)

include $(INCLUDE_DIR)/package.mk

define Package/$(PKG_NAME)
  SECTION:=net
  CATEGORY:=Network
  TITLE:=qca-wifi scripts
  MAINTAINER:=Matthew McClintock <mmcclint@qca.qualcomm.com>
  MENU:=1
endef

$(eval $(call PKG/config/CommonModule,$(PKG_NAME)))

define Build/Prepare
	$(CP) ./src/* $(PKG_BUILD_DIR)/
endef

define Build/Compile
endef

define Package/$(PKG_NAME)/install
	$(INSTALL_DIR) $(1)/lib/wifi/
	$(INSTALL_DIR) $(1)/usr/lib/
	cp -af $(PKG_BUILD_DIR)/lib/wifi/* $(1)/lib/wifi
	cp -af $(PKG_BUILD_DIR)/usr/lib/* $(1)/usr/lib
endef

$(eval $(call BuildPackage,$(PKG_NAME)))
