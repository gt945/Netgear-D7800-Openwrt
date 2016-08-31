## COMMON MODULE: uhttpd

uHTTPd is a tiny single threaded HTTP server with TLS, CGI and Lua support. It is intended as a drop-in replacement for the Busybox HTTP daemon.

### Use this module on your buildroot (openwrt):

1. get source code of this repository to your project's `PKG_BUILD_DIR` dir.
2. go to `PKG_BUILD_DIR` dir, and run ./configure with arguments to generate Makefile and uhttpd.sh
3. compile and install binary files to rootfs dir.

### Examples on common buildroot (openwrt):

**package/uhttpd/Makefile**

>    include $(TOPDIR)/rules.mk
>    
>    PKG_NAME:=uhttpd
>    PKG_RELEASE:=31
>    
>    config-$(CONFIG_PACKAGE_uhttpd-mod-tls)		+= --tls_support
>    config-$(CONFIG_PACKAGE_uhttpd-mod-tls_cyassl)	+= --tls_source cyassl
>    config-$(CONFIG_PACKAGE_uhttpd-mod-tls_openssl)	+= --tls_source openssl
>    config-$(CONFIG_PACKAGE_uhttpd-mod-lua)		+= --lua_support
>    
>    PKG_BUILD_DIR := $(BUILD_DIR)/$(PKG_NAME)
>    PKG_CONFIG_DEPENDS := \
>    	CONFIG_PACKAGE_uhttpd-mod-tls \
>    	CONFIG_PACKAGE_uhttpd-mod-tls_cyassl \
>    	CONFIG_PACKAGE_uhttpd-mod-tls_openssl
>    
>    include $(INCLUDE_DIR)/package.mk
>    
>    WEB_PATH:=www
>    
>    define Package/$(PKG_NAME)/default
>      SECTION:=net
>      CATEGORY:=Network
>      TITLE:=uHTTPd - tiny, single threaded HTTP server
>      MAINTAINER:=Jo-Philipp Wich <xm@subsignal.org>
>    endef
>    
>    define Package/$(PKG_NAME)
>      $(Package/$(PKG_NAME)/default)
>      MENU:=1
>    endef
>    
>    define Package/$(PKG_NAME)/description
>     uHTTPd is a tiny single threaded HTTP server with TLS, CGI and Lua
>     support. It is intended as a drop-in replacement for the Busybox
>     HTTP daemon.
>    endef
>    
>    
>    define Package/uhttpd-mod-tls
>      $(Package/$(PKG_NAME)/default)
>      TITLE+= (TLS plugin)
>      DEPENDS:=$(PKG_NAME) +PACKAGE_uhttpd-mod-tls_cyassl:libcyassl +PACKAGE_uhttpd-mod-tls_openssl:libopenssl
>    endef
>    
>    define Package/uhttpd-mod-tls/description
>     The TLS plugin adds HTTPS support to uHTTPd.
>    endef
>    
>    define Package/uhttpd-mod-tls/config
>            choice
>                    depends on PACKAGE_uhttpd-mod-tls
>                    prompt "TLS Provider"
>                    default PACKAGE_uhttpd-mod-tls_cyassl
>    
>                    config PACKAGE_uhttpd-mod-tls_cyassl
>                            bool "CyaSSL"
>    
>                    config PACKAGE_uhttpd-mod-tls_openssl
>                            bool "OpenSSL"
>            endchoice
>    endef
>    
>    define Package/uhttpd-mod-lua
>      $(Package/$(PKG_NAME)/default)
>      TITLE+= (Lua plugin)
>      DEPENDS:=$(PKG_NAME) +liblua
>    endef
>    
>    define Package/uhttpd-mod-lua/description
>     The Lua plugin adds a CGI-like Lua runtime interface to uHTTPd.
>    endef
>    
>    define Build/Prepare
>    	$(call Build/Get/CommonModule,CONFIG_$(PKG_NAME)_GIT_REPO,CONFIG_$(PKG_NAME)_GIT_TREEISH)
>    	$(call Build/Patch/Default)
>    endef
>    
>    $(eval $(call PKG/config/CommonModule,$(PKG_NAME)))
>    
>    define Package/$(PKG_NAME)/conffiles
>    /etc/config/uhttpd
>    endef
>    
>    define Build/Configure
>    	(cd $(PKG_BUILD_DIR); \
>    		./configure $(config-y) \
>    	)
>    endef
>    
>    define Package/$(PKG_NAME)/install
>    	$(MAKE) -C $(PKG_BUILD_DIR) install INS_DIR_PRE=$(1)
>    endef
>    
>    $(eval $(call BuildPackage,$(PKG_NAME)))
>    $(eval $(call BuildPackage,uhttpd-mod-tls))
>    $(eval $(call BuildPackage,uhttpd-mod-lua))

