#!/usr/bin/with-contenv bash

#======================================================================================================================
# Define directories
#======================================================================================================================

SSL=/ssl
SSL_CERTS=${SSL}/certs
NGINX_SITES=/sites
ACME_CHALLENGE=/www/.well-known/acme-challenge

[[ ! -d ${SSL_CERTS} ]] && mkdir ${SSL_CERTS}
