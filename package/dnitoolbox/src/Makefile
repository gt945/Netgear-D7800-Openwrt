export INSTALL_BIN=install -m0755
export INSTALL_DIR=install -m0755 -d
export INSTALL_CONF=install -m0600
export CP=cp -fpR
export LN=ln -sf
export RM=rm -rf

export INS_BIN_DIR:=$(PREFIX)/usr/sbin/
export INS_CONF_DIR:=$(PREFIX)/usr/etc/

export install_bin=$(INSTALL_BIN) $$(1) $(INS_BIN_DIR)
export install_conf=$(INSTALL_CONF) $$(1) $(INS_CONF_DIR)
export install_dir=$(INSTALL_DIR) $$(1)

define submake
	$(MAKE) -C partition $(1)
	$(MAKE) -C firmware $(1)
endef

.PHONE: all install clean
all:
	$(call submake,$@)

install:
	$(INSTALL_DIR) $(INS_BIN_DIR)
	$(INSTALL_DIR) $(INS_CONF_DIR)
	$(call submake,$@)

clean:
	$(call submake,$@)
