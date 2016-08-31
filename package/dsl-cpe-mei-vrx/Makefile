#
# Copyright (C) 2013 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/kernel.mk

PKG_NAME:=dsl-cpe-mei-vrx
PKG_VERSION:=1.4.9.7
PKG_MD5SUM:=021c13231b404a359e0289ef6fa3b131
PKG_BASE_NAME:=drv_mei_cpe
PKG_SOURCE:=$(PKG_BASE_NAME)-$(PKG_VERSION).tar.gz
PKG_BUILD_DIR:=$(KERNEL_BUILD_DIR)/$(PKG_BASE_NAME)-$(PKG_VERSION)
PKG_BUILD_DIR_NONBOND:=$(PKG_BUILD_DIR)/nonbond/$(PKG_BASE_NAME)-$(PKG_VERSION)
PKG_RELEASE:=1
PKG_INSTALL:=1
PKG_SOURCE_URL:=http://localhost
LANTIQ_BIN_DIR=opt/lantiq/bin
LANTIQ_BIN_DIR_NONBOND=opt/lantiq/bin/nonbond
FW_DIR=/lib/firmware

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/package-version-override.mk

# Get config values from general image config or other packages in dependency list
# By default this is the reference place for definition of the following values
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

DSL_TOTAL_ENTITIES:=$(shell echo $$[$(DSL_MAX_DEVICE)*$(DSL_LINES_PER_DEVICE)])

ifeq ($(DUMP),)
	STAMP_CONFIGURED:=$(strip $(STAMP_CONFIGURED))_$(shell $(SH_FUNC) ( \
		grep '^CONFIG_$(PKG_NAME)' $(TOPDIR)/.config; \
		grep '^CONFIG_VRX320_PTM_VECTORING' $(TOPDIR)/.config) | md5s)
endif

define dsl_pkg
define Package/$(1)
  SECTION:=driver
  CATEGORY:=Lantiq
  SUBMENU:=DSL Subsystem
  TITLE:=DSL CPE MEI $(if $(subst $(PKG_NAME),,$(1)),non-bond )Driver for VRX Family
  URL:=http://www.Lantiq.com/
  MAINTAINER:=Lantiq Deutschland GmbH
  DEPENDS:=$(if $(subst $(PKG_NAME),,$(1)),@BUILD_SEPARATE_NONBONDED_BINS) \
	+kmod-ifxos +kmod-dsl-cpe-mei-vrx +kmod-ltq-ifxos $(if $(subst $(PKG_NAME),,$(1)),,+BUILD_SEPARATE_NONBONDED_BINS:$(PKG_NAME)-nonbond)
  $(if $(subst $(PKG_NAME),,$(1)),,MENU:=1)
endef

define Package/$(1)/description
	Lantiq MEI CPE $(if $(subst $(PKG_NAME),,$(1)),non-bond )Driver
	Supported Devices:
		- VRX200 Family
		- VRX300 Family
endef
endef

define KernelPackage/$(PKG_NAME)
  SUBMENU:=Lantiq
  TITLE:=DSL CPE MEI Driver for VRX Family
  URL:=http://www.lantiq.com/
  MAINTAINER:=Lantiq Deutschland GmbH
  DEPENDS:=+kmod-ifxos
#  @(TARGET_ltqcpe_vr9||TARGET_ltqcpe_platform_vr9||TARGET_ltqcpe_platform_ar10_vrx318||TARGET_lantiq_xway)
  KCONFIG:=CONFIG_LTQ_DSL_CPE_MEI_VRX=y
endef

# package specific configuration
define Package/$(PKG_NAME)/config
$(call Package/$(PKG_NAME)/override_version)
$(call Package/$(PKG_NAME)/override_source_path)
	source "$(SOURCE)/Config.in"
endef 

define KernelPackage/$(PKG_NAME)/description
	Lantiq MEI CPE Kernel Module Driver
endef


ifeq ($(CONFIG_$(PKG_NAME)_DEVICE_VR9),y)
CONFIGURE_ARGS += --enable-device=vr9
else ifeq ($(CONFIG_$(PKG_NAME)_DEVICE_VR10),y)
CONFIGURE_ARGS += --enable-device=vr10
else ifeq ($(CONFIG_$(PKG_NAME)_DEVICE_VR10_320),y)
CONFIGURE_ARGS += --enable-device=vr10_320
else
CONFIGURE_ARGS += --enable-device=vr9
INCLUDE_DSM=-DMEI_SUPPORT_DSM=1
endif

ifdef CONFIG_VRX320_PTM_VECTORING
  CONFIG_PTM_VECTORING:=y
endif

ifeq ($(CONFIG_PTM_VECTORING),y)
INCLUDE_DSM=-DMEI_SUPPORT_DSM=1
else
INCLUDE_DSM=-DMEI_SUPPORT_DSM=0
endif

