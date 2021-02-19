#!/usr/bin/with-contenv bash

#======================================================================================================================
# Set up global configuration.
#======================================================================================================================

setup-global () {

    if [ ! -f ${PROXY_SSL_GLOBAL_CFG} ] ; then
        bcg-debug " .. creating global configuration file..."
        esh -o ${PROXY_SSL_GLOBAL_CFG} \
            ${TEMPLATES}/getssl-global.conf.esh
    fi

    if [ ! -f ${PROXY_SSL_DHPARAM} ] ; then
        bcg-debug " .. generating dhparam..."
        openssl dhparam -out ${PROXY_SSL_DHPARAM} ${PROXY_SSL_DHPARAM_BITS}
    fi

}
