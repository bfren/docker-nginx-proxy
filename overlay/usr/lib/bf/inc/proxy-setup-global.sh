#!/usr/bin/with-contenv bash


#======================================================================================================================
# Set up global configuration.
#======================================================================================================================

setup-global () {

    if [ ! -f ${PROXY_GETSSL_GLOBAL_CFG} ] ; then
        bf-debug " .. creating global configuration file..."
        bf-esh ${BF_TEMPLATES}/getssl-global.conf.esh ${PROXY_GETSSL_GLOBAL_CFG}
    fi

    if [ ! -f ${PROXY_SSL_DHPARAM} ] ; then
        bf-debug " .. generating dhparam..."
        openssl dhparam -out ${PROXY_SSL_DHPARAM} ${PROXY_SSL_DHPARAM_BITS}
    fi

}
