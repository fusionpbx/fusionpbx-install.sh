
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

#get and install dehydrated
pkg install dehydrated
#cd /usr/src && git clone https://github.com/lukas2511/dehydrated.git
#cd /usr/src/dehydrated
#cp dehydrated /usr/local/sbin
#mkdir -p /usr/local/www/dehydrated
#mkdir -p /usr/local/etc/dehydrated/certs

#wildcard detection
wilcard_domain=$(echo $domain_name | cut -c1-1)
if [ "$wilcard_domain" = "*" ]; then
	wilcard_domain="true"
else
	wilcard_domain="false"
fi

#remove the wildcard and period
if [ .$wilcard_domain = ."true" ]; then
	domain_name=$(echo "$domain_name" | cut -c3-255)
fi

#manual dns hook
if [ .$wilcard_domain = ."true" ]; then
	if [ ! -f /usr/local/etc/dehydrated/hook.sh]; then
		cd /usr/src
		git clone https://github.com/owhen/dns-01-manual.git
		cd /usr/src/dns-01-manual/
		cp hook.sh /usr/local/etc/dehydrated/hook.sh
		chmod 755 /usr/local/etc/dehydrated/hook.sh
	fi
fi

#update the dehydrated config
sed -i ' ' -e "s/#CONTACT_EMAIL=/CONTACT_EMAIL=$email_address/g" /usr/local/etc/dehydrated/config
sed -i ' ' -e "s/#WELLKNOWN=/WELLKNOWN=/g" /usr/local/etc/dehydrated/config

#accept the terms
dehydrated --register --accept-terms --config /usr/local/etc/dehydrated/config

#set the domain alias
domain_alias=$(echo "$domain_name" | head -n1 | cut -d " " -f1)

#create an alias when using wildcard dns
if [ .$wilcard_domain = ."true" ]; then
	echo "*.$domain_name > $domain_name" > /usr/local/etc/dehydrated/domains.txt
fi

#add the domain name to domains.txt
if [ .$wilcard_domain = ."false" ]; then
	echo "$domain_name" > /usr/local/etc/dehydrated/domains.txt
fi

#request the certificates
if [ .$wilcard_domain = ."true" ]; then
	dehydrated --cron --domain *.$domain_name --alias $domain_alias --preferred-chain "ISRG Root X1" --algo rsa --config /usr/local/etc/dehydrated/config --out /usr/local/etc/dehydrated/certs --challenge dns-01 --hook /usr/local/etc/dehydrated/hook.sh
fi
if [ .$wilcard_domain = ."false" ]; then
	dehydrated --cron --alias $domain_alias --preferred-chain "ISRG Root X1" --algo rsa --config /usr/local/etc/dehydrated/config --out /usr/local/etc/dehydrated/certs --challenge http-01
fi

#remove the old backups
rm -f /usr/local/etc/nginx/server.crt.backup
rm -f /usr/local/etc/nginx/server.key.backup

#nginx config - backup the original certificates and copy the news ones for nginx
if [ -e /usr/local/etc/nginx/server.crt]; then
	mv /usr/local/etc/nginx/server.crt /usr/local/etc/nginx/server.crt.backup
fi
if [ -e /usr/local/etc/nginx/server.key]; then
	mv /usr/local/etc/nginx/server.key /usr/local/etc/nginx/server.key.backup
fi
ln -s /usr/local/etc/dehydrated/certs/$domain_alias/fullchain.pem /usr/local/etc/nginx/server.crt
ls -s /usr/local/etc/dehydrated/certs/$domain_alias/privkey.pem /usr/local/etc/nginx/server.key
#cp /usr/local/etc/dehydrated/certs/$domain_alias/fullchain.pem /usr/local/etc/nginx/server.crt
#cp /usr/local/etc/dehydrated/certs/$domain_alias/privkey.pem /usr/local/etc/nginx/server.key

#read the config
/usr/local/sbin/nginx -t && /usr/local/sbin/nginx -s reload

#setup freeswitch tls
if [ .$switch_tls = ."true" ]; then
	#make sure the freeswitch directory exists
	mkdir -p /usr/local/etc/freeswitch/tls

	#make sure the freeswitch certificate directory is empty
	rm /usr/local/etc/freeswitch/tls/*

	#combine the certs into all.pem
	cat /usr/local/etc/dehydrated/certs/$domain_alias/fullchain.pem > /usr/local/etc/freeswitch/tls/all.pem
	cat /usr/local/etc/dehydrated/certs/$domain_alias/privkey.pem >> /usr/local/etc/freeswitch/tls/all.pem
	#cat /usr/local/etc/dehydrated/certs/$domain_alias/chain.pem >> /usr/local/etc/freeswitch/tls/all.pem

	#copy the certificates
	ln -s /usr/local/etc/dehydrated/certs/$domain_alias/cert.pem /usr/local/etc/freeswitch/tls/cert.pem
	ln -s /usr/local/etc/dehydrated/certs/$domain_alias/chain.pem /usr/local/etc/freeswitch/tls/chain.pem
	ln -s /usr/local/etc/dehydrated/certs/$domain_alias/fullchain.pem /usr/local/etc/freeswitch/tls/fullchain.pem
	ln -s /usr/local/etc/dehydrated/certs/$domain_alias/privkey.pem /usr/local/etc/freeswitch/tls/privkey.pem
	#cp /usr/local/etc/dehydrated/certs/$domain_alias/cert.pem /usr/local/etc/freeswitch/tls
	#cp /usr/local/etc/dehydrated/certs/$domain_alias/chain.pem /usr/local/etc/freeswitch/tls
	#cp /usr/local/etc/dehydrated/certs/$domain_alias/fullchain.pem /usr/local/etc/freeswitch/tls
	#cp /usr/local/etc/dehydrated/certs/$domain_alias/privkey.pem /usr/local/etc/freeswitch/tls

	#add symbolic links
	ln -s /usr/local/etc/freeswitch/tls/all.pem /usr/local/etc/freeswitch/tls/agent.pem
	ln -s /usr/local/etc/freeswitch/tls/all.pem /usr/local/etc/freeswitch/tls/tls.pem
	ln -s /usr/local/etc/freeswitch/tls/all.pem /usr/local/etc/freeswitch/tls/wss.pem
	ln -s /usr/local/etc/freeswitch/tls/all.pem /usr/local/etc/freeswitch/tls/dtls-srtp.pem

	#set the permissions
	chown -R www:www /usr/local/etc/freeswitch/tls
fi
