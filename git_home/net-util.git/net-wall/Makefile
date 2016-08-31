export INSTALL_BIN=install -m0755
export INSTALL_DIR=install -m0755 -d
export INSTALL_CONF=install -m0600
export CP=cp -fpR
export LN=ln -sf

export INS_BIN_DIR:=$(PREFIX)/usr/sbin/
export INS_CONF_DIR:=$(PREFIX)/etc/
export INS_ADDON_DIR:=$(PREFIX)/etc/net-wall/

all %:
	$(MAKE) -C src $@
	$(MAKE) -C scripts $@
