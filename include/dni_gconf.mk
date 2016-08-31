
define DGC/ProductName
	eval sed -i 's/R7500v2/$(CONFIG_DGC_PRODUCT_NAME)/g' $(1)
	eval sed -i 's/r7500v2/$(CONFIG_DGC_product_name)/g' $(1)
endef

CONFIG_DGC_DNI_GLOBAL_CONFIG_FILE?="/dni-gconfig"

define DGC/GenConf
	echo '$(patsubst CONFIG_%,%,$(1))=$($(1))'
endef

define DGC/GenConfFile
	rm -f $(1)

	echo '# --- DNI Global Configs Definition --- #' >> $(1)
	echo 'if [ "x$$$${DGC_LOADED}" = "x" ]; then DGC_LOADED="loaded"' >> $(1)
	$(call DGC/GenConf,CONFIG_DGC_DNI_GLOBAL_CONFIG_FILE) >> $(1)
	$(call DGC/GenConf,CONFIG_DGC_PRODUCT_NAME) >> $(1)
	$(call DGC/GenConf,CONFIG_DGC_product_name) >> $(1)
	$(call DGC/GenConf,CONFIG_DGC_PRODUCT_CLASS) >> $(1)
	$(call DGC/GenConf,CONFIG_DGC_PRODUCT_class) >> $(1)
	$(call DGC/GenConf,CONFIG_DGC_PRODUCT_VERSION) >> $(1)
	$(call DGC/GenConf,CONFIG_DGC_MODULE_NAME) >> $(1)
	$(call DGC/GenConf,CONFIG_DGC_HW_VERSION) >> $(1)
	$(call DGC/GenConf,CONFIG_DGC_HW_ID) >> $(1)
	$(call DGC/GenConf,CONFIG_DGC_WAN_RAW_IF) >> $(1)
	$(call DGC/GenConf,CONFIG_DGC_WAN_ETH_IF) >> $(1)
	$(call DGC/GenConf,CONFIG_DGC_WAN_PPP_IF) >> $(1)
	$(call DGC/GenConf,CONFIG_DGC_WAN_BR_IF) >> $(1)
	$(call DGC/GenConf,CONFIG_DGC_LAN_RAW_IF) >> $(1)
	$(call DGC/GenConf,CONFIG_DGC_LAN_ETH_IF) >> $(1)
	$(call DGC/GenConf,CONFIG_DGC_LAN_BR_IF) >> $(1)
	$(call DGC/GenConf,CONFIG_DGC_FW_VERSION) >> $(1)
	$(call DGC/GenConf,CONFIG_DGC_LG_VERSION) >> $(1)
	$(call DGC/GenConf,CONFIG_DGC_FW_REGION) >> $(1)
	$(call DGC/GenConf,CONFIG_DGC_CLOUD_VERSION) >> $(1)
	$(call DGC/GenConf,CONFIG_DGC_WAN_IF_NONUSE_BRIDGE) >> $(1)
	$(call DGC/GenConf,CONFIG_DGC_VENDOR) >> $(1)
	$(call DGC/GenConf,CONFIG_DGC_DNI_CMD_DIR) >> $(1)
	$(call DGC/GenConf,CONFIG_DGC_MTD_POT) >> $(1)
	echo 'fi # --- avoid load dni global configs duplicated --- #' >> $(1)
endef

define DGC/GenDGCFile
	$(call DGC/GenConfFile,$(TARGET_DIR)/$(CONFIG_DGC_DNI_GLOBAL_CONFIG_FILE))
endef
