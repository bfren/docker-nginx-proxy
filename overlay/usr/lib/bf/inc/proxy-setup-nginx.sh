#!/usr/bin/with-contenv bash


#======================================================================================================================
# Set up Nginx.
#
# Arguments
#   1   Domain name
#   2   Upstream URL
#   3   Name of Domain Aliases array
#   4   Blank (regenerate) or 'custom' (keep) Nginx configuration file
#======================================================================================================================

setup-nginx () {

    # give arguments friendly names
    export IS_PROXY=${1}
    export DOMAIN_NAME=${2}
    export UPSTREAM=${3}
    local DOMAIN_ALIASES=${4}
    export DOMAIN_NGXCONF=${5}

    # paths to site configuration and custom config directory
    local SITE="${PROXY_SITES}/${DOMAIN_NAME}"
    local CONF="${SITE}.conf"
    export CUSTOM_CONF="${SITE}.d"

    # check for custom site configuration directory
    [[ ! -d ${CUSTOM_CONF} ]] && mkdir ${CUSTOM_CONF}

    # check for existing configuration file
    if [ -f ${CONF} ] ; then

        # if empty, remove config so it can be regenerated
        if [ -z "${DOMAIN_NGXCONF}" ] ; then
            bf-debug "    removing and regnerating Nginx configuration"
            rm ${CONF}

        # otherwise, leave file (allows custom config)
        else
            bf-debug "    keeping existing configuration."
            return 0
        fi

    else

        # no need to do anything, be a good log citizen
        bf-debug "    generating default Nginx configuration"

    fi

    # build domain list and remove trailing / multiple spaces between domains
    export SERVER_NAMES=$(echo "${DOMAIN_NAME} ${DOMAIN_ALIASES}" | xargs)

    # generate site configuration
    if [ "${IS_PROXY}" = "1" ] ; then
        NGINX_CONF="proxy"
    else
        NGINX_CONF="site"
    fi

    # generate config
    bf-esh ${BF_TEMPLATES}/nginx-${NGINX_CONF}.conf.esh ${CONF} > /dev/null 2>&1

}
