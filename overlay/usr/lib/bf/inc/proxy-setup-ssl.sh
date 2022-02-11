#!/command/with-contenv bash


#======================================================================================================================
# Generate a temporary SSL certificate and key.
#
# Arguments
#   1   Base path
#   2   Domain name
#======================================================================================================================

generate-temp-cert () {

    openssl req \
        -x509 \
        -sha256 \
        -nodes \
        -days 3650 \
        -newkey rsa:${PROXY_SSL_KEY_BITS} \
        -keyout ${2} \
        -out ${1} \
        -subj "/C=NA/ST=NA/L=NA/O=NA/OU=NA/CN=${3}"

}


#======================================================================================================================
# Create PEM file out of the private key, server certificate, and intermediate certificate.
#
# Arguments
#   1   Domain name
#======================================================================================================================

create-pem () {

    local DOMAIN_NAME=${1}
    local CERT=${PROXY_SSL_CERTS}/${DOMAIN_NAME}
    local PEM=${CERT}/${DOMAIN_NAME}.pem

    cat ${CERT}.key > ${PEM}
    cat ${CERT}/fullchain.crt >> ${PEM}

}


#======================================================================================================================
# Set up SSL for a domain.
#
# Arguments
#   1   Domain name
#   2   String containing Domain Aliases (separated by spaces)
#======================================================================================================================

setup-ssl () {

    local DOMAIN_NAME=${1}
    local DOMAIN_ALIASES=(${2})
    local FILE=${PROXY_SSL_CERTS}/${DOMAIN_NAME}/${PROXY_GETSSL_CFG}

    # check for existing configuration
    [[ -f ${FILE} ]] && bf-debug "    already set up." && return 0

    # getssl flags
    #   -U  stop upgrade checks
    #   -w  set working directory
    #   -c  create default configuration files
    ${PROXY_GETSSL} -U -w ${PROXY_SSL_CERTS} -c ${DOMAIN_NAME}

    # set default values
    local SANS=$(printf ",%s" ${DOMAIN_ALIASES[@]})
    local CERT=${PROXY_SSL_CERTS}/${DOMAIN_NAME}
    local ACL_DIR="'${PROXY_WWW_ACME_CHALLENGE}'"
    local ACL_RPT=$((${#DOMAIN_ALIASES[@]} + 1))
    local ACL=$(yes ${ACL_DIR} | head -n ${ACL_RPT} | sed -n 'H;${x;s/\n/ /gp}')

    # replace config values with defaults
    bf-debug "    replacing configuration value"
    replace "SANS" "${SANS:1}" ${FILE}
    replace "DOMAIN_CERT_LOCATION" "${CERT}.crt" ${FILE}
    replace "DOMAIN_KEY_LOCATION" "${CERT}.key" ${FILE}
    replace-d "ACL" "(${ACL})" ${FILE}

    # create self-signed certificate so nginx will start before we request proper certificates
    bf-debug "    generating temporary SSL certificates"
    generate-temp-cert ${CERT}/fullchain.crt ${CERT}.key ${DOMAIN_NAME}
    generate-temp-cert ${CERT}/chain.crt ${CERT}/chain.key ${DOMAIN_NAME}
    rm ${CERT}/chain.key

    # create pem file
    create-pem "${DOMAIN_NAME}"

}