### Examples on old buildroot:

**package/uhttpd/Makefile**

>    include $(TOPDIR)/rules.mk
>    
>    PKG_NAME:=uhttpd
>    PKG_RELEASE:=31
>    
>    config-$(CONFIG_PACKAGE_uhttpd-mod-tls)		+= --tls_support
>    config-$(CONFIG_PACKAGE_uhttpd-mod-tls_cyassl)	+= --tls_source cyassl
>    config-$(CONFIG_PACKAGE_uhttpd-mod-tls_openssl)	+= --tls_source openssl
>    config-$(CONFIG_PACKAGE_uhttpd-mod-lua)		+= --lua_support
>    
>    PKG_BUILD_DIR := $(BUILD_DIR)/$(PKG_NAME)
>    PKG_CONFIG_DEPENDS := \
>    	CONFIG_PACKAGE_uhttpd-mod-tls \
>    	CONFIG_PACKAGE_uhttpd-mod-tls_cyassl \
>    	CONFIG_PACKAGE_uhttpd-mod-tls_openssl
>    
>    include $(INCLUDE_DIR)/package.mk
>    
>    WEB_PATH:=www
>    PKG_GIT_TREEISH:=HEAD
>    define Package/uhttpd/default
>      SECTION:=net
>      CATEGORY:=Network
>      TITLE:=uHTTPd - tiny, single threaded HTTP server
>      MAINTAINER:=Jo-Philipp Wich <xm@subsignal.org>
>    endef
>    
>    define Package/uhttpd
>      $(Package/uhttpd/default)
>      MENU:=1
>    endef
>    
>    define Package/uhttpd/description
>     uHTTPd is a tiny single threaded HTTP server with TLS, CGI and Lua
>     support. It is intended as a drop-in replacement for the Busybox
>     HTTP daemon.
>    endef
>    
>    
>    define Package/uhttpd-mod-tls
>      $(Package/uhttpd/default)
>      TITLE+= (TLS plugin)
>      DEPENDS:=uhttpd +PACKAGE_uhttpd-mod-tls_cyassl:libcyassl +PACKAGE_uhttpd-mod-tls_openssl:libopenssl
>    endef
>    
>    define Package/uhttpd-mod-tls/description
>     The TLS plugin adds HTTPS support to uHTTPd.
>    endef
>    
>    define Package/uhttpd-mod-tls/config
>            choice
>                    depends on PACKAGE_uhttpd-mod-tls
>                    prompt "TLS Provider"
>                    default PACKAGE_uhttpd-mod-tls_cyassl
>    
>                    config PACKAGE_uhttpd-mod-tls_cyassl
>                            bool "CyaSSL"
>    
>                    config PACKAGE_uhttpd-mod-tls_openssl
>                            bool "OpenSSL"
>            endchoice
>    endef
>    
>    define Package/uhttpd-mod-lua
>      $(Package/uhttpd/default)
>      TITLE+= (Lua plugin)
>      DEPENDS:=uhttpd +liblua
>    endef
>    
>    define Package/uhttpd-mod-lua/description
>     The Lua plugin adds a CGI-like Lua runtime interface to uHTTPd.
>    endef
>    
>    define Build/Prepare
>    	test x$(GIT_HOME) != x
>    	@ echo "plz git clone ssh://xxx@dniserver/scm/dnigit/common/apps/uhttpd.git uhttpd.git"
>    	test -d $(GIT_HOME)/uhttpd.git
>    	(cd $(GIT_HOME)/uhttpd.git; git-cat-file -e $(PKG_GIT_TREEISH))
>    	(cd $(BUILD_DIR); git-archive --format=tar --prefix=$(PKG_NAME)/ --remote=$(GIT_HOME)/uhttpd.git $(PKG_GIT_TREEISH) | tar -xvf -)
>    	$(call Build/Patch/Default)
>    endef
>    
>    define Package/uhttpd/conffiles
>    /etc/config/uhttpd
>    endef
>    
>    define Build/Configure
>    	(cd $(PKG_BUILD_DIR); \
>    		./configure $(config-y) \
>    	)
>    endef
>    
>    define Package/uhttpd/install
>    	$(MAKE) -C $(PKG_BUILD_DIR) install INS_DIR_PRE=$(1)
>    endef
>    
>    $(eval $(call BuildPackage,uhttpd))
>    $(eval $(call BuildPackage,uhttpd-mod-tls))
>    $(eval $(call BuildPackage,uhttpd-mod-lua))
