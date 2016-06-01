#########################################################
#Turning off Repeated Msg Reduction in /etc/rsyslog.conf"
#########################################################
sed -i 's/RepeatedMsgReduction\ on/RepeatedMsgReduction\ off/' /etc/rsyslog.conf

############################
# Restarting rsyslog service
############################
service rsyslog restart

sed -i /usr/bin/fail2ban-client -e s,^\.setInputCmd\(c\),'time.sleep\(0\.1\)\n\t\t\tbeautifier.setInputCmd\(c\)',

##############################
#Restarting Nginx and PHP FPM
##############################
for i in freeswitch fail2ban
do service "${i}" restart  > /dev/null 2>&1
done

############################################################
# see http://wiki.fusionpbx.com/index.php?title=RotateFSLogs
############################################################
cat > "/etc/cron.daily/freeswitch_log_rotation" <<DELIM
#!/usr/bin/bash

#number of days of logs to keep
NUMBERDAYS="$keep_logs"
FSPATH="/var/log/freeswitch"

freeswitch_cli -x "fsctl send_sighup" |grep '+OK' >/tmp/rotateFSlogs

if [ $? -eq 0 ]; then
       #-cmin 2 could bite us (leave some files uncompressed, eg 11M auto-rotate). Maybe -1440 is better?
       find "$FSPATH" -name "freeswitch.log.*" -cmin -2 -exec gzip {} \;
       find "$FSPATH" -name "freeswitch.log.*.gz" "-mtime" "+$NUMBERDAYS" -exec rm {} \;
       chown freeswitch:freeswitch "$FSPATH"/freeswitch.log
       chmod 664 "$FSPATH"/freeswitch.log
       logger FreeSWITCH Logs rotated
       rm /tmp/<<DELIM
else
       logger FreeSWITCH Log Rotation Script FAILED
       mail -s '$HOST FS Log Rotate Error' root < /tmp/<<DELIM
       rm /tmp/<<DELIM
fi

DELIM

chmod 664 /etc/cron.daily/freeswitch_log_rotation

###########################################################
# restarting services after fail2ban/monit services install
###########################################################
for i in php5-fpm niginx monit fail2ban freeswitch ;do service "${i}" restart  >/dev/null 2>&1 ; done
