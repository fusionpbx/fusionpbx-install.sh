#!/bin/sh

#send a message
echo "Install FusionPBX"

#install dependencies
apt-get install -y --force-yes vim git dbus haveged
apt-get install -y --force-yes ghostscript libtiff5 libtiff-tools

######################
#adding FusionPBX repo
#######################
echo ' installing fusionpbx jessie Stabe/Release repo '
cat > "/etc/apt/sources.list.d/fusionpbx.list" <<DELIM
deb http://103.247.152.122/fusionpbx/debian/ jessie main
DELIM
echo

#################################################
#run repo update after adding in a new repo....
#################################################
apt-get update

###########################
#Installing fusionpbx pkgs
###########################
apt-get -y --force-yes install fusionpbx-core fusionpbx-app-access-controls fusionpbx-app-calls \
		fusionpbx-app-calls-active fusionpbx-app-call-block fusionpbx-app-contacts fusionpbx-app-destinations \
		fusionpbx-app-dialplan fusionpbx-app-dialplan-inbound fusionpbx-app-dialplan-outbound fusionpbx-app-emails \
		fusionpbx-app-extensions fusionpbx-app-follow-me fusionpbx-app-gateways fusionpbx-app-ivr-menus \
		fusionpbx-app-log-viewer fusionpbx-app-modules fusionpbx-app-music-on-hold fusionpbx-app-operator-panel \
		fusionpbx-app-phrases fusionpbx-app-recordings fusionpbx-app-registrations fusionpbx-app-ring-groups \
		fusionpbx-app-scripts fusionpbx-app-settings fusionpbx-app-sip-profiles fusionpbx-app-sip-status \
		fusionpbx-app-system fusionpbx-app-time-conditions fusionpbx-app-xml-cdr fusionpbx-app-vars fusionpbx-app-voicemails \
		fusionpbx-app-voicemail-greetings fusionpbx-conf fusionpbx-sqldb fusionpbx-scripts fusionpbx-theme-default

#####################################
#cp the default configs into place.
#####################################
cp -rp "$fs_dflt_conf_dir"/vanilla/* "/etc/fusionpbx"

########################################
#fix ownership of files for freeswitch
########################################
chown -R www-data:freeswitch "/etc/fusionpbx"

##################################################
#configuring freeswitch to start with new layout.
##################################################
#Freeswitch layout for FHS with fusionpbx
##################################################
cat > '/etc/default/freeswitch' << DELIM
CONFDIR="/etc/fusionpbx"
#
# Uncooment extra lines and make sure to add cut and paste them to the DAEMON_ARGS
# Options to control locations of files:
fs_conf="/etc/fusionpbx"
fs_db="/var/lib/freeswitch/db"
fs_log="/var/log/freeswitch"
fs_recordings="/var/lib/fusionpbx/recordings"
fs_run="/run/freeswitch"
fs_scripts="/var/lib/fusionpbx/scripts"
fs_storage="/var/lib/fusionpbx/storage"
fs_usr=freeswitch
fs_grp=www-data
#
#These are the optional arguments you can pass to freeswitch: (add options to fs_options line)
# -nf                    -- no forking
# -reincarnate           -- restart the switch on an uncontrolled exit
# -reincarnate-reexec    -- run execv on a restart (helpful for upgrades)
# -u [user]              -- specify user to switch to
# -g [group]             -- specify group to switch to
# -core                  -- dump cores
# -rp                    -- enable high(realtime) priority settings
# -lp                    -- enable low priority settings
# -np                    -- enable normal priority settings
# -vg                    -- run under valgrind
# -nosql                 -- disable internal sql scoreboard
# -heavy-timer           -- Heavy Timer, possibly more accurate but at a cost
# -nonat                 -- disable auto nat detection
# -nonatmap              -- disable auto nat port mapping
# -nocal                 -- disable clock calibration
# -nort                  -- disable clock clock_realtime
# -stop                  -- stop freeswitch
# -nc                    -- do not output to a console and background
# -ncwait                -- do not output to a console and background but wait until the system is ready before exiting (implies -nc)
# -c                     -- output to a console and stay in the foreground
#
# Reads in the arguments into 1 line command
DAEMON_ARGS="-nc -rp -reincarnate"
DELIM

#################################################################
#restartng services with thefusionpbx freeswitch fhs dir layoout
#################################################################
echo " Restarting freeswitch for changes to take effect...."
service freeswitch restart

########################
#set permissions on dir
########################
find "/var/lib/fusionpbx" -type d -exec chmod 775 {} +
find "/var/lib/fusionpbx" -type f -exec chmod 664 {} +
