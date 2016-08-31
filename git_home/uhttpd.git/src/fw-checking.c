/*
 * Firmware checking
 *
 * According Spec v13 page 202:
 * For the FW checking frequency, use this definition.
 * 1. Check after each power cycle.
 * 2. If continue to be powered on, check once every week at 10:00pm + a random number
 *    of minutes between 0~59 (to avoid all routers hitting the auto update server at
 *    exactly the same time) on the week day determined by the last digit of S/N: 0, 1
 *    and 2 on Monday, 3 and 4 on Tuesday, 5 and 6 on Wednesday, 7 and 8 on Thursday, 9
 *    and A on Friday, B and C on Saturday, D, E and F on Sunday (again, this is to spread
 *    the time when router checks firmware). This date & time is based on the local time
 *    zone set on the Security / Schedule page.
 */

#include <string.h>
#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/types.h>

static char *check_fw_cmd = NULL;
static char *get_sn_cmd = NULL;
static char *sn_file = NULL;
static char *tz_name = NULL;

static void __nprintf(const char *fmt, ...)
{
	va_list ap;
	static FILE *filp;

	if ((filp == NULL) && (filp = fopen("/dev/console", "a")) == NULL)
		return;

	va_start(ap, fmt);
	vfprintf(filp, fmt, ap);
	fputs("\n", filp);
	va_end(ap);
}

static void fw_checking()
{
	FILE *fp;
	char buf[64];
	int i;
	long sn=0;
	long expect_time = 0;
	long current_time = 0;
	long diff_time = 0;
	
	time_t now;
	struct tm *tm;
	char *p;

	enum weekday{sunday, monday, tuesday, wednesday, thursday, friday, saturday};
	enum weekday week_day;

	if( fork() != 0)
	{
		return;
	}

	/*1. Check after each power cycle */
	__nprintf("AUTO FW CHECK: power cycle");
	system(check_fw_cmd);


	/* 2 if continuing to be powered on, check once every week at 10:00 pm + 
	   a random number of minutes between 0~59 on the week day determined 
	   by the last digit of S/N */

	// get week day
	buf[0]='\0';
	if ( sn_file != NULL )
	{
		if ((fp = fopen(sn_file, "r")) == NULL && get_sn_cmd != NULL)
		{
			if ((fp = popen(get_sn_cmd, "r"))!= NULL)
			{
				fgets(buf, sizeof(buf)-1, fp);
				pclose(fp);
			}
		}
		else
		{
			fgets(buf, sizeof(buf)-1, fp);
			fclose(fp);
		}
	}

	for(i = strlen(buf)-1; i>=0; i--)
	{//get the last digit
		if( buf[i] >= '0' && buf[i] <= '9')
		{
			sn=buf[i]-48;
			break;
		}
		else if( buf[i] >= 'A' && buf[i] <= 'F')
		{
			sn=buf[i]-55;
			break;
		}
		else if( buf[i] >= 'a' && buf[i] <= 'f')
		{
			sn=buf[i]-87;
			break;
		}

	}

	switch(sn){
		case 0:
		case 1:
		case 2: week_day=monday; break;
		case 3:
		case 4: week_day=tuesday; break;
		case 5:
		case 6: week_day=wednesday; break;
		case 7:
		case 8: week_day=thursday; break;
		case 9:
		case 10: week_day=friday; break;
		case 11:
		case 12: week_day=saturday; break;
		case 13:
		case 14:
		case 15:
		default:week_day=sunday;
	}
	__nprintf("week_day == %d", week_day);
	//expect time is 10:00(pm) + random number between 0-59
	srand((int)time(0));
	expect_time = 22*60*60+ (rand()%60)*60;

	while(1)
	{/* check current time every half hour. */
		#define HALF_HOUR	30*60
		#define TWO_HOUR	120*60
		sleep(HALF_HOUR);

		p = config_get(tz_name);
		time(&now);
		setenv("TZ", p, 1);
		tm = localtime(&now);
		//fprintf(stderr, "tm->tm_wday == %d\n", tm->tm_wday);
		if(tm->tm_wday == week_day)
		{
			//fprintf(stderr, "tm_wday == week_day\n");
			current_time = (long)tm->tm_hour*60*60+(long)tm->tm_min*60+(long)tm->tm_sec;
			expect_time = 22*60*60+ (rand()%60)*60;

			diff_time = expect_time - current_time;
			//printf(stedrr, "diff_time ==%ld\n", diff_time);
			if(diff_time == 0)
			{
				__nprintf("AUTO FW checking: once a week");
				system(check_fw_cmd);
			}
			else if(diff_time < TWO_HOUR && diff_time > 0 )
			{
				__nprintf("AUTO FW will check after %ld seconds", diff_time);
				sleep(diff_time);
				__nprintf("AUTO FW checking: once a week");
				system(check_fw_cmd);
			}
		}
	}
}

static void usage(void)
{
	__nprintf("Usage: fw-checking <option> ...\n"
			"<options>:\n"
			"	-c <cmd>	The command of checking new firmware\n"
			"	-g <cmd>	The command of get serial number\n"
			"	-s <file>	The serial file\n"
			"	-t <name>	The config name of time zone\n"
			"       -h              printf this message.\n"
	       );
}

int main (int argc, char **argv)
{

	int opt;

	while ((opt = getopt(argc, argv, "f:c:g:s:t:h")) != -1) {
		switch (opt) {
			case 'c':
				check_fw_cmd = strdup(optarg);
				break;
			case 'g':
				get_sn_cmd = strdup(optarg);
				break;
			case 's':
				sn_file = strdup(optarg);
				break;
			case 't':
				tz_name = strdup(optarg);
				break;
			case 'h':
			default:
				usage();
		}
	}

	if (!check_fw_cmd || (!get_sn_cmd && !sn_file) || !tz_name) {
		__nprintf("Must spully all compulsory arguments, exit!");
		return -1;
	}
	__nprintf("check new firmware comand:	%s\n"
		"get serial number command:	%s\n"
		"serial number file:		%s\n"
		"time zone name:		%s\n",
		check_fw_cmd, get_sn_cmd, sn_file, tz_name);

	fw_checking();
	return 1;
}
