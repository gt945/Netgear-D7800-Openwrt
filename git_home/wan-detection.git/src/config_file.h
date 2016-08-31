#ifndef _CONFIG_H_
#define _CONFIG_H_

#if !defined(LOGO)
#define LOGO "[*CONFIG*]"
#endif

#define logger(x, ...) fprintf(stderr, LOGO "[%s:%d] " x, __func__, __LINE__, ##__VA_ARGS__)

/* type of config items:
 *	BOOLEAN:	switch-variable, on|off, true|false.
 *	NUMBER:		numeric-variable, same as 'int'.
 *	STRING:		string-variable, same as 'char*'.
 */
typedef enum config_type { BOOLEAN, NUMBER, STRING } conft;

/* value of switch variable:
 * 	FALSE:		switch off, when used for feature means disable it.
 * 	TRUE:		switch on, when used for feature means enable it.
 */
typedef enum bool_value { FALSE, TRUE } boolv;

typedef union config_value {
	char	*string;
	int	number;
	boolv	state;
} confv;

typedef struct config_unit {
	char	*name;
	conft	type;
	confv	value;
} confu;

/* public APIs */
extern int load_config(char *file);
extern int get_conf_bool(char *name);
extern char *get_conf_string(char *name);
extern int get_conf_number(char *name);
extern void print_all_configs(void);
#endif	/* _CONFIG_H_ */
