#
#	Copyright (C) 2007-2008 Delta Networks Inc.
#

files=$(wildcard *.c)
bin=net-wall
bin6=net-wall6

CFLAGS+=-Wall -Wunused -g -O2

all : $(bin)

$(bin) : $(files:%.c=%.o)
	$(CC) $(CFLAGS) $(files) -o $@ $(EXTRA_LDFLAGS) $(LDFLAGS) -lconfig
	@echo "make $@ finished on `date`"

%.o : %.c
	$(CC) $(CFLAGS) -c $<

install:
	$(INSTALL_DIR) $(INS_BIN_DIR)
	$(INSTALL_BIN) $(bin) $(INS_BIN_DIR)
	cd $(INS_BIN_DIR) && $(LN) $(bin) $(bin6)

clean:
	rm -f *.o $(bin)
