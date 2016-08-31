all:
	@echo "compiled on $(shell date)"

addon=net-wall_addon.sh

install:
	$(INSTALL_DIR) $(INS_ADDON_DIR)
	$(INSTALL_DIR) $(INS_ADDON_DIR)/scripts
	$(INSTALL_BIN) $(addon) $(INS_ADDON_DIR)
	cd $(INS_ADDON_DIR) && $(LN) $(addon) addon_start.sh
	cd $(INS_ADDON_DIR) && $(LN) $(addon) addon_stop.sh
	$(INSTALL_DIR) $(INS_CONF_DIR)
	$(INSTALL_CONF) l7_patten.dat $(INS_CONF_DIR)

clean:
	@echo "cleaned on $(shell date)"