CONFIGURE_ARGS += \
	--enable-kernelincl="$(LINUX_DIR)/include" \
	--with-max-device=$(DSL_MAX_DEVICE) \
	--with-lines-per-device=$(DSL_LINES_PER_DEVICE) \
	--enable-debug --enable-error_print \
	--enable-ifxos-include="-I$(STAGING_DIR)/usr/include/ifxos" \
	--enable-ifxos-library="-L$(STAGING_DIR)/usr/lib" \
	--enable-add_drv_cflags="${INCLUDE_DSM} -DMEI_DRV_ATM_PTM_INTERFACE_ENABLE=1 -fno-pic -mlong-calls -O2 -g0"

ifeq ($(CONFIG_dsl-cpe-mei-vrx_USE_KERNEL_BUILD_IN),y)
CONFIGURE_ARGS += \
	--enable-ifxos_drv=no \
	--enable-lkm=no 
endif

ifeq ($(CONFIG_dsl-cpe-mei-vrx_USE_PCI_SLAVE_DOWNLOAD),y)
CONFIGURE_ARGS += \
	--enable-pci-slave=yes

ifeq ($(CONFIG_dsl-cpe-mei-vrx_USE_PCI_SLAVE_ADDR_RANGE_ADTRAN),y)
CONFIGURE_ARGS += \
	--enable-pci-slave-addr=adtran
else ifeq ($(CONFIG_dsl-cpe-mei-vrx_USE_PCI_SLAVE_ADDR_RANGE_BONDING),y)
CONFIGURE_ARGS += \
	--enable-pci-slave-addr=bonding
else
CONFIGURE_ARGS += \
	--enable-pci-slave-addr=bonding
endif
endif

ifeq ($(CONFIG_dsl-cpe-mei-vrx_MEI_PREDEF_DBG_BAR),y)
CONFIGURE_ARGS += --enable-predef-dbg-bar=yes
else
CONFIGURE_ARGS += --enable-predef-dbg-bar=no
endif

#ifeq ($(CONFIG_LINUX_2_6),y)
CONFIGURE_ARGS += \
	--enable-linux-26 \
	--enable-kernelbuild="$(LINUX_DIR)" \
	ARCH=$(LINUX_KARCH)
PKG_MODULE_EXTENSION=.ko
#endif

define Build/Configure
	# remove "configured" stamps of other configs
	@- rm $(PKG_BUILD_DIR)/.configured*
	$(call Build/Configure/Default)
endef

define Build/Clean
	$(eval PKG_BUILD_DIR:=$(KERNEL_BUILD_DIR)/$(PKG_BASE_NAME)-$(PKG_VERSION))
	@- rm -Rf $(PKG_BUILD_DIR)/ipkg*
	@- [ -e $(PKG_BUILD_DIR)/Makefile ] && $(MAKE) -C $(PKG_BUILD_DIR) clean
	@- rm -f $(LINUX_DIR)/drivers/char/ltq_dsl_cpe_mei_vrx.o
	$(call Build/Clean/Default)
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/{lib,include}
	$(CP) $(PKG_BUILD_DIR)/src/drv_mei_cpe_api_intern.h $(1)/usr/include/
	$(CP) $(PKG_BUILD_DIR)/src/drv_mei_cpe_api_atm_ptm_intern.h $(1)/usr/include/
	$(CP) $(PKG_BUILD_DIR)/src/drv_mei_cpe_interface.h $(1)/usr/include/
	$(CP) $(PKG_BUILD_DIR)/src/drv_mei_cpe_config.h $(1)/usr/include/
	$(CP) $(PKG_BUILD_DIR)/src/cmv_message_format.h $(1)/usr/include/
endef

define Build/Compile
	$(call Build/Compile/Default)
	$(if $(CONFIG_PACKAGE_$(PKG_NAME)-nonbond),
		$(eval PKG_BUILD_DIR:=$(PKG_BUILD_DIR_NONBOND))
		$(eval CONFIGURE_ARGS=$(subst with-max-device=$(DSL_MAX_DEVICE),with-max-device=1,$(CONFIGURE_ARGS)))
		$(eval CONFIGURE_ARGS=$(subst with-lines-per-device=$(DSL_LINES_PER_DEVICE),with-lines-per-device=1,$(CONFIGURE_ARGS)))
		mkdir -p $(PKG_BUILD_DIR)
		$(SH_FUNC) $(call UNPACK_CMD,$(PKG_BUILD_DIR)) $(call CRLF_CMD,$(PKG_BUILD_DIR))
		$(call Build/Patch/Default)
		$(call Build/Configure)
		$(call Build/Compile/Default)
	)
endef

define Package/$(PKG_NAME)/install
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/ltq_load_cpe_mei_drv.sh $(1)/etc/init.d/

	$(INSTALL_DIR) $(1)/$(LANTIQ_BIN_DIR)
	$(INSTALL_DIR) $(1)/$(LANTIQ_BIN_DIR)/bonded

	# Copy configuration files to rootfs
	@- [ -e ./files/dsl.cfg ] && $(INSTALL_DATA) ./files/dsl.cfg $(1)/$(LANTIQ_BIN_DIR)
	@- [ -e ./files/dsl_auto.cfg ] && $(INSTALL_DATA) ./files/dsl_auto.cfg $(1)/$(LANTIQ_BIN_DIR)
	@- [ -e ./files/dsl_auto_mei.cfg ] && $(INSTALL_DATA) ./files/dsl_auto_mei.cfg $(1)/$(LANTIQ_BIN_DIR)/bonded
	@- [ -e ./files/dsl_auto_mei.cfg ] && \
		( cd $(1)/$(LANTIQ_BIN_DIR)/ && ln -sf bonded/dsl_auto_mei.cfg )
		
	echo DSL_TOTAL_ENTITIES = $(DSL_TOTAL_ENTITIES)
	$(SED) "s:@dsl_entities@:$(DSL_TOTAL_ENTITIES):g" $(1)/$(LANTIQ_BIN_DIR)/bonded/dsl_auto_mei.cfg

	# Set support flag for L2 vectoring
