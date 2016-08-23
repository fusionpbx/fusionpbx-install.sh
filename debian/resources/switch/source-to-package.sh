#move source files to package directories
cp -R /usr/local/freeswitch/conf /etc/freeswitch
cp -R /usr/local/freeswitch/recordings/* /var/lib/freeswitch/recordings
cp -R /usr/local/freeswitch/storage/* /var/lib/freeswitch/storage
cp -R /usr/local/freeswitch/scripts/* /usr/share/freeswitch/scripts

#make sure the etc fusionpbx directory exists 
mkdir -p /etc/fusionpbx

#remove init.d startup script
mv /etc/init.d/freeswitch /usr/src/init.d.freeswitch
update-rc.d -f freeswitch remove

#add the the freeswitch package
$(dirname $0)/package-release.sh

#install freeswitch systemd.d
$(dirname $0)/package-systemd.sh

