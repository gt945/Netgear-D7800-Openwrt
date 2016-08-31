#
# Openwrt Makefile for ltq-oam
#

#### Includes ###################################
include $(TOPDIR)/rules.mk

#### Package Info ###############################
PKG_NAME:=ltq-oam
PKG_VERSION:=2.4.0.7
PKG_RELEASE:=1
PKG_DEFAULT_CUSTOM_SOURCE_DIR:=$(shell pwd)/src

PKG_CONFIG_DEPENDS:=\
	$(foreach _mr,$(shell grep -w config config/Config.in|awk '{ print $$2 }'),CONFIG_$(_mr))

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/package-version-override.mk
ifeq ($(CONFIG_FEATURE_HOST_ENVIR),y)
  include $(INCLUDE_DIR)/host-build.mk
endif

define Package/$(PKG_NAME)
	SECTION:=utils
	CATEGORY:=Lantiq
	TITLE:=Lantiq ATM OAM Module and Daemon
	URL:=http://www.lantiq.com
	MAINTAINER:=Lantiq Technologies AG
	DEPENDS:=+libpthread +librt
	MENU:=1
endef

define Package/$(PKG_NAME)/description
	This package contains Operations Administration & Maintenance module for router 4.x
endef

### Menuconfig ##################################
define Package/$(PKG_NAME)/config
$(call Package/$(PKG_NAME)/override_version)
$(call Package/$(PKG_NAME)/override_source_path)
	menu "$(PKG_NAME) features"
	depends on PACKAGE_$(PKG_NAME)
	source "$(SOURCE)/config/Config.in"
	endmenu
endef

### Configurations depends on Menuconfig ########
IFX_CFLAGS_y:=
IFX_LDFLAGS_y:=

ifeq ($(CONFIG_FEATURE_OAM_FULL),y)
	IFX_CFLAGS_y +=
else
	IFX_CFLAGS_y +=IFX_2MB_OAM_PKG=1
endif

ifeq ($(CONFIG_FEATURE_OAM_F5_LOOPBACK),y)
	IFX_CFLAGS_y +=IFX_OAM_F5_LOOPBACK=1
endif

ifeq ($(CONFIG_FEATURE_OAM_F4_LOOPBACK),y)
	IFX_CFLAGS_y +=IFX_OAM_F4_LOOPBACK=1
endif

ifeq ($(CONFIG_FEATURE_OAM_F5_LOOPBACK_PING),y)
	IFX_CFLAGS_y +=IFX_OAM_F5_LOOPBACK_PING=1
endif

ifeq ($(CONFIG_FEATURE_OAM_F4_LOOPBACK_PING),y)
	IFX_CFLAGS_y +=IFX_OAM_F4_LOOPBACK_PING=1
endif

ifeq ($(CONFIG_FEATURE_OAM_AIS),y)
	IFX_CFLAGS_y +=IFX_OAM_AIS=1
endif

ifeq ($(CONFIG_FEATURE_OAM_RDI),y)
	IFX_CFLAGS_y +=IFX_OAM_RDI=1
endif

ifeq ($(CONFIG_FEATURE_OAM_CC),y)
	IFX_CFLAGS_y +=IFX_OAM_CC=1
endif

ifeq ($(CONFIG_FEATURE_OAM_EVENT_SCRIPT),y)
	IFX_CFLAGS_y +=IFX_OAM_EVENT_SCRIPT=1
endif

ifeq ($(CONFIG_FEATURE_OAM_SIMULATOR),y)
	IFX_CFLAGS_y +=IFX_OAM_SIMULATOR=1
endif

IFX_CFLAGS:=$(IFX_CFLAGS_y)
IFX_LDFLAGS:=$(IFX_LDFLAGS_y)

#### Export Section for Features & Others #######
ifeq ($(CONFIG_FEATURE_HOST_ENVIR),y)
  export CONFIG_FEATURE_HOST_ENVIR
endif

ifeq ($(CONFIG_FEATURE_HOST_ENVIR),y)
CONFIG_OPTS=$(HOST_CONFIGURE_VARS)
CFLAGS="-g -Wall -fno-stack-protector "
else
CONFIG_OPTS=$(TARGET_CONFIGURE_OPTS)
CFLAGS="$(TARGET_CFLAGS) -Wall "
endif

#### Target Rules ###############################
define Build/Prepare
	$(call Build/Prepare/Default)
	$(if $(CONFIG_$(PKG_NAME)_USE_CUSTOM_SOURCE_DIR),,$(CP) -L ./src/* $(PKG_BUILD_DIR)/)
endef

define Build/Compile
	$(MAKE) -C $(PKG_BUILD_DIR) \
	$(CONFIG_OPTS) \
	$(IFX_CFLAGS) $(IFX_LDFLAGS) \
	CFLAGS=$(CFLAGS)
endef

define Package/$(PKG_NAME)/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_DIR) $(1)/usr/lib
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/oamd $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/oamctl $(1)/usr/bin/
ifeq ($(CONFIG_FEATURE_OAM_SIMULATOR),y)
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/oamsim $(1)/usr/bin/
endif
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/liboamapi.so $(1)/usr/lib/
	$(INSTALL_DIR) $(STAGING_DIR)/usr/lib/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/liboamapi.so $(STAGING_DIR)/usr/lib/
endef

define Build/Clean
	if [ -d $(PKG_BUILD_DIR) ]; then $(MAKE) -C $(PKG_BUILD_DIR) clean; \
	$(RM) -r $(PKG_BUILD_DIR)/ipkg-$(BOARD); fi
endef

$(eval $(call BuildPackage,$(PKG_NAME)))
