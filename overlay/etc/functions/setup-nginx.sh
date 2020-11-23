#!/usr/bin/with-contenv bash

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

    export CERTS=${SSL_CERTS}
    local FILE=${NGINX_SITES}/${DOMAIN_NAME}

    # check for existing configuration
    [[ -f ${FILE} ]] && return 0 || echo " - nginx..."

    # setup domain
    export DOMAIN_ALIASES_LIST=$(printf " %s" ${DOMAIN_ALIASES[@]})
    gomplate \
        -o ${FILE} \
        -f /etc/templates/site.conf.tmpl

}
