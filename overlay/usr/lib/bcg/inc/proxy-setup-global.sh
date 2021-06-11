#!/usr/bin/with-contenv bash

#======================================================================================================================
# Set up global configuration.
#======================================================================================================================

setup-global () {

    if [ ! -f ${PROXY_GETSSL_GLOBAL_CFG} ] ; then
        bf-debug " .. creating global configuration file..."
        esh -o ${PROXY_GETSSL_GLOBAL_CFG} \
            ${BCG_TEMPLATES}/getssl-global.conf.esh
    fi

    if [ ! -f ${PROXY_SSL_DHPARAM} ] ; then
        bf-debug " .. generating dhparam..."
        openssl dhparam -out ${PROXY_SSL_DHPARAM} ${PROXY_SSL_DHPARAM_BITS}
    fi

}
