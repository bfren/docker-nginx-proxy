#!/usr/bin/with-contenv bash

#======================================================================================================================
# Ensure email is set
#======================================================================================================================

if [ -z "${LETS_ENCRYPT_EMAIL}" ] ; then
    echo " - LETS_ENCRYPT_EMAIL must be set before requesting SSL certificates."
    exit 1
fi


#======================================================================================================================
# Create arrays and include configuration
#======================================================================================================================

source /etc/getssl/inc/directories.sh

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
