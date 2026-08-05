#old

#setup owner and group, permissions and sticky
#chmod -R ug+rw /usr/local/freeswitch
#touch /usr/local/freeswitch/freeswitch.log
#chown -R www-data:www-data /usr/local/freeswitch
#find /usr/local/freeswitch -type d -exec chmod 2770 {} \;


#current (same paths as package)

#move to script directory so all relative paths work
cd "$(dirname "$0")"

#includes
. ../config.sh

#default permissions
chown -R www-data:www-data /etc/freeswitch
chown -R www-data:www-data /var/lib/freeswitch
chown -R www-data:www-data /usr/share/freeswitch
chown -R www-data:www-data /var/log/freeswitch
chown -R www-data:www-data /var/run/freeswitch
chown -R www-data:www-data /var/cache/fusionpbx
