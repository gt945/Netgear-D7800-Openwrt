##############################################
# NET-CGI, DNI processor for web requesting. #
# Copy right (c) 2015                        #
##############################################

export TOPRULE=$(CURDIR)/toprule.mk

PKG_RELEASE:=net-cgi-dni221

include $(TOPRULE)

virtual_cgis:=apply.cgi func.cgi upgrade_check.cgi upgrade.cgi \
	backup.cgi brs_backup.cgi restore.cgi langupg.cgi \
	ubootupg.cgi unauth.cgi recover.cgi debug_cloud.cgi \
	debug.cgi green_upg.cgi bt_file.cgi mobile_install.cgi

.PHONY: all install clean
all:
#	$(INSTALL_DIR) $(WWW_OUT_DIR)

#	$(MAKE) -C $(SOURCE_DIR)
	$(MAKE) -C $(WWW_DIR)
#	$(MAKE) -C $(FILES_DIR)

	$(CP) $(SCRIPT_DIR)/* $(WWW_OUT_DIR)/cgi-bin
	$(TOUCH) $(foreach n,$(virtual_cgis),$(WWW_OUT_DIR)/$(n))

install:
	$(INSTALL_DIR)	$(INS_BIN_DIR)
	$(INSTALL_DIR)	$(INS_WWW_DIR)

	$(MAKE) -C $(SOURCE_DIR) $@
	$(MAKE) -C $(WWW_DIR) $@
	$(MAKE) -C $(FILES_DIR) $@

clean:
	$(MAKE) -C $(SOURCE_DIR) $@
	$(MAKE) -C $(WWW_DIR) $@
	$(MAKE) -C $(FILES_DIR) $@
