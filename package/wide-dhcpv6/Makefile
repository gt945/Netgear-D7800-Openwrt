
include $(TOPDIR)/rules.mk

PKG_NAME:=wide-dhcpv6
PKG_VERSION:=20080615
PKG_RELEASE:=2

ccflags-$(CONFIG_wide-dhcpv6_KERNEL_NO_IN6_PKTINFO) += -DKERNEL_NO_IN6_PKTINFO
ccflags-$(CONFIG_wide-dhcpv6_NETGEAR_getifaddrs) += -DNETGEAR_getifaddrs
ccflags-$(CONFIG_wide-dhcpv6_NETGEAR_lease_phase) += -DNETGEAR_lease_phase
ccflags-$(CONFIG_wide-dhcpv6_NETGEAR_reconfig) += -DNETGEAR_reconfig
ccflags-$(CONFIG_wide-dhcpv6_NETGEAR_user_class) += -DNETGEAR_user_class
ccflags-$(CONFIG_wide-dhcpv6_NETGEAR_select_server) += -DNETGEAR_select_server
ccflags-$(CONFIG_wide-dhcpv6_NETGEAR_dhcp6c_gw) += -DNETGEAR_dhcp6c_gw
ccflags-$(CONFIG_wide-dhcpv6_NETGEAR_dhcp6c_dad) += -DNETGEAR_dhcp6c_dad
ccflags-$(CONFIG_wide-dhcpv6_NETGEAR_dhcp6s_iata) += -DNETGEAR_dhcp6s_iata
ccflags-$(CONFIG_wide-dhcpv6_NETGEAR_script) += -DNETGEAR_script
ccflags-$(CONFIG_wide-dhcpv6_NETGEAR_dhcp6c_inforeq) += -DNETGEAR_dhcp6c_inforeq

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)

include $(INCLUDE_DIR)/package.mk

EXTRA_CFLAGS += $(ccflags-y) -I./missing
CONFIGURE_ARGS += --sysconfdir=/etc --with-localdbdir=/tmp

define Package/$(PKG_NAME)
  SECTION:=ipv6
  CATEGORY:=IPv6
  TITLE:=WIDE-DHCPv6
  DEPENDS:=+kmod-ipv6
  URL:=https://sourceforge.net/projects/wide-dhcpv6/
  MENU:=1
endef

define Package/wide-dhcpv6/Default
  SECTION:=ipv6
  CATEGORY:=IPv6
  TITLE:=WIDE-DHCPv6
  DEPENDS:=+kmod-ipv6 wide-dhcpv6
  URL:=https://sourceforge.net/projects/wide-dhcpv6/
endef

define Package/wide-dhcpv6-client
  $(call Package/wide-dhcpv6/Default)
  TITLE+= client
endef

define Package/wide-dhcpv6-client/description
	WIDE-DHCPv6 is an open-source implementation of Dynamic Host Configuration Protocol
	for IPv6 (DHCPv6) originally developed by the KAME project. The implementation
	mainly conforms to the following standards: RFC3315,3319,3633,3646,4075,4272,etc.

	This package installs the client component.
endef

define Package/wide-dhcpv6-server
  $(call Package/wide-dhcpv6/Default)
  TITLE+= server
endef

define Package/wide-dhcpv6-server/description
	WIDE-DHCPv6 is an open-source implementation of Dynamic Host Configuration Protocol
	for IPv6 (DHCPv6) originally developed by the KAME project. The implementation
	mainly conforms to the following standards: RFC3315,3319,3633,3646,4075,4272,etc.

	This package installs the server component.
endef

define Package/wide-dhcpv6-relay
  $(call Package/wide-dhcpv6/Default)
  TITLE+= relay
endef

define Package/wide-dhcpv6-relay/description
	WIDE-DHCPv6 is an open-source implementation of Dynamic Host Configuration Protocol
	for IPv6 (DHCPv6) originally developed by the KAME project. The implementation
	mainly conforms to the following standards: RFC3315,3319,3633,3646,4075,4272,etc.

	This package installs the relay component.
endef

define Package/wide-dhcpv6-control
  $(call Package/wide-dhcpv6/Default)
  TITLE+= client and server control utility
endef

define Package/wide-dhcpv6-control/description
	WIDE-DHCPv6 is an open-source implementation of Dynamic Host Configuration Protocol
	for IPv6 (DHCPv6) originally developed by the KAME project. The implementation
	mainly conforms to the following standards: RFC3315,3319,3633,3646,4075,4272,etc.

	This package installs the client and server control utility.
endef

$(eval $(call PKG/config/CommonModule,$(PKG_NAME)))

define Build/Prepare
	$(CP) $(GIT_HOME)/wide-dhcpv6.git/* $(PKG_BUILD_DIR)/
endef

#define Build/Configure
#	$(call Build/Configure/Default,--with-localdbdir=/tmp)
#endef

#define Build/Compile
#	$(MAKE) -C $(PKG_BUILD_DIR) \
#		DESTDIR="$(PKG_INSTALL_DIR)" \
#		all
#endef

define Package/wide-dhcpv6-client/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_DIR) $(1)/etc
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/dhcp6c $(1)/usr/sbin/
	$(INSTALL_BIN) ./files/dhcp6c.conf $(1)/etc/
	$(INSTALL_BIN) ./files/wide-script $(1)/etc/
endef

define Package/wide-dhcpv6-server/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_DIR) $(1)/etc
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/dhcp6s $(1)/usr/sbin/
endef

define Package/wide-dhcpv6-relay/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/dhcp6relay $(1)/usr/sbin/
endef

define Package/wide-dhcpv6-control/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_DIR) $(1)/etc
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/dhcp6ctl $(1)/usr/sbin
	$(INSTALL_BIN) ./files/dhcp6cctlkey $(1)/etc/
	$(INSTALL_BIN) ./files/dhcp6sctlkey $(1)/etc/
endef

$(eval $(call BuildPackage,$(PKG_NAME)))
$(eval $(call BuildPackage,wide-dhcpv6-client))
$(eval $(call BuildPackage,wide-dhcpv6-server))
$(eval $(call BuildPackage,wide-dhcpv6-relay))
$(eval $(call BuildPackage,wide-dhcpv6-control))
