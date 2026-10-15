#!/bin/sh

# FusionPBX - Install
# Mark J Crane <markjcrane@fusionpbx.com>
# Copyright (C) 2018
# All Rights Reserved.
#
# This is an alternative to letsencrypt.sh, it uses certbot instead of
# dehydrated to issue the Let's Encrypt certificate.

#move to script directory so all relative paths work
cd "$(dirname "$0")" || exit 1

#includes
. ../config.sh
. ../colors.sh

#certbot paths
certbot_bin=/usr/bin/certbot
certbot_live=/etc/letsencrypt/live
certbot_webroot=/var/www/certbot
certbot_hooks=/etc/letsencrypt/renewal-hooks/deploy
nginx_config=/etc/nginx/sites-available/fusionpbx

#send a message
verbose "Installing the Let's Encrypt certificate using certbot"

#add dependencies
apt-get update
apt-get install -y certbot curl

#remove a previous webroot so the script can be re-run
rm -rf "$certbot_webroot"

#use the configured domain name as the default when it is not a placeholder
default_domain=""
if [ "$domain_name" != "ip_address" ] && [ "$domain_name" != "hostname" ]; then
	default_domain="$domain_name"
fi

#request the domain name (press enter without a domain name to skip)
printf "Domain Name [%s]: " "$default_domain"
read -r domain_name
[ -z "$domain_name" ] && domain_name="$default_domain"
if [ -z "$domain_name" ]; then
	verbose "Skipping the Let's Encrypt certificate, keeping the self signed certificate."
	exit 0
fi

#request the email address
printf "Email Address: "
read -r email_address
if ! echo "$email_address" | grep -Eq '^[^@ ]+@[^@ ]+\.[^@ ]+$'; then
	error "A valid email address is required for the Let's Encrypt account: $email_address"
	exit 1
fi

#wildcard detection (a certificate for *.domain.com)
wildcard_domain=false
case "$domain_name" in
	\*.* | \* )
		wildcard_domain=true
		#remove the wildcard and the period
		domain_name=$(echo "$domain_name" | cut -c3-)
		;;
esac

#validate the domain name
case "$domain_name" in
	'' | *[!a-zA-Z0-9.-]* )
		error "The domain name is not valid: $domain_name"
		exit 1
		;;
esac

#reject ip addresses
ip_check=$(echo "$domain_name" | tr -cd '0-9.')
if [ "$ip_check" = "$domain_name" ]; then
	error "Let's Encrypt only issues certificates for domain names, an ip address cannot be used: $domain_name"
	exit 1
fi

#set the domain alias (lower case, used for the certificate folder name)
domain_alias=$(echo "$domain_name" | head -n1 | cut -d " " -f1 | tr "A-Z" "a-z")

#set the certificate name, wildcard certificates are stored under *.domain.com
if [ "$wildcard_domain" = "true" ]; then
	cert_name="*.$domain_alias"
else
	cert_name="$domain_alias"
fi
cert_dir="$certbot_live/$cert_name"

#prepare the webroot, the nginx config serves the challenge folder from /var/www/dehydrated
mkdir -p /var/www/dehydrated
mkdir -p "$certbot_webroot/.well-known"
ln -sfn /var/www/dehydrated "$certbot_webroot/.well-known/acme-challenge"

#deploy hook - refresh the certificates after a renewal
mkdir -p "$certbot_hooks"
cat > "$certbot_hooks/fusionpbx.sh" <<'EOF'
#!/bin/sh
#called by certbot after a certificate is renewed
alias=$1
cert_dir=/etc/letsencrypt/live/$alias
#test and reload nginx
if /usr/sbin/nginx -t; then
	/usr/sbin/nginx -s reload
fi
#refresh the FreeSWITCH TLS certificates
if [ -d /etc/freeswitch/tls ] && [ -f "$cert_dir/fullchain.pem" ] && [ -f "$cert_dir/privkey.pem" ]; then
	#combine the certificate and key into all.pem
	cat "$cert_dir/fullchain.pem" > /etc/freeswitch/tls/all.pem
	cat "$cert_dir/privkey.pem" >> /etc/freeswitch/tls/all.pem
	chmod 640 /etc/freeswitch/tls/all.pem
	#copy the certificates
	cp -f "$cert_dir/cert.pem" /etc/freeswitch/tls
	cp -f "$cert_dir/chain.pem" /etc/freeswitch/tls
	cp -f "$cert_dir/fullchain.pem" /etc/freeswitch/tls
	cp -f "$cert_dir/privkey.pem" /etc/freeswitch/tls
	chmod 640 /etc/freeswitch/tls/privkey.pem
	#set the permissions
	chown -R www-data:www-data /etc/freeswitch/tls
	#reload FreeSWITCH so it picks up the new certificates
	for pid_file in /var/run/freeswitch/freeswitch.pid /usr/local/freeswitch/run/freeswitch.pid; do
		if [ -f "$pid_file" ]; then
			kill -HUP "$(cat "$pid_file")" 2>/dev/null
			break
		fi
	done
