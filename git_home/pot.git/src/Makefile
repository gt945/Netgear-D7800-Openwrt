#
#	Copyright (C) 2012 Delta Networks Inc.
#
include $(POT_CONF)

CC = gcc

FILES = pot.c excmd.c common.h config.h
TARGET = i_potd i_potval i_ntpst i_stamac
OUT_TARGETS = potd potval ntpst stamac

CFLAGS += -Wall -Wunused -g
CFLAGS += -DPOT_MTD=$(POT_MTD)

all : $(TARGET)

i_potd : $(FILES)
	$(CC) $(CFLAGS) $(FILES) -o $@ $(EXTRA_LDFLAGS) $(LDFLAGS)
	@echo "make $@ finished on `date`"

i_potval: $(FILES)
	$(CC) $(CFLAGS) $(FILES) -o $@ $(EXTRA_LDFLAGS) $(LDFLAGS)
	@echo "make $@ finished on `date`"

i_ntpst: $(FILES)
	$(CC) $(CFLAGS) $(FILES) -o $@ $(EXTRA_LDFLAGS) $(LDFLAGS)
	@echo "make $@ finished on `date`"

i_stamac: $(FILES)
	$(CC) $(CFLAGS) $(FILES) -o $@ $(EXTRA_LDFLAGS) $(LDFLAGS)
	@echo "make $@ finished on `date`"

%.o : %.c
	$(CC) $(CFLAGS) -c $<

install:
	$(INSTALL_DIR) $(INS_BIN_DIR) 

	( \
		for target in $(TARGET); do \
		$(INSTALL_BIN) $$target $(INS_BIN_DIR); \
	done; );

	( \
		for target in $(OUT_TARGETS); do \
		$(INSTALL_BIN) $$target $(INS_BIN_DIR); \
	done; );

clean:
	rm -f *.o
	rm -f $(TARGET)
