# no default SSL in centos, generate a tmp certificate
# ssl_certificate         /etc/ssl/certs/nginx.crt;
# ssl_certificate_key     /etc/ssl/private/nginx.key;

DOMAIN=$(hostname)
SSL_DIR="/etc/ssl"

SUBJ="
C=US
ST=Idaho
O=FusionPBX
localityName=Boise
commonName=$DOMAIN
organizationUnitName=
emailAddress=
"

mkdir -p $SSL_DIR/private && mkdir -p $SSL_DIR/certs
chmod 700 $SSL_DIR/private

openssl req -x509 -nodes -subj "$(echo -n "$SUBJ" | tr "\n" "/")" -days 365 -newkey rsa:2048 -keyout "$SSL_DIR/private/nginx.key" -out "$SSL_DIR/certs/nginx.crt"

