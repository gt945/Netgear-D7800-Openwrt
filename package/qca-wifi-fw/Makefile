

# Copyright (c) 2014 Qualcomm Atheros, Inc..
#
# All Rights Reserved.
# Qualcomm Atheros Confidential and Proprietary.
#

include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/kernel.mk

PKG_NAME:=qca-wifi-fw
PKG_VERSION:=CNSS.BL.1.0-00453-S-1.25363.2
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)$(BUILD_VARIANT)-$(PKG_VERSION).tar.bz2
PKG_SOURCE_URL:=http://tritium.qca.qualcomm.com/software/NBU/CNSS.BL.1.0-TIP/$(PKG_VERSION)/src
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)
include $(INCLUDE_DIR)/package-version-override.mk
include $(INCLUDE_DIR)/package.mk

PKG_BUILD_DEPENDS:=

define WifiFirmware
  define Package/$(PKG_NAME)$(1)
    SECTION:=QCA
    CATEGORY:=QCA Proprietary software
    URL:=http://www.qca.qualcomm.com
    MAINTAINER:=Qualcomm Atheros
    TITLE:=QCA Wifi Firmware$(1)
    VARIANT:=$(2)
    PKGARCH:=all
  endef

  define Package/$(PKG_NAME)$(1)/description
    This package contains the qca-wifi firmware($(1)) used in 10.x drivers
  endef

  define Package/$(PKG_NAME)$(1)/config
  $(call Package/$(PKG_NAME)/override_source_path,$(PKG_NAME)$(1))
  $(call Package/$(PKG_NAME)/override_version,$(PKG_NAME)$(1),$(PKG_SUPPORTED_VERSION))
  endef

  define Package/$(PKG_NAME)$(1)/install
	$(INSTALL_DIR) $$(1)/lib/firmware/$(3)
	$(HOST_TAR) jxvf $(DL_DIR)/$(PKG_SOURCE) -C $$(1)/lib/firmware/$(3) --strip-components=1
	$(INSTALL_BIN) ./files/boarddata_0.bin $$(1)/lib/firmware/$(3)
	$(INSTALL_BIN) ./files/boarddata_1.bin $$(1)/lib/firmware/$(3)
	$(INSTALL_BIN) ./files/boardData_AR900B_CUS239_5G_v2_001.bin $$(1)/lib/firmware/$(3)
	$(INSTALL_BIN) ./files/boardData_AR900B_CUS260_2G_v2_002.bin $$(1)/lib/firmware/$(3)
	$(INSTALL_BIN) ./files/boardData_AR900B_CUS239_5G_v2_MAX_001.bin $$(1)/lib/firmware/$(3)
	$(INSTALL_BIN) ./files/boardData_AR900B_CUS260_2G_v2_MAX_002.bin $$(1)/lib/firmware/$(3)
	$(INSTALL_BIN) ./files/boardData_AR900B_CUS239_5G_v2_CE_001.bin $$(1)/lib/firmware/$(3)
	$(INSTALL_BIN) ./files/boardData_AR900B_CUS239_5G_v2_NEW_FCC_001.bin $$(1)/lib/firmware/$(3)
  endef

  $$(eval $$(call BuildPackage,$(PKG_NAME)$(1)))
endef

Build/Prepare=true
Build/Compile=true

$(eval $(call WifiFirmware,-asic,-AR900B_hw_2,AR900B/hw.2))
$(eval $(call WifiFirmware,-emu_m2m,-AR900B_fpga_2_M2M,AR900B/fpga.2/M2M))
$(eval $(call WifiFirmware,-emu_bb,-AR900B_fpga_2_BB,AR900B/fpga.2/BB))
