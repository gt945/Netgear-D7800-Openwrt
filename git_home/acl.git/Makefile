PREFIX?=/
SBIN_DIR?=$(PREFIX)/usr/sbin
INITD_DIR?=$(PREFIX)/etc/init.d

all %:
	$(MAKE) -C src $@

install:
	install -d $(SBIN_DIR) -d $(INITD_DIR)
	install -m 755 src/acld $(SBIN_DIR)
	install -m 755 src/acl_update_name $(SBIN_DIR)
	install -m 755 src/aclctl $(SBIN_DIR)
	install -m 755 src/aclhijackdns $(SBIN_DIR)
	install -m 755 files/acl $(INITD_DIR)
