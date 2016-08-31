include $(NETCGI_CONF)

ifeq ($(MAKECMDGOALS),install)
#check_language=$(shell ./check_language.sh)
check_language=success
endif

.PHONY: all install clean
install:
ifeq ($(check_language),success)
	@echo "check language success"
else
	$(error language check fail, please see invalid/)
endif

all:

clean:

