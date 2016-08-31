CGI_SUPPORT ?= 1
LUA_SUPPORT ?= 1
TLS_SUPPORT ?= 1
UHTTPD_TLS ?= cyassl

ifeq ($(UHTTPD_TLS),openssl)
  TLS_LDFLAGS := -lssl
  TLS_CFLAGS := -DTLS_IS_OPENSSL
else
  TLS_LDFLAGS := -lcyassl -lm
  TLS_CFLAGS := -I$(STAGING_DIR)/usr/include/cyassl -DTLS_IS_CYASSL
endif

CFLAGS += $(TLS_CFLAGS)
LDFLAGS += -Wl,-rpath-link=$(STAGING_DIR)/usr/lib

CFLAGS += -Wall --std=gnu99
OBJ := uhttpd.o uhttpd-file.o uhttpd-utils.o
LIB := -Wl,--export-dynamic -lcrypt -ldl -lconfig

TLSLIB :=
LUALIB :=

HAVE_SHADOW=$(shell echo 'int main(void){ return !getspnam("root"); }' | \
	$(CC) -include shadow.h -xc -o/dev/null - 2>/dev/null && echo yes)

ifeq ($(HAVE_SHADOW),yes)
  CFLAGS += -DHAVE_SHADOW
endif

ifeq ($(TLS_SUPPORT),1)
  CFLAGS += -DHAVE_TLS
endif

ifeq ($(CGI_SUPPORT),1)
  CFLAGS += -DHAVE_CGI
endif

ifeq ($(LUA_SUPPORT),1)
  CFLAGS += -DHAVE_LUA
endif

CFLAGS += -D_FILE_OFFSET_BITS=64

world: compile

ifeq ($(CGI_SUPPORT),1)
  OBJ += uhttpd-cgi.o
endif

ifeq ($(LUA_SUPPORT),1)
  LUALIB := uhttpd_lua.so

  $(LUALIB): uhttpd-lua.c
		$(CC) $(CFLAGS) $(LDFLAGS) $(FPIC) \
			-shared -lm -llua -ldl \
			-o $(LUALIB) uhttpd-lua.c
endif

ifeq ($(TLS_SUPPORT),1)
  TLSLIB := uhttpd_tls.so

  $(TLSLIB): uhttpd-tls.c
		$(CC) $(CFLAGS) $(LDFLAGS) $(FPIC) \
			-shared $(TLS_LDFLAGS) \
			-o $(TLSLIB) uhttpd-tls.c
endif

%.o: %.c
	$(CC) $(CFLAGS) -c -o $@ $<

uhttpd: $(OBJ) $(TLSLIB) $(LUALIB)
	$(CC) -o uhttpd $(LDFLAGS) $(OBJ) $(LIB)

fw-checking: fw-checking.o
	$(CC) -o fw-checking $(LDFLAGS) fw-checking.o $(LIB)

all: uhttpd fw-checking

install:
	$(INSTALL_DIR) $(INS_BIN_DIR)
	$(INSTALL_BIN) uhttpd	$(INS_BIN_DIR)
	$(INSTALL_BIN) fw-checking $(INS_BIN_DIR)
	$(INSTALL_DIR) $(INS_LIB_DIR)
	$(INSTALL_BIN) *.so $(INS_LIB_DIR)

clean:
	rm -f *.o *.so uhttpd fw-checking
