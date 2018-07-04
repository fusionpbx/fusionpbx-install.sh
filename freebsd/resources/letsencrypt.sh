#!/bin/sh

# FusionPBX - Install
# Mark J Crane <markjcrane@fusionpbx.com>
# Copyright (C) 2018
# All Rights Reserved.

#move to script directory so all relative paths work
cd "$(dirname "$0")"

#includes
. ./config.sh

#remove dehyrdated letsencrypt script
#pkg remove dehydrated
#rm -R /usr/local/etc/dehydrated/
#rm /usr/local/sbin/dehydrated
#rm -R /usr/src/dehydrated
#rm -R /usr/src/dns-01-manual
#rm -R /usr/local/www/dehydrated

#request the domain name, email address and wild card domain
read -p 'Domain Name: ' domain_name
read -p 'Email Address: ' email_address

#wildcard detection
wilcard_domain=$(echo $domain_name | cut -c1-1)
if [ "$wilcard_domain" = "*" ]; then
        wilcard_domain="y"
else
        wilcard_domain="n"
fi

#get and install dehydrated
pkg install dehydrated
#cd /usr/src && git clone https://github.com/lukas2511/dehydrated.git
#cd /usr/src/dehydrated
#cp dehydrated /usr/local/sbin
#mkdir -p /usr/local/www/dehydrated
#mkdir -p /usr/local/etc/dehydrated/certs

#remove the wildcard and period
if [ .$wilcard_domain = ."y" ]; then
      domain_name=$(echo "$domain_name" | cut -c3-255)
fi

#create an alias when using wildcard dns
#if [ .$wilcard_domain = ."y" ]; then
#  echo "*.$domain_name > $domain_name" > /usr/local/etc/dehydrated/domains.txt
#fi

#manual dns hook
cd /usr/src
git clone https://github.com/owhen/dns-01-manual.git
cd /usr/src/dns-01-manual/
cp hook.sh /usr/local/etc/dehydrated/hook.sh
chmod 755 /usr/local/etc/dehydrated/hook.sh

#copy config and hook.sh into /usr/local/etc/dehydrated
cd /usr/src/dehydrated
cp docs/examples/config /usr/local/etc/dehydrated
#cp docs/examples/hook.sh /usr/local/etc/dehydrated

#vim /usr/local/etc/dehydrated/config
#sed "s#CONTACT_EMAIL=#CONTACT_EMAIL=$email_address" -i /usr/local/etc/dehydrated/config

#accept the terms
dehydrated --register --accept-terms --config /usr/local/etc/dehydrated/config

#wildcard domain
if [ .$wilcard_domain = ."y" ]; then
  dehydrated --cron --domain *.$domain_name --alias $domain_name --config /usr/local/etc/dehydrated/config --out /usr/local/etc/dehydrated/certs --challenge dns-01 --hook /usr/local/etc/dehydrated/hook.sh
fi

#single domain
if [ .$wilcard_domain = ."n" ]; then
  dehydrated --cron --domain $domain_name --config /usr/local/etc/dehydrated/config --config /usr/local/etc/dehydrated/config --out /usr/local/etc/dehydrated/certs --challenge dns-01 --hook /usr/local/etc/dehydrated/hook.sh
fi

#remove the old backups
rm /usr/local/etc/nginx/server.crt.backup
rm /usr/local/etc/nginx/server.key.backup

#nginx config - backup the original certificates and copy the news ones for nginx
mv /usr/local/etc/nginx/server.crt /usr/local/etc/nginx/server.crt.backup
mv /usr/local/etc/nginx/server.key /usr/local/etc/nginx/server.key.backup
cp /usr/local/etc/dehydrated/certs/$domain_name/fullchain.pem /usr/local/etc/nginx/server.crt
cp /usr/local/etc/dehydrated/certs/$domain_name/privkey.pem /usr/local/etc/nginx/server.key

#read the config
/usr/local/sbin/nginx -t && /usr/local/sbin/nginx -s reload

#make sure the freeswitch directory exists
mkdir -p /usr/local/etc/freeswitch/tls

#make sure the freeswitch certificate directory is empty
rm /usr/local/etc/freeswitch/tls/*

#combine the certs into all.pem
cat /usr/local/etc/dehydrated/certs/$domain_name/fullchain.pem > /usr/local/etc/freeswitch/tls/all.pem
cat /usr/local/etc/dehydrated/certs/$domain_name/privkey.pem >> /usr/local/etc/freeswitch/tls/all.pem
#cat /usr/local/etc/dehydrated/certs/$domain_name/chain.pem >> /usr/local/etc/freeswitch/tls/all.pem

#copy the certificates
cp /usr/local/etc/dehydrated/certs/$domain_name/cert.pem /usr/local/etc/freeswitch/tls
cp /usr/local/etc/dehydrated/certs/$domain_name/chain.pem /usr/local/etc/freeswitch/tls
cp /usr/local/etc/dehydrated/certs/$domain_name/fullchain.pem /usr/local/etc/freeswitch/tls
cp /usr/local/etc/dehydrated/certs/$domain_name/privkey.pem /usr/local/etc/freeswitch/tls

#add symbolic links
ln -s /usr/local/etc/freeswitch/tls/all.pem /usr/local/etc/freeswitch/tls/agent.pem
ln -s /usr/local/etc/freeswitch/tls/all.pem /usr/local/etc/freeswitch/tls/tls.pem
ln -s /usr/local/etc/freeswitch/tls/all.pem /usr/local/etc/freeswitch/tls/wss.pem
ln -s /usr/local/etc/freeswitch/tls/all.pem /usr/local/etc/freeswitch/tls/dtls-srtp.pem

#set the permissions
chown -R www-data:www-data /usr/local/etc/freeswitch/tls
