#!/usr/bin/with-contenv bash

#======================================================================================================================
# Ensure PROXY_URI is set
#======================================================================================================================

if [ -z "${PROXY_URI}" ] ; then
    bcg-error "PROXY_URI must be set before requesting SSL certificates."
    exit 1
fi


#======================================================================================================================
# Ensure email is set
#======================================================================================================================

if [ -z "${LETS_ENCRYPT_EMAIL}" ] ; then
    bcg-error "LETS_ENCRYPT_EMAIL must be set before requesting SSL certificates."
    exit 1
fi


#======================================================================================================================
# Create arrays and include configuration
#======================================================================================================================

SSL_CONF=${SSL}/conf.sh
if [ ! -f ${SSL_CONF} ] ; then
    bcg-error "You must create ${SSL_CONF} - see ssl-conf-sample.sh."
    exit 1
fi

declare -A DOMAINS
declare -A ALIASES
declare -A NGXCONF

source ${SSL_CONF}


#======================================================================================================================
# Check whether or not domains have been registered
#======================================================================================================================

if [ "${#DOMAINS[@]}" = "0" ] ; then
    bcg-error "No domains have been registered for SSL - please add them to /ssl/conf.sh."
    exit 1
fi


#======================================================================================================================
# Ensure certs directory exists
#======================================================================================================================

[[ ! -d ${SSL_CERTS} ]] && mkdir ${SSL_CERTS}
