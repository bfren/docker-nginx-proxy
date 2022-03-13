#!/bin/bash


#======================================================================================================================
# Create arrays and include configuration.
#======================================================================================================================

SSL_CONF=${PROXY_SSL}/conf.sh
if [ ! -f ${SSL_CONF} ] ; then
    bf-error "You must create ${SSL_CONF} - see ssl-conf-sample.sh." "inc/proxy-load-conf.sh"
    exit 1
fi

declare -A DOMAINS
declare -A ALIASES
declare -A NGXCONF

source ${SSL_CONF}
