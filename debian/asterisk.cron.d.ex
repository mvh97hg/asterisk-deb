#
# Regular cron jobs for the asterisk package
#
0 4	* * *	root	[ -x /usr/bin/asterisk_maintenance ] && /usr/bin/asterisk_maintenance
