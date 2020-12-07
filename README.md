# Docker Nginx PHP

![Docker Image Version (latest semver)](https://img.shields.io/docker/v/bcgdesign/nginx-proxy?sort=semver) ![GitHub Workflow Status](https://img.shields.io/github/workflow/status/bencgreen/docker-nginx-proxy/build?label=github) ![Docker Cloud Build Status](https://img.shields.io/docker/cloud/build/bcgdesign/nginx-proxy?label=docker) ![Docker Pulls](https://img.shields.io/docker/pulls/bcgdesign/nginx-proxy?label=pulls) ![Docker Image Size (tag)](https://img.shields.io/docker/image-size/bcgdesign/nginx-proxy/latest?label=size)

[Docker Repository](https://hub.docker.com/r/bcgdesign/nginx-proxy) - [bcg|design ecosystem](https://github.com/bencgreen/docker)

Nginx Proxy

## Ports

* 80 (from base image)
* 443

## Environment Variables

Required:

```bash
LETS_ENCRYPT_EMAIL=         # used for renewal notification emails
```

Optional:

```bash
CLEAN_INSTALL=0             # clean all config and certificates before doing anything else
LETS_ENCRYPT_LIVE=0         # set to 1 to use live instead of staging server
SSL_DHPARAM_BITS=4096       # set to the number of bits to use for generating DH parameters
SSL_REDIRECT_INSECURE=0     # HTTPS redirection
SSL_REDIRECT_TO_CANONICAL=0 # canonical domain name redirection
SSL_REQUEST_ON_STARTUP=0    # automatically request certificates on startup
```

## Authors

* [Ben Green](https://github.com/bencgreen)

## License

> MIT

## Copyright

> Copyright (c) 2020 Ben Green <https://bcgdesign.com>  
> Unless otherwise stated
