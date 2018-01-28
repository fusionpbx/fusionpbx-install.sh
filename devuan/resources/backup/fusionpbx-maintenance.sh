#!/bin/sh

#settings
#export PGPASSWORD="zzzzz"
db_host=127.0.0.1
db_port=5432
switch_package=true # true or false

#set the date
now=$(date +%Y-%m-%d)

#make sure the directory exists
mkdir -p /var/backups/fusionpbx/postgresql

#show message to the console
echo "Maintenance Started"

#delete freeswitch logs older 7 days
if [ .$switch_package = .true ]; then
	find /var/log/freeswitch/freeswitch.log.* -mtime +7 -exec rm {} \;
else
	find /usr/local/freeswitch/log/freeswitch.log.* -mtime +7 -exec rm {} \;
fi

#delete fax older than 90 days
if [ .$switch_package = .true ]; then
	echo ".";
	#find /var/lib/freeswitch/storage/fax/*  -name '*.tif' -mtime +90 -exec rm {} \;
	#find /var/lib/freeswitch/storage/fax/*  -name '*.pdf' -mtime +90 -exec rm {} \;
else
	echo ".";
	#find /usr/local/freeswitch/storage/fax/*  -name '*.tif' -mtime +90 -exec rm {} \;
	#find /usr/local/freeswitch/storage/fax/*  -name '*.pdf' -mtime +90 -exec rm {} \;
fi
#delete from the database
#psql --host=127.0.0.1 --username=fusionpbx -c "delete from v_fax_files WHERE fax_date < NOW() - INTERVAL '90 days'"

#delete voicemail older than 90 days
if [ .$switch_package = .true ]; then
	echo ".";
	#find /usr/local/freeswitch/storage/voicemail/*  -name 'msg_*.wav' -mtime +90 -exec rm {} \;
	#find /usr/local/freeswitch/storage/voicemail/*  -name 'msg_*.mp3' -mtime +90 -exec rm {} \;
else
	echo ".";
	#find /usr/local/freeswitch/storage/voicemail/*  -name 'msg_*.wav' -mtime +90 -exec rm {} \;
	#find /usr/local/freeswitch/storage/voicemail/*  -name 'msg_*.mp3' -mtime +90 -exec rm {} \;
fi
#psql --host=127.0.0.1 --username=fusionpbx -c "delete from v_voicemail_messages WHERE to_timestamp(created_epoch) < NOW() - INTERVAL '90 days'"
#delete call detail records older 90 days
#psql --host=127.0.0.1 --username=fusionpbx -c "delete from v_xml_cdr WHERE start_stamp < NOW() - INTERVAL '90 days'"

#completed message
echo "Maintenance Completed";
