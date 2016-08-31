#
# Copyright (C) 2013 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/kernel.mk

PKG_NAME:=dsl-cpe-api-vrx
PKG_VERSION:=4.16.5.4
PKG_MD5SUM:=98b2f779745e191547aa6cc9d8e913cc
PKG_RELEASE:=1
PKG_INSTALL:=1
PKG_BASE_NAME:=drv_dsl_cpe_api_vrx
PKG_SOURCE:=$(PKG_BASE_NAME)-$(PKG_VERSION).tar.gz
PKG_BUILD_DIR:=$(KERNEL_BUILD_DIR)/drv_dsl_cpe_api-$(PKG_VERSION)
PKG_BUILD_DIR_NONBOND:=$(PKG_BUILD_DIR)/nonbond/drv_dsl_cpe_api-$(PKG_VERSION)
PKG_SOURCE_URL:=http://localhost
PKG_BUILD_DEPENDS:=dsl-cpe-mei-vrx

LANTIQ_BIN_DIR=/opt/lantiq/bin
LANTIQ_BIN_DIR_NONBOND=/opt/lantiq/bin/nonbond

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/package-version-override.mk

# get config values from general image config or other packages in dependency list
# Definition of these values will be overtaken from package 'dsl-cpe-mei-vrx'
DSL_MAX_DEVICE=$(strip $(subst ",, $(CONFIG_VRX_MAX_DEVICE)))
DSL_LINES_PER_DEVICE=$(strip $(subst ",, $(CONFIG_VRX_LINES_PER_DEVICE)))
DSL_CHANNELS_PER_LINE=$(strip $(subst ",, $(CONFIG_VRX_CHANNELS_PER_LINE)))

# Set default config values if necessary (not defined before)
ifeq ($(DSL_MAX_DEVICE),)
	DSL_MAX_DEVICE=1
endif

ifeq ($(DSL_LINES_PER_DEVICE),)
	DSL_LINES_PER_DEVICE=1
endif

ifeq ($(DSL_CHANNELS_PER_LINE),)
	DSL_CHANNELS_PER_LINE=1
endif

# DSL_MAX_DEVICE * DSL_LINES_PER_DEVICE
DSL_TOTAL_ENTITIES:=$(shell echo $$[$(DSL_MAX_DEVICE)*$(DSL_LINES_PER_DEVICE)])

ifeq ($(DUMP),)
	STAMP_CONFIGURED:=$(strip $(STAMP_CONFIGURED))_$(shell $(SH_FUNC) ( \
		grep '^CONFIG_dsl-cpe-api-vrx' $(TOPDIR)/.config; \
		grep '^CONFIG_VRX_' $(TOPDIR)/.config) | md5s)
endif

define dsl_pkg
define Package/$(1)
	SECTION:=driver
	CATEGORY:=Lantiq
	SUBMENU:=DSL Subsystem
	TITLE:=DSL CPE API $(if $(subst $(PKG_NAME),,$(1)),non-bond )driver
	URL:=http://www.lantiq.com/
	MAINTAINER:=Lantiq Deutschland GmbH
	DEPENDS:=+dsl-cpe-mei-vrx $(if $(subst $(PKG_NAME),,$(1)),@BUILD_SEPARATE_NONBONDED_BINS) \
		$(if $(subst $(PKG_NAME),,$(1)),,+BUILD_SEPARATE_NONBONDED_BINS:$(PKG_NAME)-nonbond)
  	$(if $(subst $(PKG_NAME),,$(1)),,MENU:=1)
endef

define Package/$(1)/description
	This package contains the Lantiq DSL CPE API $(if $(subst $(PKG_NAME),,$(1)),non-bond )driver.

	Supported Devices:
		- VRX200 Family
		- VRX300 Family
endef
endef

define Package/$(PKG_NAME)/config
$(call Package/$(PKG_NAME)/override_version)
$(call Package/$(PKG_NAME)/override_source_path)
	source "$(SOURCE)/Config.in"
endef

CONFIGURE_ARGS += --enable-kernel-include="$(LINUX_DIR)/include" \
	--with-max-device="$(DSL_MAX_DEVICE)" \
	--with-lines-per-device="$(DSL_LINES_PER_DEVICE)" \
	--with-channels-per-line="$(DSL_CHANNELS_PER_LINE)"

CONFIGURE_ARGS += --enable-vrx \
	--enable-ifxos \
	--enable-ifxos-include="-I$(STAGING_DIR)/usr/include/ifxos" \
	--enable-driver-include="-I$(STAGING_DIR)/usr/include" \
	--enable-add-drv-cflags="-DMODULE -DINCLUDE_DSL_ATM_PTM_INTERFACE_SUPPORT" \
	--enable-adsl-led=no \
	--enable-adsl-mib=no \
	--enable-dsl-ceoc=no

ifeq ($(CONFIG_$(PKG_NAME)_DEVICE_VR9),y)
CONFIGURE_ARGS += --enable-vrx-device=vr9
else ifeq ($(CONFIG_$(PKG_NAME)_DEVICE_VR10),y)
CONFIGURE_ARGS += --enable-vrx-device=vr10
else ifeq ($(CONFIG_$(PKG_NAME)_DEVICE_VR10_320),y)
CONFIGURE_ARGS += --enable-vrx-device=vr10_320
else
CONFIGURE_ARGS += --enable-vrx-device=vr9
endif

ifeq ($(CONFIG_$(PKG_NAME)_MODEL_LITE),y)
	CONFIGURE_ARGS += --enable-model=lite
	DRV_BILD_MODEL="lite"
else ifeq ($(CONFIG_$(PKG_NAME)_MODEL_FOOTPRINT),y)
	CONFIGURE_ARGS += --enable-model=footprint
	DRV_BILD_MODEL="footprint"
else ifeq ($(CONFIG_$(PKG_NAME)_MODEL_TYPICAL),y)
	CONFIGURE_ARGS += --enable-model=typical
	DRV_BILD_MODEL="typical"
else ifeq ($(CONFIG_$(PKG_NAME)_MODEL_FULL),y)
	CONFIGURE_ARGS += --enable-model=full
	DRV_BILD_MODEL="full"
else ifeq ($(CONFIG_$(PKG_NAME)_MODEL_DEBUG),y)
	CONFIGURE_ARGS += --enable-model=debug
	DRV_BILD_MODEL="debug"
else
	CONFIGURE_ARGS += --enable-model=footprint
	DRV_BILD_MODEL="footprint"
endif

ifeq ($(CONFIG_$(PKG_NAME)_USE_ADDITIONAL_BUILD_OPTIONS),y)
CONFIGURE_ARGS += $(CONFIG_$(PKG_NAME)_ADDITIONAL_BUILD_OPTIONS)
endif

#ifeq ($(CONFIG_LINUX_2_6),y)
CONFIGURE_ARGS += --enable-linux-26 --enable-kernelbuild="$(LINUX_DIR)" ARCH=$(LINUX_KARCH)
PKG_MODULE_EXTENSION=.ko
#endif

ifeq ($(CONFIG_mips),y)
EXTRA_CFLAGS = -fno-pic -mno-abicalls -mlong-calls -G 0
endif

define Build/Configure
	# remove "configured" stamps of other configs
	@- rm $(PKG_BUILD_DIR)/.configured*
	$(call Build/Configure/Default)
endef

define Build/Clean
	$(eval PKG_BUILD_DIR:=$(KERNEL_BUILD_DIR)/drv_dsl_cpe_api-$(PKG_VERSION))
	@- rm -Rf $(PKG_BUILD_DIR)/ipkg*
	@- [ -e $(PKG_BUILD_DIR)/Makefile ] && $(MAKE) -C $(PKG_BUILD_DIR) clean
	$(call Build/Clean/Default)
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include/drv_dsl_cpe_api
	$(CP) $(PKG_BUILD_DIR)/src/include/drv_dsl_cpe*.h $(1)/usr/include/drv_dsl_cpe_api/
endef

define Build/Compile
	$(call Build/Compile/Default)
	$(if $(CONFIG_PACKAGE_$(PKG_NAME)-nonbond),
		$(eval PKG_BUILD_DIR:=$(PKG_BUILD_DIR_NONBOND))
		$(eval CONFIGURE_ARGS=$(subst with-max-device="$(DSL_MAX_DEVICE)",with-max-device="1",$(CONFIGURE_ARGS)))
		$(eval CONFIGURE_ARGS=$(subst with-lines-per-device="$(DSL_LINES_PER_DEVICE)",with-lines-per-device="1",$(CONFIGURE_ARGS)))
		mkdir -p $(PKG_BUILD_DIR)
		$(call Build/Prepare/Default)
		$(call Build/Configure)
		$(call Build/Compile/Default)
	)
endef

define Package/$(PKG_NAME)/install
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/ltq_load_dsl_cpe_api.sh $(1)/etc/init.d/

	$(INSTALL_DIR) $(1)/$(LANTIQ_BIN_DIR)
	$(INSTALL_DIR) $(1)/$(LANTIQ_BIN_DIR)/bonded

	# Copy configuration files to rootfs
	@- [ -e ./files/dsl_auto_api.cfg ] && $(INSTALL_DATA) ./files/dsl_auto_api.cfg $(1)/$(LANTIQ_BIN_DIR)

	# Set common variables within DSL config file
	$(SED) "s:@drv_build_model@:$(DRV_BILD_MODEL):g" $(1)/$(LANTIQ_BIN_DIR)/dsl_auto_api.cfg;

	$(INSTALL_BIN) ./files/inst_drv_dsl_cpe_api.sh $(1)/$(LANTIQ_BIN_DIR)/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/drv_dsl_cpe_api$(PKG_MODULE_EXTENSION) $(1)/$(LANTIQ_BIN_DIR)/bonded
	( cd $(1)/$(LANTIQ_BIN_DIR)/ && ln -snf bonded/drv_dsl_cpe_api$(PKG_MODULE_EXTENSION) )
	$(INSTALL_DIR) $(1)/$(MODULES_SUBDIR)
	ln -snf $(LANTIQ_BIN_DIR)/drv_dsl_cpe_api$(PKG_MODULE_EXTENSION) $(1)/$(MODULES_SUBDIR)/drv_dsl_cpe_api.$(LINUX_KMOD_SUFFIX)
endef

define Package/$(PKG_NAME)-nonbond/install
	$(INSTALL_DIR) $(1)/$(LANTIQ_BIN_DIR_NONBOND)
	$(INSTALL_BIN) $(PKG_BUILD_DIR_NONBOND)/src/drv_dsl_cpe_api$(PKG_MODULE_EXTENSION) $(1)/$(LANTIQ_BIN_DIR_NONBOND)
endef

$(foreach pkg_name,$(PKG_NAME) $(PKG_NAME)-nonbond,$(eval $(call dsl_pkg,$(pkg_name))))
$(foreach pkg_name,$(PKG_NAME) $(PKG_NAME)-nonbond,$(eval $(call BuildPackage,$(pkg_name))))
