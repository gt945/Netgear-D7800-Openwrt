# 
# Copyright (C) 2014 Delta Networks Inc.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=ready-genie-cloud
PKG_RELEASE:=1

PKG_BUILD_DIR := $(BUILD_DIR)/$(PKG_NAME)

include $(INCLUDE_DIR)/package.mk

define Package/ready-genie-cloud
  CATEGORY:=Bigfoot
  TITLE:=ready-genie-cloud
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
	$(CP) -r ./tar $(PKG_BUILD_DIR)/
	echo "all:" > $(PKG_BUILD_DIR)/Makefile
endef

define Package/ready-genie-cloud/install
	install -d -m0755 $(1)/lib
	$(CP) -r $(PKG_BUILD_DIR)/tar/* $(1)/lib/
endef

$(eval $(call BuildPackage,ready-genie-cloud))
