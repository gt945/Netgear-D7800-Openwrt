include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/kernel.mk

PKG_NAME:=ltq_qoscmd
PKG_VERSION:=2.3.7
PKG_RELEASE:=2

include $(INCLUDE_DIR)/package.mk

define Package/$(PKG_NAME)
	SECTION:=utils
	CATEGORY:=Lantiq
	TITLE:=Lantiq QoS configuration utility
	URL:=http://www.lantiq.com
	MAINTAINER:=Lantiq Technologies AG
	MENU:=1
endef

define Package/$(PKG_NAME)/description
	Lantiq QoS configuration utility named 'ltqqoscmd'
endef
export CONFIG_FEATURE_SESSION_LIMIT
define Build/Prepare
	$(call Build/Prepare/Default)
	ln -fs `pwd`/src/* $(PKG_BUILD_DIR)/
	echo PKG_BUILD_DIR=${PKG_BUILD_DIR}
endef

define Build/Compile
	CFLAGS="$(TARGET_CFLAGS) $(FPIC)" $(MAKE) -C "$(PKG_BUILD_DIR)" \
		KERNEL_INCLUDE_PATH="$(LINUX_DIR)/include" \
		CC="$(TARGET_CROSS)gcc"
endef

define Package/$(PKG_NAME)/install
	$(INSTALL_DIR) $(1)/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/ltqqoscmd $(1)/sbin
endef

define Build/Clean
	if [ -d $(PKG_BUILD_DIR) ]; then $(MAKE) -C $(PKG_BUILD_DIR) clean; \
	$(RM) -r $(PKG_BUILD_DIR)/ipkg-$(BOARD); fi
endef

$(eval $(call BuildPackage,$(PKG_NAME)))
