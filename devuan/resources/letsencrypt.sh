#!/bin/sh

#move to script directory so all relative paths work
cd "$(dirname "$0")"

#includes
. ./config.sh
. ./colors.sh
. ./environment.sh

#request the domain and email
read -p 'Domain Name: ' domain_name
read -p 'Email Address: ' email_address
#domain_name=subdomain.domain.com
#email=username@domain.com

#remove previous install
rm -R /opt/letsencrypt
rm -R /etc/letsencrypt

#use php version 5 for arm
if [ .$cpu_architecture = .'arm' ]; then
        php_version=5
fi

#enable fusionpbx nginx config
cp nginx/fusionpbx /etc/nginx/sites-available/fusionpbx

#prepare socket name
if [ ."$php_version" = ."5" ]; then
        sed -i /etc/nginx/sites-available/fusionpbx -e 's#unix:.*;#unix:/var/run/php5-fpm.sock;#g'
fi
if [ ."$php_version" = ."7" ]; then
        sed -i /etc/nginx/sites-available/fusionpbx -e 's#unix:.*;#unix:/var/run/php/php7.0-fpm.sock;#g'
fi
ln -s /etc/nginx/sites-available/fusionpbx /etc/nginx/sites-enabled/fusionpbx

#read the config
/usr/sbin/nginx -t && /usr/sbin/nginx -s reload

#install letsencrypt
git clone https://github.com/letsencrypt/letsencrypt /opt/letsencrypt
chmod 755 /opt/letsencrypt/certbot-auto
/opt/letsencrypt/./certbot-auto
mkdir -p /etc/letsencrypt/configs
mkdir -p /var/www/letsencrypt/

#cd $pwd
#cd "$(dirname "$0")"

#copy the domain conf
cp letsencrypt/domain_name.conf /etc/letsencrypt/configs/$domain_name.conf

#update the domain_name and email_address
sed "s#{domain_name}#$domain_name#g" -i /etc/letsencrypt/configs/$domain_name.conf
sed "s#{email_address}#$email_address#g" -i /etc/letsencrypt/configs/$domain_name.conf

#letsencrypt
#sed "s@#letsencrypt@location /.well-known/acme-challenge { root /var/www/letsencrypt; }@g" -i /etc/nginx/sites-available/fusionpbx

#get the certs from letsencrypt
cd /opt/letsencrypt && ./letsencrypt-auto --config /etc/letsencrypt/configs/$domain_name.conf certonly

#update nginx config
sed "s@ssl_certificate         /etc/ssl/certs/nginx.crt;@ssl_certificate /etc/letsencrypt/live/$domain_name/fullchain.pem;@g" -i /etc/nginx/sites-available/fusionpbx
sed "s@ssl_certificate_key     /etc/ssl/private/nginx.key;@ssl_certificate_key /etc/letsencrypt/live/$domain_name/privkey.pem;@g" -i /etc/nginx/sites-available/fusionpbx

#read the config
/usr/sbin/nginx -t && /usr/sbin/nginx -s reload

#combine the certs into all.pem
cat /etc/letsencrypt/live/$domain_name/cert.pem > /etc/letsencrypt/live/$domain_name/all.pem
cat /etc/letsencrypt/live/$domain_name/privkey.pem >> /etc/letsencrypt/live/$domain_name/all.pem
cat /etc/letsencrypt/live/$domain_name/chain.pem >> /etc/letsencrypt/live/$domain_name/all.pem

#copy the certs to the switch tls directory
mkdir -p /etc/freeswitch/tls
cp /etc/letsencrypt/live/$domain_name/*.pem /etc/freeswitch/tls
cp /etc/freeswitch/tls/all.pem /etc/freeswitch/tls/wss.pem
chown -R www-data:www-data /etc/freeswitch
