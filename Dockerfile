FROM bcgdesign/nginx:1.18.0-r9

LABEL maintainer="Ben Green <ben@bcgdesign.com>" \
    org.label-schema.name="Nginx Proxy" \
    org.label-schema.version="latest" \
    org.label-schema.vendor="Ben Green" \
    org.label-schema.schema-version="1.0"

ENV \
    LETS_ENCRYPT_EMAIL=

RUN apk -U upgrade \
    && rm -rf /var/cache/apk/* /etc/nginx/sites/* /tmp/*

COPY ./overlay /

RUN ln -s /etc/ssl/certs /certs
RUN ln -s /etc/nginx/sites /sites
VOLUME [ "/certs", "/sites" ]
