#!/usr/bin/env bash

### generate squid cert
cd ssl && \
openssl req -new -newkey rsa:2048 \
	-sha256 \
	-days 365 \
	-nodes -x509 \
	-extensions v3_ca \
	-keyout squid-ca-key.pem \
	-out squid-ca-cert.pem && \
cat squid-ca-cert.pem squid-ca-key.pem >> squid-ca-cert-key.pem

### move squid cert
sudo mkdir -p /etc/squid/certs/
sudo mv ./squid-ca-cert-key.pem /etc/squid/certs/
sudo chown -R squid:root /etc/squid/certs/

### add settings to config
read -r -d '' settings <<HERE
http_port 8888 ssl-bump \
  cert=/etc/squid/certs/squid-ca-cert-key.pem \
  generate-host-certificates=on dynamic_cert_mem_cache_size=16MB
https_port 9999 intercept ssl-bump \
  cert=/etc/squid/certs/squid-ca-cert-key.pem \
  generate-host-certificates=on dynamic_cert_mem_cache_size=16MB
sslcrtd_program /usr/lib64/squid/security_file_certgen -s /var/lib/ssl_db -M 16MB
HERE
echo "TODO"

### generate ssl_db
/usr/lib64/squid/security_file_certgen -c -s /var/lib/ssl_db -M 16MB
sudo chown -R squid:root /var/lib/ssl_db/

sudo squid -k parse | less

### add cert to browser authorities
echo "add 'squid-ca-cert-key.pem' to browser authorities"
