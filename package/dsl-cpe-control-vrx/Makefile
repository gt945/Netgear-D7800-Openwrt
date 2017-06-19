#
# Copyright (C) 2013 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/kernel.mk

PKG_NAME:=dsl-cpe-control-vrx
PKG_VERSION:=4.16.5.4
PKG_MD5SUM:=abcb554e6ade7bd7dbdfd8f7a64d2d55
PKG_RELEASE:=1
PKG_BASE_NAME:=dsl_cpe_control_vrx
PKG_SOURCE:=$(PKG_BASE_NAME)-$(PKG_VERSION).tar.gz
PKG_BUILD_DIR:=$(KERNEL_BUILD_DIR)/dsl_cpe_control-$(PKG_VERSION)
PKG_BUILD_DIR_NONBOND:=$(PKG_BUILD_DIR)/nonbond/dsl_cpe_control-$(PKG_VERSION)
PKG_SOURCE_URL:=http://localhost
PKG_BUILD_DEPENDS:=dsl-cpe-api-vrx dsl-cpe-mei-vrx dsl-cpe-control-vrx_DTI:lib-dti

LANTIQ_BIN_DIR=/opt/lantiq/bin
LANTIQ_BIN_DIR_NONBOND=/opt/lantiq/bin/nonbond

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/package-version-override.mk

