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

JSON=`cat "${SSL_CONF}" | gojq '.'`

declare -a DOMAINS=(`gojq -r '.domains[].primary' <<< "${JSON}"`)


#======================================================================================================================
# Gets a domain object from the JSON configuration.
#
# Arguments
#   1   Primary domain name to select
#======================================================================================================================

function get-domain() { gojq --arg PRIMARY "${1}" '.domains[] | select(.primary == $PRIMARY)' <<< "${JSON}" ; }

function get-upstream() { get-domain "${1}" | gojq -r '.upstream' ; }
function get-aliases() { get-domain "${1}" | gojq -r '.aliases[]?' ; }
function get-custom() { get-domain "${1}" | gojq -r '.custom == true' ; }
