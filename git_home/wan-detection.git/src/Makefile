
files=$(wildcard *.c)
bin=detwan

all: $(bin)

CFLAGS += -Wall -Wunused -g -O2

%.o: %.c
	$(CC) $(CFLAGS) -c $<

$(bin) : $(files:%.c=%.o)
	$(CC) $(CFLAGS) $(files) -o $@ $(EXTRA_LDFLAGS) $(LDFLAGS) -lconfig
	@echo "make $@ finished on `date`"

install:
	$(INSTALL_DIR) $(INS_BIN_DIR)
	$(INSTALL_BIN) $(bin) $(INS_BIN_DIR)

clean:
	rm -f *.o $(bin)
