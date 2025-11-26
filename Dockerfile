FROM quay.io/bfren/nginx:nginx1.28-alpine3.22-7.0.1

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
    # the renew window number of days - certificates with more than this will not renew (Nu duration)
    BF_PROXY_GETSSL_RENEW_WINDOW=14day \
    # set to 1 to skip local HTTP token check
    BF_PROXY_GETSSL_SKIP_HTTP_TOKEN_CHECK=0 \
    # set to the number of bits to use for generating private key
    BF_PROXY_SSL_KEY_BITS=4096 \
    # set to the number of bits to use for generating DHPARAM
    BF_PROXY_SSL_DHPARAM_BITS=4096 \
    # the period of time before self-generated SSL certificates will expire (Nu duration)
    BF_PROXY_SSL_EXPIRY=36500day \
    # canonical domain name redirection
    BF_PROXY_SSL_REDIRECT_TO_CANONICAL=0 \
    # upstream DNS resolver, set to Docker's internal resolver by default
    BF_PROXY_UPSTREAM_DNS_RESOLVER=127.0.0.11 \
    # the number of seconds before the maintenance page will automatically refresh (Nu duration)
    BF_PROXY_MAINTENANCE_REFRESH=6sec

RUN bf-install

VOLUME [ "/ssl", "/sites" ]
