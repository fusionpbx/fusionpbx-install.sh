#!/bin/sh

domain_name=subdomain.domain.com
email=username@domain.com

rm -R /opt/letsencrypt
git clone https://github.com/letsencrypt/letsencrypt /opt/letsencrypt
chmod 755 /opt/letsencrypt/certbot-auto
/opt/letsencrypt/./certbot-auto
mkdir -p /etc/letsencrypt/configs

#cd $pwd
#cd "$(dirname "$0")"

cp letsencrypt/domain_name.conf /etc/letsencrypt/configs/$domain_name.conf

sed 's#{domain_name}#$domain_name#g' -i /etc/letsencrypt/configs/$domain_name.conf
sed 's#{email_address}#$email#g' -i /etc/letsencrypt/configs/$domain_name.conf
