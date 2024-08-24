#!/bin/sh

#move to script directory so all relative paths work
cd "$(dirname "$0")"

#includes
. ../config.sh

#set the current working directory
cwd=$(pwd)

#send a message
echo "Installing the FreeSWITCH source"

#install minimum dependencies
pkg install --yes autoconf automake curl git gmake ldns libedit libtool openssl pcre pkgconf speex sqlite3
pkg install --yes wget sudo libsndfile lua52 opus libmemcached libvorbis libogg tiff memcached

#additional dependencies
#pkg install --yes libshout mpg123 lame

#get the source
git clone https://github.com/signalwire/freeswitch.git /usr/src/freeswitch

#prepare the source
cd /usr/src/freeswitch && /bin/sh /usr/src/freeswitch/bootstrap.sh -j

#enable the modules
sed -i' ' -e s:'#applications/mod_avmd:applications/mod_avmd:' /usr/src/freeswitch/modules.conf
sed -i' ' -e s:'#applications/mod_callcenter:applications/mod_callcenter:' /usr/src/freeswitch/modules.conf
sed -i' ' -e s:'#applications/mod_cidlookup:applications/mod_cidlookup:' /usr/src/freeswitch/modules.conf
sed -i' ' -e s:'#applications/mod_memcache:applications/mod_memcache:' /usr/src/freeswitch/modules.conf
sed -i' ' -e s:'#applications/mod_curl:applications/mod_curl:' /usr/src/freeswitch/modules.conf
#sed -i' ' -e s:'#formats/mod_shout:formats/mod_shout:' /usr/src/freeswitch/modules.conf

#configure the source (additional option --enable-system-lua)
/bin/sh configure --prefix=/usr/local/freeswitch --enable-core-pgsql-support --disable-fhs

#gmake
rm -rf /usr/local/freeswitch/{lib,mod,bin}/*
gmake install
gmake sounds-install moh-install
gmake hd-sounds-install hd-moh-install
gmake cd-sounds-install cd-moh-install
gmake uhd-sounds-install uhd-sounds-install

#move the music into music/default directory
mkdir -p /usr/local/freeswitch/sounds/music/default
mv /usr/local/freeswitch/sounds/music/*000 /usr/local/freeswitch/sounds/music/default

#set the original working directory
cd $cwd

#configure system service
ln -s /usr/local/freeswitch/bin/fs_cli /usr/bin/fs_cli
cp "$(dirname $0)/rc.d.freeswitch /usr/local/etc/rc.d/freeswitch
chmod u-w,ugo+x /usr/local/etc/rc.d/freeswitch

#enable the service
echo 'freeswitch_enable="YES"' >> /etc/rc.conf
echo 'freeswitch_flags="-nc -nonat -u www -g www"' >> /etc/rc.conf

#start the service
service memcached start
