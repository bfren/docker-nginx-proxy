#!/usr/bin/with-contenv bash

#======================================================================================================================
# Set up Nginx
#   $1  (string) Domain name
#   $2  (string) Upstream URL
#   $3  (string) Name of Domain Aliases array
#   $4  (string) Blank (regenerate) or 'custom' (keep) Nginx configuration file
#======================================================================================================================

setup_nginx () {

    export DOMAIN_NAME=${1}
    export UPSTREAM=${2}
    local -n DOMAIN_ALIASES=${3}
    local DOMAIN_NGXCONF=${4}

    local FILE=${SITES}/${DOMAIN_NAME}

    # check for existing configuration file
    if [ -f ${FILE} ] ; then

        # if set, remove config so it can be regenerated
        if [ -n "${DOMAIN_NGXCONF}" ] &&  ; then
            _echo "    removing and regnerating Nginx configuration"
            rm ${FILE}

        # otherwise, leave file (allows custom config)
        else
            _echo "    keeping existing configuration."
            return 0
        fi

    else

        # no need to do anything, be a good log citizen
        _echo "    generating default Nginx configuration"

    fi

    # build domain list and remove trailing / multiple spaces between domains
    TMP="${DOMAIN_NAME}$(printf " %s" ${DOMAIN_ALIASES[@]})"
    export SERVER_NAMES=$(echo "${TMP}" | xargs)

    # generate site configuration
    gomplate \
        -o ${FILE} \
        -f ${TEMPLATES}/site.conf.tmpl

}
