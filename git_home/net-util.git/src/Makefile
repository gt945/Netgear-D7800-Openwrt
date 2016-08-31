#
#	Copyright (C) 2007-2008 Delta Networks Inc.
#
include $(NET_UTIL_CONF)

CC = gcc

FILES = main.o ipconflict.o sched.o route.o detcable.o detwanv6.o

CFLAGS += -Wall -Wunused -g -O2
CFLAGS += -DWLAN_COMMON_SUUPPORT=$(WLAN_COMMON_SUUPPORT)
CFLAGS += -DRFC3442_249_SUPPORT=$(RFC3442_249_SUPPORT)
CFLAGS += -DDNI_WAN_DNS3_SUPPORT=$(DNI_WAN_DNS3_SUPPORT)
CFLAGS += -DDETWANV6

all : net-util

net-util : $(FILES)
	$(CC) $(CFLAGS) $(FILES) -o $@ $(EXTRA_LDFLAGS) $(LDFLAGS) -lconfig
	@echo "make $@ finished on `date`"

%.o : %.c
	$(CC) $(CFLAGS) -c $<

install:
	$(INSTALL_DIR) $(INS_BIN_DIR)

	$(INSTALL_BIN) net-util $(INS_BIN_DIR)
	$(LN) /sbin/net-util $(INS_BIN_DIR)/ipconflict
	$(LN) /sbin/net-util $(INS_BIN_DIR)/cmdsched
	$(LN) /sbin/net-util $(INS_BIN_DIR)/apsched
	$(LN) /sbin/net-util $(INS_BIN_DIR)/cmdsched_wlan_status
	$(LN) /sbin/net-util $(INS_BIN_DIR)/cmdroute
	$(LN) /sbin/net-util $(INS_BIN_DIR)/detwanv6
	$(LN) /sbin/net-util $(INS_BIN_DIR)/daemonv6
	$(LN) /sbin/net-util $(INS_BIN_DIR)/rs_send

clean:
	rm -f *.o 
	rm -f net-util
