#
# Copyright (C) 2006 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/kernel.mk

PKG_NAME:=kmod-spiadvdos
PKG_RELEASE:=1

PKG_BUILD_DIR:=$(KERNEL_BUILD_DIR)/$(PKG_NAME)

include $(INCLUDE_DIR)/package.mk

define KernelPackage/spiadvdos
  SUBMENU:=Other modules
  TITLE:=DNI Advanced SPI DOS firewall module
  VERSION:=$(LINUX_VERSION)-$(BOARD)-$(PKG_RELEASE)
  FILES:= \
	$(PKG_BUILD_DIR)/ipt_spiadvDoS.$(LINUX_KMOD_SUFFIX)
  AUTOLOAD:=$(call AutoLoad,46,ipt_spiadvDoS)
  MENU:=1
endef

define Build/Prepare
	$(CP) ./src/* $(PKG_BUILD_DIR)/
endef

$(eval $(call PKG/config/CommonModule,$(PKG_NAME)))

define Build/Compile
endef

define KernelPackage/spiadvdos/install
	$(INSTALL_DIR) $(1)/lib/network/
endef

$(eval $(call KernelPackage,spiadvdos))