# Get config values from general image config or other packages in dependency list
# Definition of these values will be overtaken from package 'dsl-cpe-mei-vrx'
DSL_MAX_DEVICE=$(strip $(subst ",, $(CONFIG_VRX_MAX_DEVICE)))
DSL_LINES_PER_DEVICE=$(strip $(subst ",, $(CONFIG_VRX_LINES_PER_DEVICE)))
DSL_CHANNELS_PER_LINE=$(strip $(subst ",, $(CONFIG_VRX_CHANNELS_PER_LINE)))

DSL_TOTAL_ENTITIES:=$(shell echo $$[$(DSL_MAX_DEVICE)*$(DSL_LINES_PER_DEVICE)])

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

ifeq ($(CONFIG_LTQ_CLI),)
CONFIG_LTQ_CLI=y
endif

ifeq ($(DUMP),)
	STAMP_CONFIGURED:=$(strip $(STAMP_CONFIGURED))_$(shell $(SH_FUNC) ( \
		grep '^CONFIG_$(PKG_NAME)' $(TOPDIR)/.config; \
		grep '^CONFIG_DSL_' $(TOPDIR)/.config; \
		grep '^CONFIG_VRX_' $(TOPDIR)/.config; \
		grep '^CONFIG_PTM_VECTORING' $(LINUX_DIR)/.config) | md5s)
endif

define Package/dsl-cpe-control
	SECTION:=application
	CATEGORY:=Lantiq
	SUBMENU:=DSL Subsystem
	URL:=http://www.lantiq.com/
	MAINTAINER:=Lantiq Deutschland GmbH
	PROVIDES:=dsl-cpe-control
endef

define Package/dsl-cpe-control/description
	Lantiq DSL CPE for Amazon SE, Danube,Vinax and VRx.
endef

define dsl_pkg
define Package/$(1)
	$(call Package/dsl-cpe-control)
	TITLE:=DSL CPE control $(if $(subst $(PKG_NAME),,$(1)),non-bond )application
	DEPENDS:=dsl-cpe-api-vrx +libpthread +librt +lib-dti \
		$(if $(subst $(PKG_NAME),,$(1)),@BUILD_SEPARATE_NONBONDED_BINS) \
		$(if $(subst $(PKG_NAME),,$(1)),,+BUILD_SEPARATE_NONBONDED_BINS:$(PKG_NAME)-nonbond)
	$(if $(subst $(PKG_NAME),,$(1)),,MENU:=1)
endef

define Package/$(1)/description
	This package contains the DSL CPE control $(if $(subst $(PKG_NAME),,$(1)),non-bond )application.

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

CONFIGURE_ARGS += \
	--with-max-device="$(DSL_MAX_DEVICE)" \
	--with-lines-per-device="$(DSL_LINES_PER_DEVICE)" \
	--with-channels-per-line="$(DSL_CHANNELS_PER_LINE)"

CONFIGURE_ARGS += \
	--enable-vrx \
	--enable-driver-include="-I$(STAGING_DIR)/usr/include/drv_dsl_cpe_api" \
	--enable-device-driver-include="-I$(STAGING_DIR)/usr/include" \
	--enable-ifxos \
	--enable-ifxos-include="-I$(STAGING_DIR)/usr/include/ifxos" \
	--enable-ifxos-library="-I$(STAGING_DIR)/usr/lib" \
	--enable-dsl-ceoc=no

ifeq ($(CONFIG_dsl-cpe-control-vrx_DTI),y)
ifeq ($(CONFIG_$(PKG_NAME)_DEVICE_VR10_320),y)
CONFIGURE_ARGS += \
	--enable-dti=no
else
CONFIGURE_ARGS += \
	--enable-dti=yes
endif
CONFIGURE_ARGS += \
	--enable-dti-include="-I$(STAGING_DIR)/usr/include/dti" \
	--enable-dti-library="-L$(STAGING_DIR)/usr/lib"
endif

ifeq ($(CONFIG_LTQ_CLI),y)
CONFIGURE_ARGS += \
	--enable-cli-support
endif

ifeq ($(CONFIG_$(PKG_NAME)_DEVICE_VR9),y)
	CONFIGURE_ARGS += --enable-vrx-device=vr9
else ifeq ($(CONFIG_$(PKG_NAME)_DEVICE_VR10),y)
	CONFIGURE_ARGS += --enable-vrx-device=vr10
else ifeq ($(CONFIG_$(PKG_NAME)_DEVICE_VR10_320),y)
	CONFIGURE_ARGS += --enable-vrx-device=vr10_320
else
	CONFIGURE_ARGS += --enable-vrx-device=vr9
endif

# Default number of pipes used for CLI communication is two
NUM_PIPES:=2
ifeq ($(CONFIG_$(PKG_NAME)_MODEL_LITE),y)
	CONFIGURE_ARGS += --enable-model=lite
	APP_BILD_MODEL="lite"
else ifeq ($(CONFIG_$(PKG_NAME)_MODEL_FOOTPRINT),y)
	CONFIGURE_ARGS += --enable-model=footprint
	APP_BILD_MODEL="footprint"
else ifeq ($(CONFIG_$(PKG_NAME)_MODEL_TYPICAL),y)
	CONFIGURE_ARGS += --enable-model=typical
	APP_BILD_MODEL="typical"
else ifeq ($(CONFIG_$(PKG_NAME)_MODEL_FULL),y)
	CONFIGURE_ARGS += --enable-model=full
	APP_BILD_MODEL="full"
else ifeq ($(CONFIG_$(PKG_NAME)_MODEL_DEBUG),y)
	CONFIGURE_ARGS += --enable-model=debug
	# In case of debug compilation number of pipes is increased to five
	NUM_PIPES:=5
	APP_BILD_MODEL="debug"
else
	CONFIGURE_ARGS += --enable-model=footprint
	APP_BILD_MODEL="footprint"
endif

CONFIGURE_ARGS += --enable-add-appl-cflags="-DMAX_CLI_PIPES=$(NUM_PIPES)"

ifeq ($(CONFIG_$(PKG_NAME)_USE_ADDITIONAL_BUILD_OPTIONS),y)
	CONFIGURE_ARGS += $(CONFIG_$(PKG_NAME)_ADDITIONAL_BUILD_OPTIONS)
endif

define Build/Configure
	# remove "configured" stamps of other configs
	@- rm $(PKG_BUILD_DIR)/.configured*
	$(call Build/Configure/Default)
endef

define Build/Clean
	$(eval PKG_BUILD_DIR:=$(KERNEL_BUILD_DIR)/dsl_cpe_control-$(PKG_VERSION))
	@- rm -Rf $(PKG_BUILD_DIR)/ipkg*
	@- [ -e $(PKG_BUILD_DIR)/Makefile ] && $(MAKE) -C $(PKG_BUILD_DIR) clean
	$(call Build/Clean/Default)
endef

define Build/Compile
	$(call Build/Compile/Default)
	$(if $(CONFIG_PACKAGE_$(PKG_NAME)-nonbond),
		$(eval PKG_BUILD_DIR:=$(PKG_BUILD_DIR_NONBOND))
		$(eval CONFIGURE_ARGS=$(subst with-max-device="$(DSL_MAX_DEVICE)",with-max-device="1",$(CONFIGURE_ARGS)))
		$(eval CONFIGURE_ARGS=$(subst with-lines-per-device="$(DSL_LINES_PER_DEVICE)",with-lines-per-device="1",$(CONFIGURE_ARGS)))
		mkdir -p $(PKG_BUILD_DIR)
		$(call PKG_UNPACK)
		$(call Build/Patch/Default)
		$(call Build/Configure)
		$(call Build/Compile/Default)
	)
endef

define Package/$(PKG_NAME)/install
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/ltq_dsl_fw_dbg.sh $(1)/etc/init.d/
	$(INSTALL_BIN) ./files/ltq_cpe_control_init.sh $(1)/etc/init.d/
	$(INSTALL_DIR) $(1)/$(LANTIQ_BIN_DIR)
	$(INSTALL_DIR) $(1)/$(LANTIQ_BIN_DIR)/bonded

ifeq ($(DSL_LINES_PER_DEVICE),1)
	#$(INSTALL_DATA) ./files/adsl.scr $(1)/$(LANTIQ_BIN_DIR)
	#$(INSTALL_DATA) ./files/vdsl.scr $(1)/$(LANTIQ_BIN_DIR)
else
	#$(INSTALL_DATA) ./files/adsl_bonding.scr $(1)/$(LANTIQ_BIN_DIR)/adsl.scr
	#$(INSTALL_DATA) ./files/vdsl_bonding.scr $(1)/$(LANTIQ_BIN_DIR)/vdsl.scr
endif
	ln -sf /tmp/etc/adsl.scr $(1)/$(LANTIQ_BIN_DIR)/adsl.scr
	ln -sf /tmp/etc/vdsl.scr $(1)/$(LANTIQ_BIN_DIR)/vdsl.scr

	# Copy configuration files to rootfs
	@- [ -e ./files/dsl_auto_app.cfg ] && $(INSTALL_DATA) ./files/dsl_auto_app.cfg $(1)/$(LANTIQ_BIN_DIR)

	# Set common variables within DSL config file
	$(SED) "s:@num_dsl_pipes@:$(NUM_PIPES):g" $(1)/$(LANTIQ_BIN_DIR)/dsl_auto_app.cfg;
	$(SED) "s:@app_build_model@:$(APP_BILD_MODEL):g" $(1)/$(LANTIQ_BIN_DIR)/dsl_auto_app.cfg;

	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/dsl_cpe_control $(1)/$(LANTIQ_BIN_DIR)/bonded
	( cd $(1)/$(LANTIQ_BIN_DIR)/ && ln -snf bonded/dsl_cpe_control )
	$(INSTALL_BIN) ./files/alias_dsl_cpe.sh $(1)/$(LANTIQ_BIN_DIR)
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/scripts/dsl_cpe_pipe.sh $(1)/$(LANTIQ_BIN_DIR)
endef

define Package/$(PKG_NAME)-nonbond/install
	$(INSTALL_DIR) $(1)/$(LANTIQ_BIN_DIR_NONBOND)
	$(INSTALL_DATA) ./files/adsl.scr $(1)/$(LANTIQ_BIN_DIR_NONBOND)
	$(INSTALL_DATA) ./files/vdsl.scr $(1)/$(LANTIQ_BIN_DIR_NONBOND)
	$(INSTALL_BIN) $(PKG_BUILD_DIR_NONBOND)/src/dsl_cpe_control $(1)/$(LANTIQ_BIN_DIR_NONBOND)
endef

$(foreach pkg_name,$(PKG_NAME) $(PKG_NAME)-nonbond,$(eval $(call dsl_pkg,$(pkg_name))))
$(foreach pkg_name,$(PKG_NAME) $(PKG_NAME)-nonbond,$(eval $(call BuildPackage,$(pkg_name))))
