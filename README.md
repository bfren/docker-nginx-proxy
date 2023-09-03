# Docker Nginx Proxy

![GitHub release (latest by date)](https://img.shields.io/github/v/release/bfren/docker-nginx-proxy) ![Docker Pulls](https://img.shields.io/endpoint?url=https%3A%2F%2Fbfren.dev%2Fdocker%2Fpulls%2Fnginx-proxy) ![Docker Image Size](https://img.shields.io/endpoint?url=https%3A%2F%2Fbfren.dev%2Fdocker%2Fsize%2Fnginx-proxy) ![GitHub Workflow Status](https://img.shields.io/github/actions/workflow/status/bfren/docker-nginx-proxy/dev.yml?branch=main)

[Docker Repository](https://hub.docker.com/r/bfren/nginx-proxy) - [bfren ecosystem](https://github.com/bfren/docker)

Nginx Proxy which uses [getssl](https://github.com/srvrco/getssl) to automate requesting and renewing SSL certificates via Let's Encrypt.  Certificates are checked for renewal every day - the last check can be viewed in the `/ssl` volume.  Also includes [NAXSI](https://github.com/nbs-system/naxsi), a web application firewall.

As of v4, configuration is handled via a JSON file - see ssl-conf-sample.json for an example and ssl-conf-schema.json for the full file definition.

## Contents

* [Ports](#ports)
* [Volumes](#volumes)
* [Environment Variables](#environment-variables)
* [Helper Functions](#helper-functions)
* [Nginx Configuration Helpers](#nginx-configuration-helpers)
* [Licence / Copyright](#licence)

## Ports

For SSL certificate requests to work correctly, ports 80 and 443 need mapping from the host to your proxy container, e.g. adding `"0.0.0.0:80:80"` to the ports section of your docker compose file.

* 80 (from base image)
* 443

## Volumes

| Volume   | Purpose                                                                                                                                                                                                                                                   |
| -------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `/www`   | *From base image.*                                                                                                                                                                                                                                        |
| `/sites` | Nginx site configuration, auto-generated on first run based on `conf.json`.  After they are generated, you can alter them to suit their needs.  Running `nginx-regenerate` will wipe them all and start again.                                            |
| `/ssl`   | Contains auto-generated SSL configuration and certificates (for backup purposes).  Your `conf.json` file should be stored in here for auto-configuration (see `ssl-conf-sample.json`).  Certificate update log (`update.log`) will be created here daily. |

## Environment Variables

| Variable                              | Values                | Description                                                                                                                                   | Default               |
| ------------------------------------- | --------------------- | --------------------------------------------------------------------------------------------------------------------------------------------- | --------------------- |
| `PROXY_URI`                           | URI                   | The base URI of the proxy server - will be used to handle unbound requests.                                                                   | *None* - **required** |
| `PROXY_CLEAN_INSTALL`                 | 0 or 1                | If 1, all Nginx and SSL configuration and certificates will be deleted and regenerated.                                                       | 0                     |
| `PROXY_ENABLE_NAXSI`                  | 0 or 1                | If 1, NAXSI web application firewall will be enabled for all sites.                                                                           | 0                     |
| `PROXY_HARDEN`                        | 0 or 1                | If 1, only modern SSL ciphers and protocols will be enabled (some older devices may not be able to access it).                                | 0                     |
| `PROXY_LETS_ENCRYPT_EMAIL`            | A valid email address | Used by Lets Encrypt for notification emails.                                                                                                 | *None* - **required** |
| `PROXY_LETS_ENCRYPT_LIVE`             | 0 or 1                | Only set to 1 (to request live certificates) when your config is correct - Lets Encrypt rate limit certificate requests.                      | 0                     |
| `PROXY_SSL_DHPARAM_BITS`              | A valid integer       | The size of your DHPARAM variables - adjust down only if you have limited processing resources.                                               | 4096                  |
| `PROXY_SSL_REDIRECT_TO_CANONICAL`     | 0 or 1                | If 1, all requests will be redirected to the primary domain (defined in `conf.json`).                                                         | 0                     |
| `PROXY_GETSSL_SKIP_HTTP_TOKEN_CHECK`  | true or false         | Set to true to enable `getssl`'s [skip HTTP token check](https://github.com/srvrco/getssl/wiki/Config-variables#skip_http_token_checkfalse).  | false                 |
| `PROXY_AUTO_PRIMARY`                  | URI                   | If set (along with PROXY_AUTO_UPSTREAM) SSL config will be generated on first startup.                                                        | *None*                |
| `PROXY_AUTO_UPSTREAM`                 | URI                   | If set (along with PROXY_AUTO_PRIMARY) SSL config will be generated on first startup.                                                         | *None*                |
| `PROXY_AUTO_ALIASES`                  | string of URIs        | Add aliases to the auto-generated conf.json on first startup.                                                                                 | *None*                |
| `PROXY_AUTO_CUSTOM`                   | 0 or 1                | Mark the auto-generated SSL config to 'custom' so the Nginx configuration is not regenerated on startup.                                      | 0                     |
| `PROXY_UPSTREAM_DNS_RESOLVER`         | IP address            | Upstream DNS resolver - set to Docker's by default.                                                                                           | 127.0.0.11            |
| `PROXY_MAINTENANCE_REFRESH_SECONDS`   | A valid integer       | The number of seconds to count down before the maintenance page auto-refreshes.                                                               | 6                     |

## Helper Functions

| Function              | Arguments                                                 | Description                                                                                                                   |
| --------------------- | --------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------- |
| `nginx-adduser`       | 0: username, 1: password                                  | Add a user to enable basic HTTP auth.                                                                                         |
| `nginx-regenerate`    | -a: all domains, -d XXXXXX: only domain XXXXXX, -f: force | Removes non-custom Nginx configuration files (in `/sites`) and regenerates based on `conf.json` (with force, removes all).    |
| `ssl-cleanup`         | -m: mode                                                  | Removes SSL and Nginx configuration files and directories not defined in `conf.json` (mode 0 = dry run, 1 = live).            |
| `ssl-init`            | -a: all domains, -d XXXXXX: only domain XXXXXX            | Initialises SSL configuration based on `conf.json`.                                                                           |
| `ssl-regenerate`      | -a: all domains, -d XXXXXX: only domain XXXXXX            | Removes SSL configuration files (in `/ssl/certs`) and regenerates based on `conf.json`.                                       |
| `ssl-regenerate-full` | *None*                                                    | Removes SSL configuration files (in `/ssl/certs`), as well as DH parameters, and regenerates based on `conf.json`.            |
| `ssl-request`         | -a: all domains, -d XXXXXX: only domain XXXXXX            | Requests SSL certificates from Lets Encrypt.                                                                                  |
| `ssl-update`          | -a: all domains, -d XXXXXX: only domain XXXXXX            | Attempts to update SSL certificates manually.                                                                                 |

## Nginx Configuration Helpers

The image contains a handful of useful Nginx configuration 'helper' files, which you can find in `/overlay/etc/nginx/helpers`.  They all begin with the prefix 'proxy':

| Helper                    | Description                                                                                                      |
| ------------------------- | ---------------------------------------------------------------------------------------------------------------- |
| `-maintenance.conf`       | Displays a maintenance page (used when upstream server is returning an error 50x).                               |
| `-params.conf`            | Headers commonly required when proxying a site.                                                                  |
| `-params-websockets.conf` | Headers required to use websockets.                                                                              |
| `-secure-headers.conf`    | Standard secure headers - see [Mozilla SSL Configuration Generator](https://ssl-config.mozilla.org/).            |
| `-tls1_3-only.conf`       | If you want to be ultra-secure (and not support older browsers), this will disable all TLS protocols except 1.3. |

## Licence

> [MIT](https://mit.bfren.dev/2020)

## Copyright

> Copyright (c) 2020-2023 [bfren](https://bfren.dev) (unless otherwise stated)
