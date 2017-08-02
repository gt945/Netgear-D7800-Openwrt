# GENERATED AUTOMATICALLY BY configure, DON'T EDIT THIS FILE MANUALLY.

##############################################
# net-cgi, DNI processor for web requesting. #
#             Copyright (c) 2015             #
##############################################

export INSTALL_DIR:=install -d -m0755
export INSTALL_BIN:=install -m0755
export INSTALL_DATA:=install -m0644
export INSTALL_CONF:=install -m0600
export LN:=ln -sf
export CP:=cp -fpR
export TOUCH:=touch

export WWW_OUT_DIR:=${CURDIR}/www.out

export INS_DIR_PRE:=
export INS_BIN_DIR:=$(INS_DIR_PRE)/usr/sbin
export INS_WWW_DIR:=$(INS_DIR_PRE)/www

export NETCGI_CONF:=${CURDIR}/files/net-cgi.config

export NEW_SOURCE:=yes

SOURCE_DIR:="src.new"
FILES_DIR:="files"
SCRIPT_DIR:="scripts"
WWW_DIR:="www"

all %::
	$(MAKE) -C $(SOURCE_DIR) $@
	$(MAKE) -C $(WWW_DIR) $@
	$(MAKE) -C $(SCRIPT_DIR) $@
	$(MAKE) -C $(FILES_DIR) $@
