#!/usr/bin/with-contenv bash

#======================================================================================================================
# Set up global configuration
#======================================================================================================================

setup_global () {

    if [ ! -f ${SSL_GLOBAL_CFG} ] ; then
        _echo " - creating global configuration file..."
        gomplate \
            -o ${SSL_GLOBAL_CFG} \
            -f ${TEMPLATES}/global.conf.tmpl
        _done
    fi

    if [ ! -f ${SSL_DHPARAM} ] ; then
        _echo " - generating dhparam..."
        openssl dhparam -out ${SSL_DHPARAM} 2048
        _done
    fi

}