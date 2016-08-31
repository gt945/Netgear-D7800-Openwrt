#
# Copyright (C) 2006 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
# $Id: Makefile 6565 2007-03-14 13:42:21Z nbd $

include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/kernel.mk

PKG_NAME:=kmod-dnshijack
PKG_RELEASE:=1

PKG_BUILD_DIR:=$(KERNEL_BUILD_DIR)/$(PKG_NAME)

include $(INCLUDE_DIR)/package.mk

define KernelPackage/dnshijack
  SUBMENU:=Other modules
  TITLE:=DNI DNS Hijack firewall module
  VERSION:=$(LINUX_VERSION)-$(BOARD)-$(PKG_RELEASE)
  FILES:= \
	$(PKG_BUILD_DIR)/ipt_dnshijack.$(LINUX_KMOD_SUFFIX)
  AUTOLOAD:=$(call AutoLoad,46,ipt_dnshijack)
  MENU:=1
endef

define Build/Prepare
	$(CP) ./src/* $(PKG_BUILD_DIR)/
endef

$(eval $(call PKG/config/CommonModule,$(PKG_NAME)))

define Build/Compile
endef

define KernelPackage/dnshijack/install
	$(INSTALL_DIR) $(1)/lib/network/
endef

$(eval $(call KernelPackage,dnshijack))
