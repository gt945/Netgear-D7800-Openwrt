#
# Copyright (C) DNI 2014
#
# Author: Iceway Zhang
# Date:   2014/11/27
#

binary:=ntgr_integration_api
links:=firewall nvconfig system internet api
firewall_rule:=ntgrapi.rule

files:=$(wildcard *.c)
objs:=$(patsubst %.c,%.o,$(files))

INSTALL_BIN:=install -m0755
INSTALL_DIR:=install -d -m0755
INSTALL_LINK:=ln -sf

INS_DIR_PRE:=
INS_DIR:=$(INS_DIR_PRE)/usr/sbin
FINAL_BIN:=$(INS_DIR)/$(binary)
LINK_BIN:=$(foreach var,$(links),$(INS_DIR)/$(var))
FW_RULE_DIR:=$(INS_DIR_PRE)/etc/scripts/firewall

override CFLAGS+=-Wunused -Wuninitialized -Wall

### MUST SPECIFY LIBCONFIG.SO PATH IN BUILDROOT PACKAGE MAKEFILE
### override LDFLAGS+=-lconfig -L<libconfig.so path>

.PHONY:all install clean
all:$(binary)

$(binary):$(objs)
	$(CC) -o $@ $^ $(LDFLAGS)

%o:%c
	$(CC) -o $@ -c $< $(CFLAGS)

install:$(INS_DIR) $(LINK_BIN) $(firewall_rule)

$(INS_DIR):
	$(INSTALL_DIR) $@

$(FINAL_BIN):$(binary)
	$(INSTALL_BIN) $(binary) $@

$(LINK_BIN):$(FINAL_BIN)
	$(INSTALL_LINK) $(notdir $(FINAL_BIN)) $@

$(FW_RULE_DIR):
	$(INSTALL_DIR) $@

$(firewall_rule):$(FW_RULE_DIR)
	$(INSTALL_BIN) $@ $(FW_RULE_DIR)/$@

clean:
	rm -rf $(LINK_BIN) $(FINAL_BIN) $(binary) *.o
