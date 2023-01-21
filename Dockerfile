FROM bfren/nginx:nginx1.22-4.0.26

LABEL org.opencontainers.image.source="https://github.com/bfren/docker-nginx-proxy"

ARG BF_IMAGE
ARG BF_VERSION

# port 80 is already exposed by the base image
EXPOSE 443

ENV \
    # the base URI of the proxy server (will be used when SSL bindings fail)
    PROXY_URI= \
    # clean all config and certificates before doing anything else
    PROXY_CLEAN_INSTALL=0 \
    # enable automatic certificate updating
    PROXY_ENABLE_AUTO_UPDATE=1 \
    # use hardened mode (remove old / insecure ciphers and protocols)
    PROXY_HARDEN=0 \
    # used for renewal notification emails
    PROXY_LETS_ENCRYPT_EMAIL= \
    # set to 1 to use live instead of staging server
    PROXY_LETS_ENCRYPT_LIVE=0 \
    # set to the number of bits to use for generating private key
    PROXY_SSL_KEY_BITS=4096 \
    # set to the number of bits to use for generating DHPARAM
    PROXY_SSL_DHPARAM_BITS=4096 \
    # canonical domain name redirection
    PROXY_SSL_REDIRECT_TO_CANONICAL=0 \
    # set to true to skip local HTTP token check
    PROXY_GETSSL_SKIP_HTTP_TOKEN_CHECK="false" \
    # if both are set, on first startup will generate SSL config and request certs
    PROXY_AUTO_PRIMARY= \
    PROXY_AUTO_UPSTREAM= \
    # optional - add aliases to the auto-generated conf.json on first startup
    PROXY_AUTO_ALIASES= \
    # optional - mark the Nginx config as custom so it isn't regenerated on future startups
    PROXY_AUTO_CUSTOM=0

COPY ./overlay /

RUN bf-install

VOLUME [ "/ssl", "/sites" ]
