# 
# Copyright (C) 2008 Delta Networks Inc.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=net-util
PKG_VERSION:=1
PKG_RELEASE:=1
PKG_BUILD_DEPENDS:=datalib
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)

include $(INCLUDE_DIR)/package.mk

define Package/$(PKG_NAME)
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=Tiny utils for configuring the Router.
  MENU:=1
endef

define Package/$(PKG_NAME)/description
	This package contains an utility for configuring Home Router.
endef

config-$(CONFIG_net-util_WLAN_COMMON) += "--with_wlan_common"
config-$(CONFIG_net-util_RFC3442_249) += "--with_rfc3442_249"
config-$(CONFIG_net-util_DNI_WAN_DNS3) += "--with_dni_wan_dns3"
config-$(CONFIG_net-util_DETWANV6) += "--with_detwanv6"

ccflags-$(CONFIG_wide-dhcpv6_KERNEL_NO_IN6_PKTINFO) += -DKERNEL_NO_IN6_PKTINFO
EXTRA_CFLAGS += $(ccflags-y)

define Build/Prepare
	$(CP) $(GIT_HOME)/net-util.git/* $(PKG_BUILD_DIR)/
endef

define Build/Compile
endef

define Build/Configure
	(cd $(PKG_BUILD_DIR) && \
		./configure $(config-y) \
	)
endef

$(eval $(call PKG/config/CommonModule,$(PKG_NAME)))

define Package/$(PKG_NAME)/install
	$(MAKE) -C $(PKG_BUILD_DIR) install INS_DIR_PRE=$(1)
endef

$(eval $(call BuildPackage,$(PKG_NAME)))
