#
# Copyright (C) 2013 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
# $Id: $

include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/kernel.mk

PKG_NAME:=dsl-vr10-firmware-xdsl
PKG_VERSION:=07.08.01.05.00.07_07.08.00.09.00.01
PKG_MD5SUM:=73f131ce11baa688f6ead0cc50ce184a
PKG_BASE_NAME:=dsl_vr10_firmware_xdsl
PKG_SOURCE:=$(PKG_BASE_NAME)-$(PKG_VERSION).tar.gz
PKG_BUILD_DIR:=$(KERNEL_BUILD_DIR)/$(PKG_BASE_NAME)-$(PKG_VERSION)
PKG_RELEASE:=1
PKG_UNPACK:=gzip -dc $(DL_DIR)/$(PKG_SOURCE) | $(TAR) -C $(PKG_BUILD_DIR) $(TAR_OPTIONS)
PKG_SOURCE_URL:=http://localhost
PKG_TARGET_BASE_NAME:=xcpe_hw.bin

FIRMWARE_DIR:=/lib/firmware

include $(INCLUDE_DIR)/package-version-override.mk
include $(INCLUDE_DIR)/package.mk

ifeq ($(DUMP),)
  $(info "FIRMWARE_DIR = $(FIRMWARE_DIR)")
   STAMP_CONFIGURED:=$(strip $(STAMP_CONFIGURED))_$(shell $(SH_FUNC) ( \
      grep '^CONFIG_UBOOT_CONFIG_FIRMWARE_IN_ROOTFS' $(TOPDIR)/.config; \
      grep '^CONFIG_$(PKG_NAME)' $(TOPDIR)/.config) | md5s)
endif

define Package/$(PKG_NAME)
  SECTION:=firmware
  CATEGORY:=Lantiq
  SUBMENU:=DSL Subsystem
  TITLE:=VR10 CPE xDSL firmware
  URL:=http://www.lantiq.com/
  MAINTAINER:=Lantiq Deutschland GmbH
  DEPENDS:=+dsl-cpe-mei-vrx @!PACKAGE_dsl-vr10-firmware-xdsl-vectoring
  MENU:=1
endef

define Package/$(PKG_NAME)/description
	VRX300 CPE xDSL firmware
endef

define Build/Configure
	# remove "configured" stamps of other configs
	@- rm $(PKG_BUILD_DIR)/.configured*
	$(call Build/Configure/Default)
endef

define Build/Clean
	@- rm -Rf $(PKG_BUILD_DIR)/ipkg*
	@- [ -e $(PKG_BUILD_DIR)/Makefile ] && $(MAKE) -C $(PKG_BUILD_DIR) clean
	$(call Build/Clean/Default)
endef

define Build/Compile
endef

define Package/$(PKG_NAME)/install
	$(INSTALL_DIR) $(1)/$(FIRMWARE_DIR)

ifneq ($(CONFIG_UBOOT_CONFIG_FIRMWARE_IN_ROOTFS)$(CONFIG_dsl-cpe-control-vrx_DEVICE_VR10_320),)
	$(CP) $(PKG_BUILD_DIR)/*.bin $(1)/$(FIRMWARE_DIR)/$(PKG_BASE_NAME)-$(PKG_VERSION).bin
	$(CP) $(PKG_BUILD_DIR)/LICENSE $(1)/$(FIRMWARE_DIR)
	ln -sf $(PKG_BASE_NAME)-$(PKG_VERSION).bin $(1)/$(FIRMWARE_DIR)/$(PKG_TARGET_BASE_NAME)
else
	rm -rf $(STAGING_DIR)/firmware/; mkdir -p $(STAGING_DIR)/firmware/
	$(CP) $(PKG_BUILD_DIR)/*.bin $(STAGING_DIR)/firmware/$(PKG_BASE_NAME)-$(PKG_VERSION).bin
	$(CP) $(PKG_BUILD_DIR)/LICENSE $(STAGING_DIR)/firmware/
	ln -sf $(PKG_BASE_NAME)-$(PKG_VERSION).bin $(STAGING_DIR)/firmware/$(PKG_TARGET_BASE_NAME)
endif
endef

$(eval $(call BuildPackage,$(PKG_NAME)))

