FROM bcgdesign/nginx:alpine3.13-2.0.4

LABEL maintainer="Ben Green <ben@bcgdesign.com>" \
    org.label-schema.name="Nginx Proxy" \
    org.label-schema.version="latest" \
    org.label-schema.vendor="Ben Green" \
    org.label-schema.schema-version="1.0"

# port 80 is already exposed by the base image
EXPOSE 443

ENV \
    PROXY_URI= \
    # clean all config and certificates before doing anything else
    PROXY_CLEAN_INSTALL=0 \
    # used for renewal notification emails
    PROXY_LETS_ENCRYPT_EMAIL= \
    # the base URI of the proxy server (will be used when SSL bindings fail)
    # set to 1 to use live instead of staging server
    PROXY_LETS_ENCRYPT_LIVE=0 \
    # set to the number of bits to use for generating private key
    PROXY_SSL_KEY_BITS=4096 \
    # set to the number of bits to use for generating DHPARAM
    PROXY_SSL_DHPARAM_BITS=4096 \
    # canonical domain name redirection
    PROXY_SSL_REDIRECT_TO_CANONICAL=0 \
    # set to true to skip local HTTP token check
    PROXY_GETSSL_SKIP_HTTP_TOKEN_CHECK="false"

COPY ./overlay /

RUN bcg-install

VOLUME [ "/ssl", "/sites" ]
