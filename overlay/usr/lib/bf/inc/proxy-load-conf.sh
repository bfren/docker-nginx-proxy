#!/bin/bash


#======================================================================================================================
# Check JSON configuration file exists.
#======================================================================================================================

SSL_CONF=${PROXY_SSL}/conf.json
if [ ! -f ${SSL_CONF} ] ; then
    bf-error "You must create ${SSL_CONF} - see ssl-conf-sample.json." "inc/proxy-load-conf.sh"
    exit 1
fi


#======================================================================================================================
# Load JSON and create DOMAINS array by selecting primary keys.
#======================================================================================================================

CONF_JSON=`cat "${SSL_CONF}" | jq '.'`

declare -a DOMAINS=(`jq -r '.domains[].primary' <<< "${CONF_JSON}"`)
