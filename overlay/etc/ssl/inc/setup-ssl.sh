#!/usr/bin/with-contenv bash

#======================================================================================================================
# Generate a temporary SSL certificate and key
#   $1  (string) Base path
#   $2  (string) Domain name
#======================================================================================================================

generate_temp_cert () {

    openssl req -newkey rsa:2048 \
        -x509 \
        -sha256 \
        -days 3650 \
        -nodes \
        -out ${1}.crt \
        -keyout ${1}.key \
        -subj "/C=NA/ST=NA/L=NA/O=NA/OU=NA/CN=${2}"

}


#======================================================================================================================
# Set up SSL for a domain
#   $1  (string) Domain name
#   $2  (string) Name of Domain Aliases array
#======================================================================================================================

setup_ssl () {

    local DOMAIN_NAME=${1}
    local -n DOMAIN_ALIASES=${2}
    local FILE=${SSL_CERTS}/${DOMAIN_NAME}/${GETSSL_CFG}

    # check for existing configuration
    [[ -f ${FILE} ]] && return 0 || echo " - SSL..."
    /etc/ssl/getssl -w ${SSL_CERTS} -c ${DOMAIN_NAME}

    # set default values
    local SANS=$(printf ",%s" ${DOMAIN_ALIASES[@]})
    local CERT=${SSL_CERTS}/${DOMAIN_NAME}
    local ACL_DIR="'${WWW_ACME_CHALLENGE}'"
    local ACL_RPT=$((${#DOMAIN_ALIASES[@]} + 1))
    local ACL=$(yes ${ACL_DIR} | head -n ${ACL_RPT} | sed -n 'H;${x;s/\n/ /gp}')

    # replace config values with defaults
    replace "SANS" "${SANS:1}" ${FILE}
    replace "DOMAIN_CERT_LOCATION" "${CERT}.crt" ${FILE}
    replace "DOMAIN_KEY_LOCATION" "${CERT}.key" ${FILE}
    replace_d "ACL" "(${ACL})" ${FILE}

    # create self-signed certificate so nginx will start before we request proper certificates
    generate_temp_cert ${CERT} ${DOMAIN_NAME}
    generate_temp_cert ${CERT}/fullchain ${DOMAIN_NAME}

}
