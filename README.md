# Docker Nginx Proxy

![Docker Image Version (tag latest semver)](https://img.shields.io/docker/v/bcgdesign/nginx-proxy/latest?label=latest) ![GitHub Workflow Status](https://img.shields.io/github/workflow/status/bencgreen/docker-nginx-proxy/build?label=github) ![Docker Cloud Build Status](https://img.shields.io/docker/cloud/build/bcgdesign/nginx-proxy?label=docker) ![Docker Pulls](https://img.shields.io/docker/pulls/bcgdesign/nginx-proxy?label=pulls) ![Docker Image Size (tag)](https://img.shields.io/docker/image-size/bcgdesign/nginx-proxy/latest?label=size)

[Docker Repository](https://hub.docker.com/r/bcgdesign/nginx-proxy) - [bcg|design ecosystem](https://github.com/bencgreen/docker)

Nginx Proxy which uses [getssl](https://github.com/srvrco/getssl) to automate requesting and renewing SSL certificates via Let's Encrypt.  Certificates are checked for renewal every week - the last check can be viewed in the `/ssl` volume.

## Ports

For SSL certificate requests to work correctly, ports 80 and 443 need mapping from the host to your proxy container, e.g. adding `"0.0.0.0:80:80"` to the ports section of your docker compose file.

* 80 (from base image)
* 443

## Volumes

| Volume   | Purpose                                                                                                                                                                                                                                                |
| -------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| `/www`   | *From base image*                                                                                                                                                                                                                                      |
| `/sites` | Nginx site configuration, auto-generated on first run based on `conf.sh`.  After they are generated, you can alter them to suit their needs.  Running `nginx-regenerate` will wipe them all and start again.                                           |
| `/ssl`   | Contains auto-generated SSL configuration and certificates (for backup purposes).  Your `conf.sh` file should be stored in here for auto-configuration (see `ssl-conf-sample.sh`).  Certificate update log (`update.log`) will be created here weekly. |

## Environment Variables

| Variable                       | Values                | Description                                                                                                                                  | Default               |
| ------------------------------ | --------------------- | -------------------------------------------------------------------------------------------------------------------------------------------- | --------------------- |
| `LETS_ENCRYPT_EMAIL`           | A valid email address | Used by Lets Encrypt for notification emails.                                                                                                | *None* - **required** |
| `CLEAN_INSTALL`                | 0 or 1                | If 1, all Nginx and SSL configuration and certificates will be deleted and regenerated.                                                      | 0                     |
| `LETS_ENCRYPT_LIVE`            | 0 or 1                | Only set to 1 (to request live certificates) when your config is correct - Lets Encrypt rate limit certificate requests.                     | 0                     |
| `SSL_DHPARAM_BITS`             | A valid integer       | The size of your DHPARAM variables - adjust down only if you have limited processing resources.                                              | 4096                  |
| `SSL_REDIRECT_INSECURE`        | 0 or 1                | If 1, all insecured (HTTP) requests will be upgraded by Nginx to secure (HTTPS).                                                             | 0                     |
| `SSL_REDIRECT_TO_CANONICAL`    | 0 or 1                | If 1, all requests will be redirected to the primary domain (defined in `conf.sh`).                                                          | 0                     |
| `SSL_REQUEST_ON_STARTUP`       | 0 or 1                | If 1, SSL certificates will be automatically requested - otherwise you'll need to use `ssl-request`.                                         | 0                     |
| `GETSSL_SKIP_HTTP_TOKEN_CHECK` | true or false         | Set to true to enable `getssl`'s [skip HTTP token check](https://github.com/srvrco/getssl/wiki/Config-variables#skip_http_token_checkfalse). | false                 |

## Helper Functions

| Function           | Arguments | Description                                                                         |
| ------------------ | --------- | ----------------------------------------------------------------------------------- |
| `nginx-regenerate` | *None*    | Removes Nginx configuration files (in `/sites`) and regenerates based on `conf.sh`. |
| `ssl-init`         | *None*    | Initialises SSL configuration based on `conf.sh`.                                   |
| `ssl-regenerate`   | *None*    | Removes SSL configuration files (in `/ssl`) and regenerates based on `conf.sh`.     |
| `ssl-request`      | *None*    | Requests SSL certificates from Lets Encrypt.                                        |
| `ssl-update`       | *None*    | Attempts to update SSL certificates manually.                                       |

## Nginx Configuration Helpers

The image contains a handful of useful Nginx configuration 'helper' files, which you can find in `/overlay/etc/nginx/helpers`.

| Helper                | Description                                                                                                      |
| --------------------- | ---------------------------------------------------------------------------------------------------------------- |
| `proxy-params.conf`   | Headers commonly required when proxying a site.                                                                  |
| `secure-headers.conf` | Standard secure headers - see [Mozilla SSL Configuration Generator](https://ssl-config.mozilla.org/).            |
| `tls1_3-only.conf`    | If you want to be ultra-secure (and not support older browsers), this will disable all TLS protocols except 1.3. |

## Authors

* [Ben Green](https://github.com/bencgreen)

## License

> MIT

## Copyright

> Copyright (c) 2021 Ben Green <https://bcgdesign.com>  
> Unless otherwise stated
