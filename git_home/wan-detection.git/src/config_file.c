#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <ctype.h>

#include "config_file.h"

static confu g_conf[] = {
	/* system information */
	{ "detwan_pptp_hostname", STRING, (confv)"r7500v2" },
	{ "detwan_lan_ifname", STRING, (confv)"br0" },
	{ "detwan_ppp_ifname", STRING, (confv)"ppp0" },
	{ "detwan_pptp_netmask", STRING, (confv)"255.255.255.255" },
	{ "detwan_pptp_ip", STRING, (confv)"10.0.0.140" },
	{ "detwan_pptp_server", STRING, (confv)"10.0.0.138" },
	{ "detwan_status_file", STRING, (confv)"/tmp/det_wan_type" },
	{ "detwan_ppp_status", STRING, (confv)"/etc/ppp/ppp0-status" },
	{ "detwan_bpa_status", STRING, (confv)"/tmp/bpa_info" },
	{ "detwan_cable_file", STRING, (confv)"/tmp/port_status" },

	/* features swtich: enable or disable */
	{ "detwan_lanhttp_access", NUMBER, (confv)0 },
	{ "detwan_nethttp_access", NUMBER, (confv)1 }, /* Access web server from Internet side */
	{ "detwan_apmode_det", BOOLEAN, (confv)TRUE },
	{ "detwan_have_dsl", BOOLEAN, (confv)FALSE },

	{ "wan_proto", STRING, (confv)"dhcp" },
	{ "wan_factory_mac", STRING, (confv)"6c:b0:ce:f3:ef:57" },
	{ "wan_hostname", STRING, (confv)"R7500" },
	{ "wan_dhcp_gateway", STRING, (confv)"172.17.144.254" },
	{ "wan_dhcp_ipaddr", STRING, (confv)"0.0.0.0" },
	{ "wan_dhcp_server", STRING, (confv)"172.17.151.6" },
	{ "internet_type", STRING, (confv)"1" },
	{ "internet_ppp_type", STRING, (confv)"0" },
	{ "dsl_wan_country", STRING, (confv)""},
	{ "dsl_wan_isp", STRING, (confv)""},
	{ "dsl_wan_ether_dhcp_option61", STRING, (confv)""},

	{ NULL, 0, 0 }	/* identify end of g_conf */
};

/* bool value:
 * FALSE:	"FALSE"|"false"|"OFF"|"off"|"0".
 * TRUE:	other values.
 */
static boolv get_boolvalue(char *str)
{
	return (boolv)(!(!strcasecmp(str, "FALSE") || !strcasecmp(str, "OFF") \
				|| !strcmp(str, "0")));
}

static int set_config_value(char *name, char *value)
{
	if (!name || !value) {
		logger("ERROR: name and value must be not NULL!\n");
		return -1;
	}

	confu *conf;
	for (conf=g_conf; conf->name; conf++) {
		if (!strcmp(conf->name, name)) {
			switch (conf->type) {
			case BOOLEAN:
				conf->value.state = get_boolvalue(value);
				break;
			case STRING:
				/* FIXME: when free memory got from strdup??? */
				conf->value.string = strdup(value);
				break;
			case NUMBER:
				/* value: (decimal) 12345, or (hexadecimal) 0x1f2c.
				 * FIXME: handle strtol error???
				 */
				conf->value.number = strtol(value, NULL, 0);
				break;
			}
			break;
		}
	}

	if (conf->name == NULL) {
		logger("WARN: unknow config name: %s\n", name);
		return 1;
	}

	return 0;
}

static char *trim(char **str)
{
	if (*str)
		while (isspace((int)**str))
			(*str)++;
	return *str;
}

/***
 * Function load_configs
 * 	Load all configuration from the config file passed in by <file>.
 * Return Value:
 * 	-1	critical error occur, like as config file not exist.
 * 	 0	load configuration succes.
 * 	 1	found unknow config name in config file, skip and print a warning.
 */
int load_config(char *file)
{
	FILE *fp;
	char line[256];
	char *name, *value;
	int ret = 0;

	if (file == NULL) {
		logger("ERROR: no config file supplied, use default values!\n");
		return -1;
	}

	fp = fopen(file, "r");
	if (fp == NULL) {
		logger("ERROR: can't open %s, use default values!\n", file);
		return -1;
	}

	/* format of lines (not include quotes) in config file:
	 * 	# name		value (this line is comment)
	 * 	str_name	"string value"
	 * 	num_name	12345
	 * 	bool_name	false
	 * 	...
	 * - name and value is separated by ' ', '\t', or mixed.
	 * - comment lines begin with '#'.
	 */
	do {
		/* FIXME: length of line is only 256, enough or not??? */
		bzero(line, sizeof(line));
		if (fgets(line, sizeof(line), fp) == NULL)
			break;

		char *p = line;

		/* skip spaces in head. */
		trim(&p);
		/* skip comment line and blank line. */
		if (*p == '#' || *p == '\0')
			continue;

		/* first field, config name */
		name = p;
		while (!isspace((int)*p))
			p++;
		*p++ = '\0';

		/* skip spaces separated config name and value. */
		trim(&p);
		if (*p == '#' || *p =='\0') {
			logger("WARN: no value specify to config %s\n", name);
			continue;
		}

		/* second feild, config value */
		if (*p == '\"') {	/* ignore double quotation marks. */
			value = ++p;
			while (*p != '\"')
				p ++;
		} else {
			value = p;
			while (!isspace((int)*p))
				p++;
		}
		*p = '\0';

		ret += set_config_value(name, value);
	} while (1);

	fclose(fp);
	return ret;
}

static confv get_conf_value(char *name)
{
	confu *conf;

	for (conf=g_conf; conf->name; conf++)
		if (!strcmp(conf->name, name))
			break;

	/* if no found config which name is <name>, will return last item in g_conf.
	 * definition is { NULL, 0, 0 }.
	 */
	return conf->value;
}

/* return value:
 *  0	FALSE
 *  1	TRUE
 */
int get_conf_bool(char *name)
{
	return get_conf_value(name).state == TRUE;
}

char *get_conf_string(char *name)
{
	return get_conf_value(name).string;
}

int get_conf_number(char *name)
{
	return get_conf_value(name).number;
}

/* normally used to debug... */
void print_all_configs(void)
{
	confu *conf;

	logger("All configs are listed with format \"`<name>`:`<value>`\"\n");
	for (conf=g_conf; conf->name; conf++) {
		switch (conf->type) {
		case BOOLEAN:
			logger("`%s` `%s`\n", conf->name, conf->value.state ? "TRUE" : "FALSE");
			break;
		case STRING:
			logger("`%s` `%s`\n", conf->name, conf->value.string);
			break;
		case NUMBER:
			logger("`%s` `%d`\n", conf->name, conf->value.number);
			break;
		}
	}
}
