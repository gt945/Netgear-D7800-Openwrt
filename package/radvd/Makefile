#
# Copyright (C) 2006-2009 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=radvd
PKG_VERSION:=1.5
PKG_RELEASE:=1

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)

include $(INCLUDE_DIR)/package.mk

define Package/$(PKG_NAME)
  SECTION:=ipv6
  CATEGORY:=IPv6
  TITLE:=IPv6 Routing Advertisement Daemon
  URL:=http://v6web.litech.org/radvd/
  DEPENDS:=+kmod-ipv6
  MENU:=1
endef

define Package/$(PKG_NAME)/description
IPv6 Routing Advertisement Daemon.
endef

$(eval $(call PKG/config/CommonModule,$(PKG_NAME)))

define Build/Prepare
	$(CP) $(GIT_HOME)/radvd.git/* $(PKG_BUILD_DIR)/
	[ -e $(PKG_BUILD_DIR)/configure ] && chmod +x $(PKG_BUILD_DIR)/configure
endef

define Build/Configure
	$(call Build/Configure/Default,\
		--with-configfile=/etc/radvd.conf \
		--with-logfile=/var/log/radvd.log \
		--with-pidfile=/var/run/radvd.pid \
	)
endef

define Build/Compile
	$(MAKE) -C $(PKG_BUILD_DIR) \
		radvd_LDADD=""
	$(MAKE) -C $(PKG_BUILD_DIR) \
		DESTDIR="$(PKG_INSTALL_DIR)" \
		install
endef

define Package/$(PKG_NAME)/conffiles
/etc/config/radvd
endef

define Package/$(PKG_NAME)/install
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_DATA) ./files/radvd.config $(1)/etc/config/radvd
	$(INSTALL_DATA) ./files/radvd.conf $(1)/etc/
	#$(INSTALL_DIR) $(1)/etc/init.d
	#$(INSTALL_BIN) ./files/radvd.init $(1)/etc/init.d/radvd
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/radvd $(1)/usr/sbin/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/radvdump $(1)/usr/sbin/
endef

$(eval $(call BuildPackage,$(PKG_NAME)))
