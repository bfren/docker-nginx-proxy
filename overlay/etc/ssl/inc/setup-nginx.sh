#!/usr/bin/with-contenv bash

#======================================================================================================================
# Set up Nginx
#   $1  (string) Domain name
#   $2  (string) Upstream URL
#   $3  (string) Name of Domain Aliases array
#   $4  (string) Blank (regenerate) or 'custom' (keep) Nginx configuration file
#======================================================================================================================

setup_nginx () {

    # give arguments friendly names
    export IS_DEFAULT=${1}
    export DOMAIN_NAME=${2}
    export UPSTREAM=${3}
    local DOMAIN_ALIASES=${4}
    export DOMAIN_NGXCONF=${5}

    # paths to site configuration and custom config directory
    local SITE="${SITES}/${DOMAIN_NAME}"
    local CONF="${SITE}.conf"
    export CUSTOM_CONF="${SITE}.d"

    # check for custom site configuration directory
    [[ ! -d ${CUSTOM_CONF} ]] && mkdir ${CUSTOM_CONF}

    # check for existing configuration file
    if [ -f ${CONF} ] ; then

        # if empty, remove config so it can be regenerated
        if [ -z "${DOMAIN_NGXCONF}" ] ; then
            bcg-echo "    removing and regnerating Nginx configuration"
            rm ${CONF}

        # otherwise, leave file (allows custom config)
        else
            bcg-echo "    keeping existing configuration."
            return 0
        fi

    else

        # no need to do anything, be a good log citizen
        bcg-echo "    generating default Nginx configuration"

    fi

    # build domain list and remove trailing / multiple spaces between domains
    TMP="${DOMAIN_NAME}$(printf " %s" ${DOMAIN_ALIASES})"
    export SERVER_NAMES=$(echo "${TMP}" | xargs)

    # generate site configuration
    if [ "${IS_DEFAULT}" = "1" ] ; then
        NGINX_CONF="default"
    else
        NGINX_CONF="site"
    fi

    esh -s /bin/bash \
        -o ${CONF} \
        ${TEMPLATES}/nginx-${NGINX_CONF}.conf.esh

}
