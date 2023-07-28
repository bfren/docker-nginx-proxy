#!/bin/bash


#======================================================================================================================
# Initialise Nginx and SSL configuration for proxy domain.
#======================================================================================================================

init-proxy () {

    bf-echo "  . Nginx..." "inc/proxy-init-domain.sh"
    setup-nginx 1 ${PROXY_URI} "http://localhost" ""

    bf-echo "  . SSL..." "inc/proxy-init-domain.sh"
    setup-ssl ${PROXY_URI} ""

}


#======================================================================================================================
# Initialise Nginx and SSL configuration for a domain.
#
# Arguments
#   1   Domain name
#======================================================================================================================

init-domain () {

    # get domain configuration values
    PRIMARY_DOMAIN=${1}
    UPSTREAM_SERVER=`get-upstream ${PRIMARY_DOMAIN}`
    DOMAIN_ALIASES=`get-aliases ${PRIMARY_DOMAIN}`
    CUSTOM_NGINX_CONFIG=`get-custom ${PRIMARY_DOMAIN}`

    # add default Nginx configuration
    bf-echo "  . Nginx..." "inc/proxy-init-domain.sh"
    setup-nginx 0 ${PRIMARY_DOMAIN} ${UPSTREAM_SERVER} "${DOMAIN_ALIASES}" ${CUSTOM_NGINX_CONFIG}

    # add default SSL files
    bf-echo "  . SSL..." "inc/proxy-init-domain.sh"
    setup-ssl ${PRIMARY_DOMAIN} "${DOMAIN_ALIASES}"

}