fi
EOF
chmod 755 "$certbot_hooks/fusionpbx.sh"

#check that nginx is running so the http-01 challenge can be validated
if [ "$wildcard_domain" = "false" ] && ! curl -s -o /dev/null http://127.0.0.1/; then
	warning "nginx does not appear to be listening on port 80, the http-01 challenge may fail."
fi

#request the certificate
if [ "$wildcard_domain" = "true" ]; then
	warning "A wildcard certificate requires a DNS TXT record."
	warning "certbot will show the record to add, create it in your DNS, then press enter."
	warning "Wildcard certificates cannot be renewed automatically."
	warning "Renew them by running this script again before the certificate expires."
	"$certbot_bin" certonly --manual --preferred-challenges dns-01 -d "*.$domain_alias" -m "$email_address" --agree-tos
else
	"$certbot_bin" certonly --webroot -w "$certbot_webroot" -d "$domain_alias" -m "$email_address" --agree-tos --non-interactive
fi

#check the certificate was issued
if [ ! -f "$cert_dir/fullchain.pem" ] || [ ! -f "$cert_dir/privkey.pem" ]; then
	error "The certificate was not issued, check the certbot output above."
	exit 1
fi
verbose "The certificate for $cert_name was issued"

#update the nginx certificate paths
sed -i "s@ssl_certificate[[:space:]]\+/etc/ssl/certs/nginx.crt;@ssl_certificate $cert_dir/fullchain.pem;@" "$nginx_config"
sed -i "s@ssl_certificate_key[[:space:]]\+/etc/ssl/private/nginx.key;@ssl_certificate_key $cert_dir/privkey.pem;@" "$nginx_config"

#test and reload nginx
if /usr/sbin/nginx -t; then
	/usr/sbin/nginx -s reload
	verbose "nginx was reloaded with the new certificate"
else
	error "The nginx config is invalid, check $nginx_config"
	exit 1
fi

#setup the FreeSWITCH TLS certificates
if [ "$switch_tls" = "true" ]; then

	#make sure the freeswitch directory exists
	mkdir -p /etc/freeswitch/tls

	#remove the old certificates
	rm -f /etc/freeswitch/tls/*.pem

	#combine the certificate and key into all.pem
	cat "$cert_dir/fullchain.pem" > /etc/freeswitch/tls/all.pem
	cat "$cert_dir/privkey.pem" >> /etc/freeswitch/tls/all.pem
	chmod 640 /etc/freeswitch/tls/all.pem

	#copy the certificates
	cp -f "$cert_dir/cert.pem" /etc/freeswitch/tls
	cp -f "$cert_dir/chain.pem" /etc/freeswitch/tls
	cp -f "$cert_dir/fullchain.pem" /etc/freeswitch/tls
	cp -f "$cert_dir/privkey.pem" /etc/freeswitch/tls
	chmod 640 /etc/freeswitch/tls/privkey.pem

	#add symbolic links
	ln -sf /etc/freeswitch/tls/all.pem /etc/freeswitch/tls/agent.pem
	ln -sf /etc/freeswitch/tls/all.pem /etc/freeswitch/tls/tls.pem
	ln -sf /etc/freeswitch/tls/all.pem /etc/freeswitch/tls/wss.pem
	ln -sf /etc/freeswitch/tls/all.pem /etc/freeswitch/tls/dtls-srtp.pem

	#set the permissions
	chown -R www-data:www-data /etc/freeswitch/tls

	#reload FreeSWITCH so it picks up the new certificates
	for pid_file in /var/run/freeswitch/freeswitch.pid /usr/local/freeswitch/run/freeswitch.pid; do
		if [ -f "$pid_file" ]; then
			kill -HUP "$(cat "$pid_file")" 2>/dev/null
			break
		fi
	done
fi

#enable the certbot renewal timer (ships with the certbot package)
if command -v systemctl >/dev/null 2>&1; then
	systemctl enable certbot.timer
	systemctl start certbot.timer
fi
verbose "The certificates will be renewed automatically daily by certbot.timer"
verbose "The certificate for $cert_name is installed"
