# $Id: Makefile,v 1.1.2.2 2007/02/27 03:06:36 ronger Exp $

PREFIX?=/
BIN_DIR?=$(PREFIX)/usr/sbin

all: ntpclient

%.o: %.c
	$(CC) $(CFLAGS) $(EXTRA_CFLAGS)  -c -o $@ $^

ntpclient: ntpclient.o phaselock.o
	$(CC) -o $@ $^

install: all
	install -d -m0755 $(BIN_DIR)
	install -m0755 ./ntpclient $(BIN_DIR)

clean:
	rm -f *.o ntpclient
