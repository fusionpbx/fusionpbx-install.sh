#!/bin/sh

# FusionPBX - Install
# Mark J Crane <markjcrane@fusionpbx.com>
# Copyright (C) 2018
# All Rights Reserved.

#move to script directory so all relative paths work
cd $(dirname "$0")

#includes
. ./config.sh

#remove dehyrdated letsencrypt script
#rm -R /etc/dehydrated/
#rm /usr/local/sbin/dehydrated
#rm -R /usr/src/dehydrated
#rm -R /usr/src/dns-01-manual
#rm -R /var/www/dehydrated

#request the domain name, email address and wild card domain
read -p 'Domain Name(s): ' domain_name
read -p 'Email Address: ' email_address

#get and install dehydrated
cd /usr/src && git clone https://github.com/dehydrated-io/dehydrated.git
cd /usr/src/dehydrated
cp dehydrated /usr/local/sbin
mkdir -p /var/www/dehydrated
mkdir -p /etc/dehydrated/certs

#wildcard detection
wildcard_domain=$(echo "$domain_name" | cut -c1-2)
if [ "$wildcard_domain" = "*." ]; then
	wildcard_domain="true"
	domain_alias=$(echo "$domain_name" | cut -c3-)
else
	wildcard_domain="false"
	domain_alias="$domain_name"
fi

#set the domain alias
domain_alias=$(echo "$domain_alias" | head -n1 | cut -d " " -f1)

#cater for domain lists with wildcards
if echo "$domain_name" | grep -Eq "\*\."; then
      wildcard_domain="true"
fi

#manual dns hook
if [ .$wildcard_domain = ."true" ]; then
    cd /usr/src
    git clone https://github.com/gheja/dns-01-manual.git
    cd /usr/src/dns-01-manual/
    cp hook.sh /etc/dehydrated/hook.sh
    chmod 755 /etc/dehydrated/hook.sh
fi

#copy default config into /etc/dehydrated
cd /usr/src/dehydrated
cp docs/examples/config /etc/dehydrated

#update the dehydrated config
#sed "s#CONTACT_EMAIL=#CONTACT_EMAIL=$email_address" -i /etc/dehydrated/config
sed -i 's/#CONTACT_EMAIL=/CONTACT_EMAIL="'"$email_address"'"/g' /etc/dehydrated/config
sed -i 's/#WELLKNOWN=/WELLKNOWN=/g' /etc/dehydrated/config

#accept the terms
dehydrated --register --accept-terms --config /etc/dehydrated/config

#add the domain name to domains.txt
echo "$domain_name > $domain_alias" > /etc/dehydrated/domains.txt

#request the certificates
if [ .$wildcard_domain = ."true" ]; then
	dehydrated --cron --config /etc/dehydrated/config --out /etc/dehydrated/certs --challenge dns-01 --hook /etc/dehydrated/hook.sh
fi
if [ .$wildcard_domain = ."false" ]; then
	dehydrated --cron --config /etc/dehydrated/config --out /etc/dehydrated/certs --challenge http-01
fi

#make sure the nginx ssl directory exists
mkdir -p /etc/nginx/ssl

#update nginx config
sed "s@ssl_certificate         /etc/ssl/certs/nginx.crt;@ssl_certificate /etc/dehydrated/certs/$domain_alias/fullchain.pem;@g" -i /etc/nginx/sites-available/fusionpbx
sed "s@ssl_certificate_key     /etc/ssl/private/nginx.key;@ssl_certificate_key /etc/dehydrated/certs/$domain_alias/privkey.pem;@g" -i /etc/nginx/sites-available/fusionpbx

#read the config
/usr/sbin/nginx -t && /usr/sbin/nginx -s reload

#setup freeswitch tls
if [ .$switch_tls = ."true" ]; then

	#make sure the freeswitch directory exists
	mkdir -p /etc/freeswitch/tls

	#make sure the freeswitch certificate directory is empty
	rm /etc/freeswitch/tls/*

	#combine the certs into all.pem
	cat /etc/dehydrated/certs/$domain_alias/fullchain.pem > /etc/dehydrated/certs/$domain_alias/all.pem
	cat /etc/dehydrated/certs/$domain_alias/privkey.pem >> /etc/dehydrated/certs/$domain_alias/all.pem

	#link the certificates
	ln -s /etc/dehydrated/certs/$domain_alias/cert.pem /etc/freeswitch/tls
	ln -s /etc/dehydrated/certs/$domain_alias/chain.pem /etc/freeswitch/tls
	ln -s /etc/dehydrated/certs/$domain_alias/fullchain.pem /etc/freeswitch/tls
	ln -s /etc/dehydrated/certs/$domain_alias/privkey.pem /etc/freeswitch/tls
	ln -s /etc/dehydrated/certs/$domain_alias/all.pem /etc/freeswitch/tls

	#add extra symbolic links
	ln -s /etc/dehydrated/certs/$domain_alias/all.pem /etc/freeswitch/tls/agent.pem
	ln -s /etc/dehydrated/certs/$domain_alias/all.pem /etc/freeswitch/tls/tls.pem
	ln -s /etc/dehydrated/certs/$domain_alias/all.pem /etc/freeswitch/tls/wss.pem
	ln -s /etc/dehydrated/certs/$domain_alias/all.pem /etc/freeswitch/tls/dtls-srtp.pem

	#set the permissions
	chmod 750 /etc/dehydrated/certs/$domain_alias /etc/dehydrated/certs
	chmod 640 /etc/dehydrated/certs/$domain_alias/*
	chown -h www-data:www-data /etc/freeswitch/tls/*

	# install cron script
	cp ./letsencrypt/letsencrypt-cron.sh /usr/local/sbin
	chmod 754 /usr/local/sbin/letsencrypt-cron.sh
	cron="0 9 * * mon /usr/local/sbin/letsencrypt-cron.sh >/dev/null"
	(crontab -l 2>/dev/null; echo "$cron") | crontab -

fi
