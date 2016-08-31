BINARY:= libconfig.so config datalib
# CONFIG_LINKS was defined on top Makefile

PREFIX?=/
BIN_DIR?=$(PREFIX)/bin
LIB_DIR?=$(PREFIX)/usr/lib

.PHONY: all install clean
all:
	@echo "Compile $^ on $(shell date)"

libconfig.so: config.o
	$(CC) -shared -o $@ $^

config: demo.o libconfig.so
	$(CC) -o $@ $< -lconfig -L.

datalib: datalib.o defaults.o mtd.o appconfig.o
	$(CC) -o $@ $^

%.o: %.c
	$(CC) $(CFLAGS) -fPIC -o $@ -c $^

install: all
	install -d $(BIN_DIR) -d $(LIB_DIR)
	install -m 755 ./config $(BIN_DIR)
	install -m 755 ./datalib $(BIN_DIR)
	install -m 755 ./libconfig.so $(LIB_DIR)
	$(foreach n,$(CONFIG_LINKS),ln -sf config $(BIN_DIR)/$(n);)

clean:
	rm -f *.o $(BINARY)
