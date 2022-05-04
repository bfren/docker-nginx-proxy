#!/bin/bash


#======================================================================================================================
# Check JSON configuration file exists.
#======================================================================================================================

SSL_CONF=${PROXY_SSL}/conf.json
if [ ! -f ${SSL_CONF} ] ; then

    # if a <=v3 bash configuration file doesn't exist either, exit with an error
    OLD_SSL_CONF=${PROXY_SSL}/conf.sh
    if [ ! -f ${OLD_SSL_CONF} ] ; then
        bf-error "You must create ${SSL_CONF} - see ssl-conf-sample.json." "inc/proxy-load-conf.sh"
        exit 1
    fi

    # attempt to create the JSON configuration file from a <=v3 bash configuration file
    ${PROXY_LIB}/convert "${OLD_SSL_CONF}" "${SSL_CONF}"

fi


#======================================================================================================================
# Load JSON and create DOMAINS array by selecting primary keys.
#======================================================================================================================

CONF_JSON=`cat "${SSL_CONF}" | jq '.'`

declare -a DOMAINS=(`jq -r '.domains[].primary' <<< "${CONF_JSON}"`)
