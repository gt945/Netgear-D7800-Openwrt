# $Id$

include $(TOPDIR)/rules.mk

PKG_NAME:=forked-daapd
PKG_VERSION:=23.0
PKG_RELEASE:=20140216

PKG_FIXUP:=libtool
PKG_INSTALL:=1
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)

include $(INCLUDE_DIR)/package.mk

define Package/$(PKG_NAME)
SECTION:=sound
CATEGORY:=Sound
TITLE:=Improved iTunes (DAAP) server. Support for Apple Remote and AirPlay.
MAINTAINER:=Espen Jürgensen <espenjurgensen+openwrt@gmail.com>
URL:=https://github.com/jasonmc/forked-daapd
DEPENDS:=+libgpg-error +libgcrypt +libgdbm +zlib +libexpat +libunistring \
	+libevent2 +libdaemon +libantlr3c +confuse +glib2 +alsa-lib +libffmpeg-full \
	+mxml +libavl +avahi-daemon +libavahi-client +sqlite3-cli +libplist
MENU:=1
endef

define Build/Prepare
	$(CP) $(GIT_HOME)/forked-daapd.git/* $(PKG_BUILD_DIR)/
endef

$(eval $(call PKG/config/CommonModule,$(PKG_NAME)))

define Package/forked-daapd/conffiles
/etc/forked-daapd.conf
endef

# Fix for libevent
TARGET_CPPFLAGS += -I$(STAGING_DIR)/usr/include/libevent2
TARGET_CPPFLAGS += -DDNI_SUPPORT_LIBEVENT2
TARGET_LDFLAGS += -L$(STAGING_DIR)/usr/lib/libevent2

TARGET_CFLAGS += $(FPIC)
TARGET_LDFLAGS += -Wl,-rpath-link,$(STAGING_DIR)/usr/lib

define Build/Configure
	$(call Build/Configure/Default, \
		--enable-shared \
		--enable-static \
		--enable-itunes)
endef

define Package/$(PKG_NAME)/install
	$(INSTALL_DIR) $(1)/etc
	ln -sf /tmp/etc/forked-daapd.conf $(1)/etc/forked-daapd.conf
	$(INSTALL_DIR) $(1)/usr/lib
	$(INSTALL_DIR) $(1)/usr/lib/forked-daapd
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/forked-daapd/* $(1)//usr/lib/forked-daapd/
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) ./files/itunes_allow_control $(1)/usr/sbin/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/forked-daapd $(1)/usr/sbin/
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/forked-daapd.init $(1)/etc/init.d/forked-daapd
endef

$(eval $(call BuildPackage,$(PKG_NAME)))
