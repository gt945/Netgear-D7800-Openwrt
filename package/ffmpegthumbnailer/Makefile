 #
# Copyright (C) 2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=ffmpegthumbnailer
PKG_VERSION:=2.1.1
PKG_RELEASE:=1
PKG_MAINTAINER:=Tao Guo <guotao945@gmail.com>
PKG_LICENSE:=GPL2

PKG_SOURCE:=$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/dirkvdb/$(PKG_NAME)/archive/
#PKG_MD5SUM:=c4e51a60a5a26987bdce59e45d674a9e

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/ffmpegthumbnailer
  SECTION:=multimedia
  CATEGORY:=Multimedia
  TITLE:=ffmpegthumbnailer
  URL:=https://github.com/dirkvdb/ffmpegthumbnailer
  DEPENDS:= +libffmpeg-full +libjpeg +libpng
endef

define Package/ffmpegthumbnailer/description
 Lightweight video thumbnailer that can be used by file managers.
endef

define Package/ffmpegthumbnailer/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/ffmpegthumbnailer $(1)/usr/bin
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libffmpegthumbnailer.so* $(1)/usr/lib/
        
endef

$(eval $(call BuildPackage,ffmpegthumbnailer))
