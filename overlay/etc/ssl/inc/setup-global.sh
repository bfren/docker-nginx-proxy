#!/usr/bin/with-contenv bash

#======================================================================================================================
# Set up global configuration
#======================================================================================================================

setup_global () {

    if [ ! -f ${SSL_GLOBAL_CFG} ] ; then
        echo " - creating global configuration..."
        gomplate \
            -o ${SSL_GLOBAL_CFG} \
            -f ${TEMPLATES}/global.conf.tmpl
        echo " - done."
    fi

    if [ ! -f ${SSL_DHPARAM} ] ; then
        echo " - generating dhparam..."
        openssl dhparam -out ${SSL_DHPARAM} 2048
        echo " - done."
    fi

}
