#!/bin/bash


#======================================================================================================================
# Check JSON configuration file exists.
#======================================================================================================================

if [ ! -f "${PROXY_SSL_CONF}" ] ; then
    bf-error "You must create ${PROXY_SSL_CONF} - see ssl-conf-sample.json." "inc/proxy-load-conf.sh"
    exit 1
fi


#======================================================================================================================
# Load JSON and create DOMAINS array by selecting primary keys.
#======================================================================================================================

JSON=`cat "${PROXY_SSL_CONF}" | jq '.'`

declare -a DOMAINS=(`jq -r '.domains[].primary' <<< "${JSON}"`)


#======================================================================================================================
# Gets a domain object from the JSON configuration.
#
# Arguments
#   1   Primary domain name to select
#======================================================================================================================

function get-domain() { jq --arg PRIMARY "${1}" '.domains[] | select(.primary == $PRIMARY)' <<< "${JSON}" ; }

function get-upstream() { get-domain "${1}" | jq -r '.upstream' ; }
function get-aliases() { get-domain "${1}" | jq -r '.aliases[]?' ; }
function get-custom() { get-domain "${1}" | jq -r '.custom == true' ; }