ifeq ($(CONFIG_PTM_VECTORING),y)
	$(SED) "s:@vectoring_l2_cfg@:1:g" $(1)/$(LANTIQ_BIN_DIR)/bonded/dsl_auto_mei.cfg;
else
	$(SED) "s:@vectoring_l2_cfg@:0:g" $(1)/$(LANTIQ_BIN_DIR)/bonded/dsl_auto_mei.cfg;
endif

	# Set support flag for bonding
ifeq ($(DSL_TOTAL_ENTITIES),1)
	$(SED) "s:@bonding_cfg@:0:g" $(1)/$(LANTIQ_BIN_DIR)/bonded/dsl_auto_mei.cfg;
else
	$(SED) "s:@bonding_cfg@:1:g" $(1)/$(LANTIQ_BIN_DIR)/bonded/dsl_auto_mei.cfg;
endif

	$(INSTALL_BIN) ./files/inst_drv_mei_cpe.sh $(1)/$(LANTIQ_BIN_DIR)
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/scripts/alias_drv_mei_cpe.sh $(1)/$(LANTIQ_BIN_DIR)
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/scripts/enable_ARC_JTAG.sh $(1)/$(LANTIQ_BIN_DIR)
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/mei_cpe_drv_test $(1)/$(LANTIQ_BIN_DIR)

ifeq ($(CONFIG_dsl-cpe-mei-vrx_USE_KERNEL_BUILD_IN),y)
	$(INSTALL_DIR) $(1)/$(FW_DIR)
	$(CP) -s $(PKG_BUILD_DIR)/src/$(PKG_BASE_NAME).o $(LINUX_DIR)/drivers/char/ltq_dsl_cpe_mei_vrx.o
else
	-rm -f $(LINUX_DIR)/drivers/char/ltq_dsl_cpe_mei_vrx.o
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/$(PKG_BASE_NAME)$(PKG_MODULE_EXTENSION) $(1)/$(LANTIQ_BIN_DIR)/bonded
	( cd $(1)/$(LANTIQ_BIN_DIR)/ && ln -snf bonded/$(PKG_BASE_NAME)$(PKG_MODULE_EXTENSION) )
	$(INSTALL_DIR) $(1)/$(MODULES_SUBDIR)
	ln -snf /$(LANTIQ_BIN_DIR)/$(PKG_BASE_NAME)$(PKG_MODULE_EXTENSION) $(1)/$(MODULES_SUBDIR)/$(PKG_BASE_NAME).$(LINUX_KMOD_SUFFIX)

	$(INSTALL_DIR) $(1)/$(FW_DIR)
endif
endef

define Package/$(PKG_NAME)-nonbond/install
	$(INSTALL_DIR) $(1)/$(LANTIQ_BIN_DIR_NONBOND)
	@- [ -e ./files/dsl_auto_mei.cfg ] && $(INSTALL_DATA) ./files/dsl_auto_mei.cfg $(1)/$(LANTIQ_BIN_DIR_NONBOND)
	$(SED) "s:@dsl_entities@:1:g" $(1)/$(LANTIQ_BIN_DIR_NONBOND)/dsl_auto_mei.cfg;
	$(SED) "s:@bonding_cfg@:0:g" $(1)/$(LANTIQ_BIN_DIR_NONBOND)/dsl_auto_mei.cfg;
	# Set support flag for L2 vectoring
ifeq ($(CONFIG_PTM_VECTORING),y)
	$(SED) "s:@vectoring_l2_cfg@:1:g" $(1)/$(LANTIQ_BIN_DIR_NONBOND)/dsl_auto_mei.cfg;
else
	$(SED) "s:@vectoring_l2_cfg@:0:g" $(1)/$(LANTIQ_BIN_DIR_NONBOND)/dsl_auto_mei.cfg;
endif
	$(INSTALL_BIN) $(PKG_BUILD_DIR_NONBOND)/src/$(PKG_BASE_NAME)$(PKG_MODULE_EXTENSION) $(1)/$(LANTIQ_BIN_DIR_NONBOND)
endef

$(foreach pkg_name,$(PKG_NAME) $(PKG_NAME)-nonbond,$(eval $(call dsl_pkg,$(pkg_name))))
$(foreach pkg_name,$(PKG_NAME) $(PKG_NAME)-nonbond,$(eval $(call BuildPackage,$(pkg_name))))
$(eval $(call KernelPackage,$(PKG_NAME)))
