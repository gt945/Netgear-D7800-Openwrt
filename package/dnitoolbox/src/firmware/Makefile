bin:=firmware_update
scripts:=pre_action.sh do_action.sh post_action.sh

all:
	@echo "Compiled on $(shell date)"

#$(bin): firmware.c
#	$(CC) $< -o $@

install: $(bin) $(scripts)
	$(call install_bin,$(bin))
	$(INSTALL_DIR) $(INS_CONF_DIR)/firmware_update
	$(INSTALL_BIN) $(scripts) $(INS_CONF_DIR)/firmware_update

clean:
#	$(RM) $(bin)
	@echo "Cleaned on $(shell date)"
