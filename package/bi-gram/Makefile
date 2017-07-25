#
# Copyright (C) 2006-2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=bi-gram
PKG_VERSION:=1.0.1
PKG_RELEASE:=1

PKG_BUILD_DIR:=$(BUILD_DIR)/bi_gram
PKG_SOURCE:=bi_gram-src-1.0.1.tar.gz
PKG_SOURCE_URL:=https://sites.google.com/site/mysqlbigram/
PKG_MD5SUM:=f5d52e3abb245461307147ff5421cbde
PKG_MAINTAINER:=Tao Guo<guotao945@gmail.com>
PKG_LICENSE:=LGPL

PKG_FIXUP:=autoreconf

include $(INCLUDE_DIR)/package.mk

define Package/bi-gram
  SECTION:=libs
  CATEGORY:=Libraries
  DEPENDS:=+mysql-server
  TITLE:=Simple MySQL gram fulltext index parser plugin
  URL:=https://sites.google.com/site/mysqlbigram/
endef


define Package/bi-gram/description
 This package contains MySQL gram fulltext plugin
endef

TARGET_CFLAGS += $(FPIC)

TARGET_CPPFLAGS+=-I$(STAGING_DIR)/usr/include/mysql

define Build/Compile
	+$(MAKE) $(PKG_JOBS) -C $(PKG_BUILD_DIR) \
		DESTDIR="$(PKG_INSTALL_DIR)" \
		CC="$(TARGET_CC)" \
		install
endef

define Build/InstallDev
	mkdir -p $(1)/usr/lib/mysql
endef

define Package/bi-gram/install
	$(INSTALL_DIR) $(1)/usr/lib/mysql/plugin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/lib/mysql/bi_gramlib.so* $(1)/usr/lib/mysql/plugin
endef

$(eval $(call BuildPackage,bi-gram))
