#
# Copyright (C) 2013 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/kernel.mk

PKG_NAME:=ltq_vrx320_datapath_drv
PKG_VERSION:=1.0.0
PKG_RELEASE:=1

include $(INCLUDE_DIR)/package.mk

define Package/$(PKG_NAME)
  SECTION:=driver
  CATEGORY:=Lantiq
  TITLE:=VRX320 DSL Datapath drivers and utils
  URL:=http://www.lantiq.com/
  MAINTAINER:=Lantiq Deutschland GmbH
  DEPENDS:=+kmod-qca-nss-drv
  MENU:=1
endef

define Package/$(PKG_NAME)/description
   This package contains the Lantiq VRX320 DSL Datapath drivers, test modules and scripts.
   Supported Devices:
	- Lantiq xRX300/330 Family
	- QCA ipq806x DB149
endef

define Package/$(PKG_NAME)/config
	config VRX320_DEBUG
		bool "VRX320 Debug mode"
		depends PACKAGE_$(PKG_NAME)
		default n

	config VRX320_PTM_QCA_NSS_REDIRECT
		bool "NSS Redirect support for VRX320 PTM"
		depends PACKAGE_$(PKG_NAME)
		default y

	config VRX320_PTM_VECTORING
		bool "VRX320 PTM Vectoring Support"
		depends PACKAGE_$(PKG_NAME)
		default y
endef

define KernelPackage/lantiq-vrx320-pcie-test
  SUBMENU:=Lantiq
  TITLE:=Lantiq VRX320 pcie test driver
  URL:=http://www.lantiq.com/
  MAINTAINER:=Lantiq Deutschland GmbH
  KCONFIG:= \
	CONFIG_LANTIQ_VRX320_TEST=m
  FILES:=$(LINUX_DIR)/drivers/net/ethernet/lantiq/lantiq_pcie_ep_vrx320_test.ko
endef

export CONFIG_VRX320_PTM_QCA_NSS_REDIRECT CONFIG_VRX320_DEBUG

define Build/Prepare
	$(call Build/Prepare/Default)
	$(if $(CONFIG_$(PKG_NAME)_USE_CUSTOM_SOURCE_DIR),,$(CP) -L ./src/* $(PKG_BUILD_DIR)/)
endef

define Build/Compile
	$(MAKE) ARCH=$(LINUX_KARCH) $(TARGET_CONFIGURE_OPTS) -C $(LINUX_DIR) M=$(PKG_BUILD_DIR)/ modules
endef

define Build/Clean
	$(MAKE) ARCH=$(LINUX_KARCH) $(TARGET_CONFIGURE_OPTS) -C $(LINUX_DIR) M=$(PKG_BUILD_DIR)/ clean
	@- rm -Rf $(PKG_BUILD_DIR)/ipkg*
	$(call Build/Clean/Default)
endef

define Package/$(PKG_NAME)/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_DIR) $(1)/lib/cfgmgr
	#$(INSTALL_DIR) $(1)/etc/ppp/peers
	$(INSTALL_DIR) $(1)/lib/modules/$(LINUX_VERSION)
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/lantiq_vrx320_e1.ko $(1)/lib/modules/$(LINUX_VERSION)/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/lantiq_vrx320_a1.ko $(1)/lib/modules/$(LINUX_VERSION)/
	$(if $(CONFIG_VRX320_PTM_VECTORING), \
		$(INSTALL_BIN) $(PKG_BUILD_DIR)/vectoring/lantiq_vrx320_vectoring.ko $(1)/lib/modules/$(LINUX_VERSION)/; \
		$(INSTALL_BIN) $(PKG_BUILD_DIR)/vectoring/lantiq_vrx320_vectoring_test.ko $(1)/lib/modules/$(LINUX_VERSION)/ \
	)
	$(INSTALL_BIN) ./files/lantiq_vrx320_init.sh $(1)/etc/init.d/
	$(INSTALL_BIN) ./files/lantiq_dsl_wan_connect.sh $(1)/etc/init.d/
	$(INSTALL_BIN) ./files/lantiq_dsl_wan.sh $(1)/usr/sbin/
	ln -sf ./lantiq_dsl_wan.sh $(1)/usr/sbin/lantiq_dsl_wan2.sh
	$(INSTALL_BIN) ./files/dni_dsl_init $(1)/etc/init.d/
	$(INSTALL_BIN) ./files/dni_dsl_net_wan.sh $(1)/usr/sbin/
	$(INSTALL_BIN) ./files/dni_adsl_scan.sh $(1)/usr/sbin/
	$(INSTALL_BIN) ./files/dni_vdsl_eth_scan.sh $(1)/usr/sbin/
	$(INSTALL_BIN) ./files/dni_scan_isp_info.sh $(1)/usr/sbin/
	$(INSTALL_BIN) ./files/dni_dsl_debug_advanced.sh $(1)/usr/sbin/
	$(INSTALL_BIN) ./files/dni_dsl_log_upload.sh $(1)/usr/sbin
	$(INSTALL_BIN) ./files/dsl_prepare.sh $(1)/lib/cfgmgr/
	$(INSTALL_BIN) ./files/dsl.sh $(1)/usr/sbin
	$(INSTALL_BIN) ./files/dsl_time.sh $(1)/usr/sbin
	$(INSTALL_BIN) ./files/dsl_log_zip.sh $(1)/usr/sbin
	$(INSTALL_BIN) ./files/xdslrc.sh $(1)/etc/init.d/
	$(INSTALL_BIN) ./files/dni_dsl_lsg_vig_g997xtusecg.sh $(1)/usr/sbin
	#$(INSTALL_BIN) ./files/ip-up $(1)/etc/ppp/
	ln -sf /tmp/etc/lantiq_dsl_wan.conf $(1)/etc/lantiq_dsl_wan.conf
	ln -sf /tmp/etc/lantiq_dsl_wan2.conf $(1)/etc/lantiq_dsl_wan2.conf
endef

$(eval $(call BuildPackage,$(PKG_NAME)))
$(eval $(call KernelPackage,lantiq-vrx320-pcie-test))
