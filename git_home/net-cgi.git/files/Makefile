include $(TOPRULE)
include $(NETCGI_CONF)

check_language=$(shell ./check_language.sh $(WWW_OUT_DIR))

.PHONY: all install clean
all:
ifeq ($(check_language),success)
	@echo "check language success"
else
	$(error language check fail, please see invalid/)
endif

	./create_soap_list.sh


install:
	$(INSTALL_BIN) wget_netgear $(INS_BIN_DIR)
ifeq ($(HAVE_USB_STORAGE),1)
	$(INSTALL_BIN) select_partition $(INS_BIN_DIR)
endif
	$(INSTALL_BIN) gen_netcgi_conf.sh $(INS_BIN_DIR)

clean:

