#include "netscan.h"

struct config_struct configs[] =
{
	{ "arp_ifname", "br0"},
	{ "arp_file", "/tmp/netscan/attach_device"},
	{ "dhcp_list_file", "/tmp/dhcpd_hostlist"},
	{ "wlan_sta_file", "/tmp/sta_dev"},
	{ "lock_file", "/var/run/netscan.pid"},

	{ 0, 0} /* The End One */
};

static char *find_word(char **str)
{
	if (!*str)
		return NULL;

	while (isspace((int)**str)) {
		if (**str == '\0' || **str == '\r' || **str == '\n')
			return NULL;
		++*str;
	}

	return *str;
}

/* @@ convert config's value @@
 * 	1. remove '\r' and '\n' in tail of value.
 * 	2. remove '"' in head and tail of string value.
 * 	3. replace '\"' in content of value to '"'.
 * Return Value:
 * 	0	success
 * 	-1	fail
 */
static int convert_value(char *val)
{
	if (!val)
		return -1;

	char *s, *p, *e;
	s = p = val;
	e = val + strlen(val);

	if (*s == '\"') { /* string */
		p++;
		while (*p != '\"' && p < e) {
			if (*p == '\\' && *(p+1) == '\"') {
				*s++ = '\"';
				p = p+2;
			} else
				*s++ = *p++;
		}

		if (p >= e) {
			fprintf(stderr, "ERROR: missing tail \" for string value.\n");
			return -1;
		}

		if (*p == '\"')
			*s = '\0';
	} else {
		fprintf(stderr, "ERROR: value is not start with \"!\n");
		return -1;
	}

	return 0;
}

/* @@ load all configs from file @@
 * 	load <file> and read all configures.
 * Return Value:
 * 	-1	critical error, could not open <file> correctly.
 * 	 0	load configuration succes.
 * 	 1	found unknow config name in the config file, will ignore it and print a warning message.
 */
int load_configs(char *file)
{
	FILE *fp;
	char line[512]; /* enough to all configs??? */
	char *value, *name, *pos;
	struct config_struct *conf;
	int find_invconf = 0;

	if (file == NULL) {
		fprintf(stderr, "ERROR: file is NULL!\n");
		return -1;
	}

	fp = fopen(file, "r");
	if (fp == NULL) {
		fprintf(stderr, "ERROR: can't open file %s!\n", file);
		return -1;
	}

	/* contents in file should be:
	 * 	name1 "string \"value\""
	 * 	# comment line
	 * 	...
	 */
	while (fgets(line, sizeof(line), fp)) {
		pos = &line[0];

		/* blank line */
		if ((name = find_word(&pos)) == NULL)
			continue;

		/* comment line */
		if (*pos == '#')
			continue;

		while (!isspace((int)*pos))
			pos++;
		*pos++ = '\0';

		if ((value = find_word(&pos)) == NULL) {
			fprintf(stderr, "ERROR: miss value for config %s in file %s\n", name, file);
			continue;
		}
		if (convert_value(value)) {
			fprintf(stderr, "ERROR: invalid value for config %s in file %s\n", name, file);
			continue;
		}


		for (conf=&configs[0]; conf->name; conf++)
			if (!strcmp(conf->name, name)) {
				/* NOTE: strdup alloc memory, but not free in our code? */
				conf->value = strdup(value);
				break;
			}

		if (!conf->name) {
			find_invconf++;
			fprintf(stderr, "WARN: unknow config name found: %s\n", name);
		}
	}

	if (find_invconf)
		fprintf(stderr, "INFO: find %d unknow configs in file %s\n", find_invconf, file);

	fclose(fp);
	return find_invconf ? 1 : 0;
}

char * get_value(const char *name) 
{
	struct config_struct *conf;

	for (conf = &configs[0]; conf->name; conf++)
		if (!strcmp(conf->name, name))
			return conf->value;
			
	return NULL;	
}
