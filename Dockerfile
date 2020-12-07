FROM bcgdesign/nginx:1.18.0-r1

LABEL maintainer="Ben Green <ben@bcgdesign.com>" \
    org.label-schema.name="Nginx Proxy" \
    org.label-schema.version="latest" \
    org.label-schema.vendor="Ben Green" \
    org.label-schema.schema-version="1.0"

# port 80 is already exposed by the base image
EXPOSE 443

ENV \
    # clean all config and certificates before doing anything else
    CLEAN_INSTALL=0 \
    # used for renewal notification emails
    LETS_ENCRYPT_EMAIL= \
    # set to 1 to use live instead of staging server
    LETS_ENCRYPT_LIVE=0 \
    # set to the number of bits to use for generating DHPARAM
    SSL_DHPARAM_BITS=4096 \
    # HTTPS redirection
    SSL_REDIRECT_INSECURE=0 \
    # canonical domain name redirection
    SSL_REDIRECT_TO_CANONICAL=0 \
    # automatically request certificates on startup - only use if you don't need any additional configuration
    SSL_REQUEST_ON_STARTUP=0

RUN apk -U upgrade \
    && apk add \
        bash \
        curl \
        gomplate \
        openssl \
    && rm -rf /var/cache/apk/* /etc/nginx/sites /www/* /tmp/*

COPY ./overlay /

RUN ln -s /ssl/certs /etc/ssl/certs
RUN ln -s /sites /etc/nginx/sites
VOLUME [ "/ssl", "/sites" ]
