#!/bin/sh
(
#Repos
USE_UNOFFICIAL_ARM_REPO=0
arch=$(uname -m)
if [ $arch = 'armv7l' ] && [ $USE_UNOFFICIAL_ARM_REPO -eq 1 ]; then
		cat > /etc/apt/source.list.d/freeswitch.list << DELIM
        deb http://repo.sip247.com/debian/freeswitch-stable-armhf/ jessie main
DELIM
        curl http://repo.sip247.com/debian/sip247.com.gpg.key | apt-key add - 
else
        cat > /etc/apt/source.list.d/freeswitch.list << DELIM
        deb http://files.freeswitch.org/repo/deb/freeswitch-1.6/ jessie main
DELIM
        curl http://files.freeswitch.org/repo/deb/freeswitch-1.6/key.gpg | apt-key add - 
fi

#Used for pkg based installs for cp the base configs into place
fs_conf_dir="/etc/freeswitch"
fs_dflt_conf_dir="/usr/share/freeswitch/conf"

# Set what language lang/say pkgs and language sound files to use. ( Only if pkgs install is selected )
# en-ca=English/CA en-us=English/US (default) fr-ca=French/Canadian pt-br=Portuguese/Brazill
# ru-ru=Russian/Russia sv-se=Swedish/Sweden zh-cn=chinese/Mandarin zh-hk=chinese/HongKong
freeswitch_sounds_language="en-us" #Currently other sounds dont exist.

#Pre Deps
apt-get update && apt-get -y install --force-yes sqlite3 unixodbc uuid memcached libtiff5 libtiff-tools time bison htop screen libpq5 lame curl haveged 

#Freeswitch Pkgs
apt-get -y install --force-yes libfreeswitch1 freeswitch freeswitch-mod-curl freeswitch-systemd freeswitch-mod-db freeswitch-doc \
	freeswitch-mod-distributor freeswitch-mod-dptools freeswitch-mod-enum freeswitch-mod-esf freeswitch-mod-esl \
	freeswitch-mod-expr freeswitch-mod-fsv freeswitch-mod-hash freeswitch-mod-memcache freeswitch-mod-portaudio \
    freeswitch-mod-portaudio-stream freeswitch-mod-spandsp freeswitch-mod-spy freeswitch-mod-translate \
    freeswitch-mod-valet-parking freeswitch-mod-flite freeswitch-mod-pocketsphinx freeswitch-mod-tts-commandline \
    freeswitch-mod-dialplan-xml freeswitch-mod-loopback freeswitch-mod-sofia freeswitch-mod-event-multicast \
    freeswitch-mod-event-socket freeswitch-mod-local-stream freeswitch-mod-native-file freeswitch-mod-sndfile \
    freeswitch-mod-tone-stream freeswitch-mod-lua freeswitch-mod-console freeswitch-mod-logfile freeswitch-mod-syslog \
    freeswitch-mod-say-en freeswitch-mod-posix-timer freeswitch-mod-timerfd freeswitch-mod-xml-cdr freeswitch-mod-shout\
    freeswitch-mod-xml-curl freeswitch-mod-xml-rpc freeswitch-conf-vanilla freeswitch-mod-vlc freeswitch-mod-verto \
    freeswitch-mod-sms freeswitch-timezones freeswitch-mod-bert freeswitch-mod-basic freeswitch-mod-lcr freeswitch-mod-rtc \
    freeswitch-mod-commands freeswitch-mod-cdr-csv 
    
#setup language / sound files for use
#if [[ $freeswitch_sounds_language == "en-ca" ]]; then
#	apt-get -y install --force-yes freeswitch-lang-en freeswitch-mod-say-en freeswitch-sounds-en-ca-june
#fi

if [[ $freeswitch_sounds_language == "en-us" ]]; then
	apt-get -y install --force-yes freeswitch-lang-en freeswitch-mod-say-en freeswitch-sounds-en-us-callie freeswitch-music-default
fi

#if [[ $freeswitch_sounds_language == "fr-ca" ]]; then
#	apt-get -y install --force-yes freeswitch-lang-fr freeswitch-mod-say-fr freeswitch-sounds-fr-ca-june
#fi
#
#if [[ $freeswitch_sounds_language == "pt-br" ]]; then
#	apt-get -y install --force-yes freeswitch-lang-pt freeswitch-mod-say-pt freeswitch-sounds-pt-br-karina
#fi
#
#if [[ $freeswitch_sounds_language == "ru-ru" ]]; then
#	apt-get -y install --force-yes freeswitch-lang-ru freeswitch-mod-say-ru freeswitch-sounds-ru-ru-elena
#fi
#
#if [[ $freeswitch_sounds_language == "sv-se" ]]; then
#	apt-get -y install --force-yes freeswitch-lang-sv freeswitch-mod-say-sv freeswitch-sounds-sv-se-jakob
#fi

#if [[ $freeswitch_sounds_language == "zh-cn" ]]; then
#	apt-get -y install --force-yes freeswitch-mod-say-zh freeswitch-sounds-zh-cn-sinmei
#fi

#if [[ $freeswitch_sounds_language == "zh-hk" ]]; then
#	apt-get -y install --force-yes freeswitch-mod-say-zh freeswitch-sounds-zh-hk-sinmei
#fi

# make the freeswitch conf dir
mkdir -p "$fs_conf_dir"

#cp the default configs into place.
cp -rp "$fs_dflt_conf_dir"/vanilla/* "$fs_conf_dir"

#fix ownership of files for freeswitch
chown -R freeswitch:freeswitch "$fs_conf_dir"

#Adding users to needed groups
adduser freeswitch www-data
adduser freeswitch dialout

#Restarting freeswitch
service freeswitch restart

#cleanup
apt-get clean

) | tee ~/freeswitch-install.log