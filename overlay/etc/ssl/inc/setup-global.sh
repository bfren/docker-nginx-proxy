#!/usr/bin/with-contenv bash

#======================================================================================================================
# Set up global configuration
#======================================================================================================================

setup_global () {

    if [ ! -f ${SSL_GLOBAL_CFG} ] ; then
        bcg-echo " .. creating global configuration file..."
        esh -o ${SSL_GLOBAL_CFG} \
            ${TEMPLATES}/getssl-global.conf.esh
    fi

    if [ ! -f ${SSL_DHPARAM} ] ; then
        bcg-echo " .. generating dhparam..."
        openssl dhparam -out ${SSL_DHPARAM} ${SSL_DHPARAM_BITS}
    fi

}
