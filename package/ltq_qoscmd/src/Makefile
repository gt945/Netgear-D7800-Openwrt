#
# Makefile for ltqqoscmd
#

#CFLAGS += -O2 -I$(KERNEL_INCLUDE_PATH)
PPA_CFG_FLAG +=-DCONFIG_LTQ_PPA_IPv6_ENABLE
PPA_CFG_FLAG +=-DCONFIG_LTQ_PPA_QOS
PPA_CFG_FLAG +=-DCONFIG_LTQ_PPA_QOS_WFQ
PPA_CFG_FLAG +=-DCONFIG_LTQ_PPA_QOS_RATE_SHAPING
PPA_CFG_FLAG +=-DCONFIG_LTQ_PPA_API_SW_FASTPATH
ifeq ($(CONFIG_FEATURE_SESSION_LIMIT),y)
PPA_CFG_FLAG +=-DCONFIG_LTQ_PPA_HANDLE_CONNTRACK_SESSIONS
endif

CFLAGS += -O2 $(PPA_CFG_FLAG) -I./

all: ltqqoscmd

ltqqoscmd.o: ltqqoscmd.c
ltqqoscmd_autotest.o: ltqqoscmd_autotest.c

ltqqoscmd: ltqqoscmd_autotest.o ltqqoscmd.o

clean:
	rm -f *.o ltqqoscmd
