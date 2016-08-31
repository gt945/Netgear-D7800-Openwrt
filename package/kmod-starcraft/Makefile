# 
# Copyright (C) 2006 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/kernel.mk

PKG_NAME:=kmod-dnistarcraft-alg
PKG_VERSION:=
PKG_RELEASE:=1

PKG_BUILD_DIR:=$(KERNEL_BUILD_DIR)/$(PKG_NAME)

include $(INCLUDE_DIR)/package.mk

define KernelPackage/dnistarcraft-alg
  SUBMENU:=Other modules
  TITLE:=Starcraft ALG linux kernel module
  VERSION:=$(LINUX_VERSION)-$(PKG_RELEASE)
  FILES:= \
	$(PKG_BUILD_DIR)/nf_nat_STARCRAFT.$(LINUX_KMOD_SUFFIX)
  AUTOLOAD:=$(call AutoLoad,45,nf_nat_STARCRAFT)
  MENU:=1
endef

define Build/Prepare
	$(CP) ./src/* $(PKG_BUILD_DIR)/
endef

$(eval $(call PKG/config/CommonModule,$(PKG_NAME)))

define Build/Compile
endef

$(eval $(call KernelPackage,dnistarcraft-alg))
