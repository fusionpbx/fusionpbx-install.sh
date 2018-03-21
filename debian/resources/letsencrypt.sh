#!/bin/sh

#move to script directory so all relative paths work
cd "$(dirname "$0")"

#includes
. ./config.sh
#. ./colors.sh
. ./environment.sh

#request the domain and email
read -p 'Domain Name: ' domain_name
read -p 'Email Address: ' email_address
#domain_name=subdomain.domain.com
#email=username@domain.com

cd /usr/src && git clone https://github.com/lukas2511/dehydrated.git
cd /usr/src/dehydrated
cp dehydrated /usr/local/sbin
mkdir -p /var/www/dehydrated
mkdir -p /etc/dehydrated/certs
#echo "$domain_name *.$domain_name" > /etc/dehydrated/domains.txt

#use this for wildcard dns
echo "*.$domain_name > $domain_name" > /etc/dehydrated/domains.txt

#manual dns hook
cd /usr/src
git clone https://github.com/owhen/dns-01-manual.git
cd /usr/src/dns-01-manual/
cp hook.sh /etc/dehydrated/hook.sh

mkdir -p /etc/nginx/ssl

dehydrated --register --accept-terms

#wildcard domain
dehydrated --cron --challenge dns-01 --hook /etc/dehydrated/hook.sh
#single domain
#dehydrated --cron --challenge http-01

cd /usr/src/dehydrated
cp docs/examples/hook.sh /etc/dehydrated
cp docs/examples/config /etc/dehydrated

#vim /etc/dehydrated/config
sed "s#CONTACT_EMAIL=#CONTACT_EMAIL=$email_address" -i /etc/dehydrated/config

#update nginx config
sed "s@ssl_certificate         /etc/ssl/certs/nginx.crt;@ssl_certificate /etc/dehydrated/certs/$domain_name/fullchain.pem;@g" -i /etc/nginx/sites-available/fusionpbx
sed "s@ssl_certificate_key     /etc/ssl/private/nginx.key;@ssl_certificate_key /etc/dehydrated/certs/$domain_name/privkey.pem;@g" -i /etc/nginx/sites-available/fusionpbx

#read the config
/usr/sbin/nginx -t && /usr/sbin/nginx -s reload

#combine the certs into all.pem
cat /etc/dehydrated/certs/$domain_name/fullchain.pem > /etc/dehydrated/certs/$domain_name/all.pem
cat /etc/dehydrated/certs/$domain_name/privkey.pem >> /etc/dehydrated/certs/$domain_name/all.pem
#cat /etc/dehydrated/certs/$domain_name/chain.pem >> /etc/dehydrated/certs/$domain_name/all.pem

#copy the certs to the switch tls directory
mkdir -p /etc/freeswitch/tls
cp /etc/dehydrated/certs/$domain_name/*.pem /etc/freeswitch/tls
cp /etc/dehydrated/certs/all.pem /etc/freeswitch/tls/wss.pem
chown -R www-data:www-data /etc/freeswitch
