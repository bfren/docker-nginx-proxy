FROM bcgdesign/nginx:alpine-3.13-1.4.2

LABEL maintainer="Ben Green <ben@bcgdesign.com>" \
    org.label-schema.name="Nginx Proxy" \
    org.label-schema.version="latest" \
    org.label-schema.vendor="Ben Green" \
    org.label-schema.schema-version="1.0"

# port 80 is already exposed by the base image
EXPOSE 443

ENV \
    # used for renewal notification emails
    LETS_ENCRYPT_EMAIL= \
    # the base URI of the proxy server (will be used when SSL bindings fail)
    PROXY_URI= \
    # clean all config and certificates before doing anything else
    CLEAN_INSTALL=0 \
    # set to 1 to use live instead of staging server
    LETS_ENCRYPT_LIVE=0 \
    # set to the number of bits to use for generating DHPARAM
    SSL_DHPARAM_BITS=4096 \
    # canonical domain name redirection
    SSL_REDIRECT_TO_CANONICAL=0 \
    # set to true to skip local HTTP token check
    GETSSL_SKIP_HTTP_TOKEN_CHECK="false"

RUN apk -U upgrade \
    && apk add \
        bash \
        curl \
        openssl \
    && rm -rf /var/cache/apk/* /etc/nginx/sites /tmp/*

COPY ./overlay /

RUN ln -s /ssl/certs /etc/ssl/certs
RUN ln -s /sites /etc/nginx/sites
VOLUME [ "/ssl", "/sites" ]
