#
#	Copyright (C) 2007 Delta Networks Inc.
#

CC = gcc

PREFIX?=/
BIN_DIR?=$(PREFIX)/usr/sbin

FILES = main.o arp.o bios.o dni_system.o appconfig.o
FILES2 = devscan.o bios.o
CFLAGS += -Wall -Wunused -g -O2
ifeq ($(SUPPORT_STREAMBOOST), 1)
CFLAGS += -DSUPPORT_STREAMBOOST=$(SUPPORT_STREAMBOOST)
LLIB += -lconfig
endif

all : net-scan dev-scan

net-scan : $(FILES)
	$(CC) $(CFLAGS) $(FILES) $(LLIB) -o $@
	@echo "make $@ finished on `date`"

dev-scan : $(FILES2)
	$(CC) $(CFLAGS) $(FILES2) -o $@
	@echo "make $@ finished on `date`"

%.o : %.c
	$(CC) $(CFLAGS) -c $<

install: all
	install -d $(BIN_DIR) -d $(LIB_DIR)
	install -m 755 ./net-scan $(BIN_DIR)
	install -m 755 ./dev-scan $(BIN_DIR)

clean:
	rm -f *.o
	rm -f net-scan dev-scan
