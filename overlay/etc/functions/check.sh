#!/usr/bin/with-contenv bash

#======================================================================================================================
# Ensure email is set
#======================================================================================================================

if [ -z "${LETS_ENCRYPT_EMAIL}" ] ; then
    echo " - LETS_ENCRYPT_EMAIL must be set before requesting SSL certificates."
    exit 1
fi


#======================================================================================================================
# Define directories
#======================================================================================================================

SSL=/ssl
SSL_CERTS=${SSL}/certs
NGINX_SITES=/sites

[[ ! -d ${SSL_CERTS} ]] && mkdir ${SSL_CERTS}

if [ "${SSL_CLEAN_INSTALL}" = "1" ] ; then 
    rm -rf ${SSL_CERTS}/*
    rm -rf ${NGINX_SITES}/*
fi


#======================================================================================================================
# Create arrays and include configuration
#======================================================================================================================

SSL_CONF=${SSL}/conf.sh
if [ ! -f ${SSL_CONF} ] ; then
    echo " - you must create ${SSL_CONF} - see ssl-conf-sample.sh."
    exit 1
fi

declare -A DOMAINS
declare -A ALIASES

source ${SSL_CONF}


#======================================================================================================================
# Check whether or not domains have been registered
#======================================================================================================================

if [ "${#DOMAINS[@]}" = "0" ] ; then
    echo " - no domains have been registered for SSL."
    exit 1
fi
