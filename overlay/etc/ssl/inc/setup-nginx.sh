#!/usr/bin/with-contenv bash

set -euo pipefail

#======================================================================================================================
# Set up Nginx
#   $1  (string) Domain name
#   $2  (string) Upstream URL
#   $3  (string) Name of Domain Aliases array
#======================================================================================================================

setup_nginx () {

    export DOMAIN_NAME=${1}
    export UPSTREAM=${2}
    local -n DOMAIN_ALIASES=${3}

    local FILE=${SITES}/${DOMAIN_NAME}

    # check for existing configuration
    [[ -f ${FILE} ]] && return 0 || _echo " - nginx..."

    # build domain list and remove trailing / multiple spaces between domains
    TMP="${DOMAIN_NAME}$(printf " %s" ${DOMAIN_ALIASES[@]})"
    export SERVER_NAMES=$(echo "${TMP}" | xargs)

    # generate site configuration
    gomplate \
        -o ${FILE} \
        -f ${TEMPLATES}/site.conf.tmpl

}
