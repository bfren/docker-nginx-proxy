FROM bfren/nginx:nginx1.26-alpine3.20-6.3.14

LABEL org.opencontainers.image.source="https://github.com/bfren/docker-nginx-proxy"

ARG BF_IMAGE
ARG BF_VERSION

# port 80 is already exposed by the base image
EXPOSE 443

COPY ./overlay /

ENV \
    # the root domain of the proxy server (will be used when SSL bindings fail)
    BF_PROXY_DOMAIN= \
    # delete all config and certificates before doing anything else
    BF_PROXY_CLEAN_INSTALL=0 \
    # enable automatic certificate updating
    BF_PROXY_ENABLE_AUTO_UPDATE=1 \
    # use hardened mode (e.g. remove old / insecure ciphers and protocols)
    BF_PROXY_HARDEN=0 \
    # used for renewal notification emails
    BF_PROXY_GETSSL_EMAIL= \
    # set to 1 to use live instead of staging server
    BF_PROXY_GETSSL_USE_LIVE_SERVER=0 \
    # set to true to skip local HTTP token check
    BF_PROXY_GETSSL_SKIP_HTTP_TOKEN_CHECK="false" \
    # set to the number of bits to use for generating private key
    BF_PROXY_SSL_KEY_BITS=4096 \
    # set to the number of bits to use for generating DHPARAM
    BF_PROXY_SSL_DHPARAM_BITS=4096 \
    # canonical domain name redirection
    BF_PROXY_SSL_REDIRECT_TO_CANONICAL=0 \
    # if both are set, on first startup will generate SSL config and request certs
    BF_PROXY_AUTO_PRIMARY= \
    BF_PROXY_AUTO_UPSTREAM= \
    # optional - add aliases to the auto-generated conf.json on first startup
    BF_PROXY_AUTO_ALIASES= \
    # optional - mark the Nginx config as custom so it isn't regenerated on future startups
    BF_PROXY_AUTO_CUSTOM=0 \
    # upstream DNS resolver, set to Docker's internal resolver by default
    BF_PROXY_UPSTREAM_DNS_RESOLVER=127.0.0.11 \
    # the number of seconds before the maintenance page will automatically refresh
    BF_PROXY_MAINTENANCE_REFRESH_SECONDS=6

RUN bf-install

VOLUME [ "/ssl", "/sites" ]
