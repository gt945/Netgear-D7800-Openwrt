# 
# Copyright (C) 2007 OpenWrt.org
#

include $(TOPDIR)/rules.mk

PKG_NAME:=ppp-nas
PKG_RELEASE:=1

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)

PKG_BUILD_DEPENDS:=ipp


include $(INCLUDE_DIR)/package.mk

define Package/$(PKG_NAME)
	SECTION:=utils
	CATEGORY:=Network
	TITLE:=PPP tools for controlling Multi-PPPoE
	MENU:=1
endef

$(eval $(call PKG/config/CommonModule,$(PKG_NAME)))

define Build/Prepare
	$(CP) $(GIT_HOME)/ppp-nas.git/* $(PKG_BUILD_DIR)/
endef

define Build/Compile
	$(MAKE) -C $(PKG_BUILD_DIR) \
		$(TARGET_CONFIGURE_OPTS) \
		CROSS="$(TARGET_CROSS)" \
		LDFLAGS="-L$(STAGING_DIR)/usr/lib -L$(STAGING_DIR)/lib -lnetlink" \
		ARCH="$(ARCH)"
endef

define Package/$(PKG_NAME)/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_DIR) $(1)/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/ppp-nas $(1)/usr/sbin/
	$(INSTALL_BIN) ./files/check_route $(1)/sbin
	$(INSTALL_BIN) ./files/mulpppoe.sh $(1)/usr/sbin/
endef

$(eval $(call BuildPackage,$(PKG_NAME)))
