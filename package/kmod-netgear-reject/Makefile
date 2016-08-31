#
# Copyright (C) 2006 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
# $Id: Makefile 6565 2007-03-14 13:42:21Z nbd $

include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/kernel.mk

PKG_NAME:=kmod-netgear-reject
PKG_RELEASE:=1

PKG_BUILD_DIR:=$(KERNEL_BUILD_DIR)/$(PKG_NAME)

include $(INCLUDE_DIR)/package.mk

define KernelPackage/netgear-reject
  SUBMENU:=Other modules
  TITLE:=REJECT target module designed for Netgear
  VERSION:=$(LINUX_VERSION)-$(BOARD)-$(PKG_RELEASE)
  FILES:= \
	$(PKG_BUILD_DIR)/ipt_NETGEAR_REJECT.$(LINUX_KMOD_SUFFIX)
  AUTOLOAD:=$(call AutoLoad,45,ipt_NETGEAR_REJECT)
  MENU:=1
endef

define Build/Prepare
	$(CP) $(GIT_HOME)/kmod-netgear-reject.git/* $(PKG_BUILD_DIR)/
endef

$(eval $(call PKG/config/CommonModule,$(PKG_NAME)))

define Build/Compile
	$(MAKE) -C "$(LINUX_DIR)" \
		CROSS_COMPILE="$(TARGET_CROSS)" \
		ARCH="$(LINUX_KARCH)" \
		SUBDIRS="$(PKG_BUILD_DIR)" \
		EXTRA_CFLAGS="$(BUILDFLAGS)" \
		modules
endef

define KernelPackage/netgear-reject/install
	$(INSTALL_DIR) $(1)/lib/network/
endef

$(eval $(call KernelPackage,netgear-reject))
