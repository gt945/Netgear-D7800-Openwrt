#
# Copyright (C) 2010-2012 Jo-Philipp Wich <xm@subsignal.org>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=uhttpd
PKG_RELEASE:=31

config-$(CONFIG_PACKAGE_uhttpd-mod-tls)		+= --tls_support
config-$(CONFIG_PACKAGE_uhttpd-mod-tls_cyassl)	+= --tls_source cyassl
config-$(CONFIG_PACKAGE_uhttpd-mod-tls_openssl)	+= --tls_source openssl
config-$(CONFIG_PACKAGE_uhttpd-mod-lua)		+= --lua_support

PKG_BUILD_DIR := $(BUILD_DIR)/$(PKG_NAME)
PKG_CONFIG_DEPENDS := \
	CONFIG_PACKAGE_uhttpd-mod-tls \
	CONFIG_PACKAGE_uhttpd-mod-tls_cyassl \
	CONFIG_PACKAGE_uhttpd-mod-tls_openssl

include $(INCLUDE_DIR)/package.mk

WEB_PATH:=www

define Package/$(PKG_NAME)/default
  SECTION:=net
  CATEGORY:=Network
  TITLE:=uHTTPd - tiny, single threaded HTTP server
  MAINTAINER:=Jo-Philipp Wich <xm@subsignal.org>
endef

define Package/$(PKG_NAME)
  $(Package/$(PKG_NAME)/default)
  MENU:=1
endef

define Package/$(PKG_NAME)/description
 uHTTPd is a tiny single threaded HTTP server with TLS, CGI and Lua
 support. It is intended as a drop-in replacement for the Busybox
 HTTP daemon.
endef


define Package/uhttpd-mod-tls
  $(Package/$(PKG_NAME)/default)
  TITLE+= (TLS plugin)
  DEPENDS:=$(PKG_NAME) +PACKAGE_uhttpd-mod-tls_cyassl:libcyassl +PACKAGE_uhttpd-mod-tls_openssl:libopenssl
endef

define Package/uhttpd-mod-tls/description
 The TLS plugin adds HTTPS support to uHTTPd.
endef

define Package/uhttpd-mod-tls/config
        choice
                depends on PACKAGE_uhttpd-mod-tls
                prompt "TLS Provider"
                default PACKAGE_uhttpd-mod-tls_cyassl

                config PACKAGE_uhttpd-mod-tls_cyassl
                        bool "CyaSSL"

                config PACKAGE_uhttpd-mod-tls_openssl
                        bool "OpenSSL"
        endchoice
endef

define Package/uhttpd-mod-lua
  $(Package/$(PKG_NAME)/default)
  TITLE+= (Lua plugin)
  DEPENDS:=$(PKG_NAME) +liblua
endef

define Package/uhttpd-mod-lua/description
 The Lua plugin adds a CGI-like Lua runtime interface to uHTTPd.
endef

define Build/Prepare
	$(CP) $(GIT_HOME)/uhttpd.git/* $(PKG_BUILD_DIR)/
endef

$(eval $(call PKG/config/CommonModule,$(PKG_NAME)))

define Package/$(PKG_NAME)/conffiles
/etc/config/uhttpd
endef

define Build/Configure
	(cd $(PKG_BUILD_DIR); \
		./configure $(config-y) \
	)
endef

define Package/$(PKG_NAME)/install
	$(MAKE) -C $(PKG_BUILD_DIR) install INS_DIR_PRE=$(1)
endef

$(eval $(call BuildPackage,$(PKG_NAME)))
$(eval $(call BuildPackage,uhttpd-mod-tls))
$(eval $(call BuildPackage,uhttpd-mod-lua))
