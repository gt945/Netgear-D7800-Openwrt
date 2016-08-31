
.PHONY: all install clean
all:
ifeq ($(TLS_SUPPORT),1)
	$(shell ./generate_crt.sh)
endif

install:
	$(INSTALL_DIR) $(INS_ETC_DIR)
	$(INSTALL_CONF) uhttpd.key $(INS_ETC_DIR)
	$(INSTALL_CONF) uhttpd.crt $(INS_ETC_DIR)
	$(INSTALL_DIR) $(INS_CONF_DIR)
	$(INSTALL_CONF) uhttpd.config $(INS_CONF_DIR)/uhttpd
	$(INSTALL_DIR) $(INS_INIT_DIR)
	$(INSTALL_BIN) uhttpd.init $(INS_INIT_DIR)
	$(INSTALL_DIR) $(INS_WWW_DIR)
	$(INSTALL_BIN) uhttpd.sh $(INS_WWW_DIR)
	chmod a+x $(INS_WWW_DIR)/uhttpd.sh

clean: rm -rf uhttpd.key uhttpd.crt uhttpd.sh
