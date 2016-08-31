all: acld acl_update_name aclctl aclhijackdns

%.o: %.c
	$(CC) -I. $(CFLAGS) $(EXTRA_CFLAGS) -c -o $@ $^

acld: acld.o
	$(CC) -o $@ $(EXTRA_LDFLAGS) $(LDFLAGS) -lconfig $^

acl_update_name: acl_update_name.o
	$(CC) -o $@ $(EXTRA_LDFLAGS) $(LDFLAGS) -lconfig $^

aclctl: aclctl.o
	$(CC) -o $@ $(EXTRA_LDFLAGS) $(LDFLAGS) $^

aclhijackdns: aclhijackdns.o
	$(CC) -o $@ $(EXTRA_LDFLAGS) $(LDFLAGS) $^

clean:
	rm -f *.o acld acl_update_name aclctl aclhijackdns
