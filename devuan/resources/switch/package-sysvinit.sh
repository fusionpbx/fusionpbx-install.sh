update-rc.d freeswitch enable
#
# If freeswitch is not restarted with the new config before finish.sh is run,
# upgrade_domains.php will not set the paths correctly on the default domain
#
service freeswitch restart