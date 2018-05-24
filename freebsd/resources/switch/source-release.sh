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
pkg install --yes gcc49 wget sudo libsndfile lua52 opus libmemcached libvorbis libogg tiff memcached

#additional dependencies
#pkg install --yes libshout mpg123 lame

#get the source from git and run boostrap
#git clone -b v1.6 https://freeswitch.org/stash/scm/fs/freeswitch.git /usr/src/freeswitch
#cd /usr/src/freeswitch && /bin/sh /usr/src/freeswitch/bootstrap.sh -j

#get the release from https
cd /usr/src && fetch https://files.freeswitch.org/freeswitch-releases/freeswitch-1.6.20.zip
cd /usr/src && unzip /usr/src/freeswitch-1.6.20.zip
mv /usr/src/freeswitch-1.6.20 /usr/src/freeswitch

#enable the modules
sed -i' ' -e s:'#applications/mod_avmd:applications/mod_avmd:' /usr/src/freeswitch/modules.conf
sed -i' ' -e s:'#applications/mod_callcenter:applications/mod_callcenter:' /usr/src/freeswitch/modules.conf
sed -i' ' -e s:'#applications/mod_cidlookup:applications/mod_cidlookup:' /usr/src/freeswitch/modules.conf
sed -i' ' -e s:'#applications/mod_memcache:applications/mod_memcache:' /usr/src/freeswitch/modules.conf
sed -i' ' -e s:'#applications/mod_curl:applications/mod_curl:' /usr/src/freeswitch/modules.conf
#sed -i' ' -e s:'#formats/mod_shout:formats/mod_shout:' /usr/src/freeswitch/modules.conf
#sed -i' ' -e s:'#formats/mod_nibblebill:formats/mod_nibblebill:' /usr/src/freeswitch/modules.conf

#disable mod_fsv
#sed -i '' -e s:'applications/mod_fsv:#applications/mod_fsv:' /usr/src/freeswitch/modules.conf

#set the variables
export CC=gcc49
export CFLAGS="-Wno-error -std=gnu99 -Wno-c11-extensions -Wno-deprecated-declarations -Wno-zero-length-array -Wno-incompatible-pointer-types"

#configure the source (additional option --enable-system-lua)
/usr/src/freeswitch/./configure --prefix=/usr/local/freeswitch --enable-core-pgsql-support --disable-fhs

#gmake
rm -rf /usr/local/freeswitch/{lib,mod,bin}/*
gmake install
gmake sounds-install moh-install
gmake hd-sounds-install hd-moh-install
#gmake cd-sounds-install cd-moh-install
#gmake uhd-sounds-install uhd-sounds-install

#move the music into music/default directory
mkdir -p /usr/local/freeswitch/sounds/music/default
mv /usr/local/freeswitch/sounds/music/*000 /usr/local/freeswitch/sounds/music/default

#configure system service
ln -s /usr/local/freeswitch/bin/fs_cli /usr/bin/fs_cli
cp "$cwd/rc.d.freeswitch" /usr/local/etc/rc.d/freeswitch
chmod 0555 /usr/local/etc/rc.d/freeswitch

#enable the services
echo 'memcached_enable="YES"' >> /etc/rc.conf
echo 'freeswitch_enable="YES"' >> /etc/rc.conf
echo 'freeswitch_flags="-nc -nonat -u www -g www"' >> /etc/rc.conf

#start the services
service memcached start
