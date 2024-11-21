use bf
bf env load

# Set environment variables
def main []: nothing -> nothing {
    bf env set "PROXY_GETSSL" "/usr/bin/getssl"

    let proxy_ssl = "/ssl"
    bf env set "PROXY_SSL" $proxy_ssl
    bf env set "PROXY_SSL_CONF" $"($proxy_ssl)/conf.json"
    bf env set "PROXY_SSL_DHPARAM" $"($proxy_ssl)/dhparam.pem"

    let proxy_ssl_certs = $"($proxy_ssl)/certs"
    let proxy_getssl_config = "getssl.cfg"
    bf env set "PROXY_SSL_CERTS" $proxy_ssl_certs
    bf env set "PROXY_GETSSL_CFG" $proxy_getssl_config
    bf env set "PROXY_GETSSL_GLOBAL_CFG" $"($proxy_ssl_certs)/($proxy_getssl_config)"
    bf env set "PROXY_GETSSL_ACCOUNT_KEY" $"($proxy_ssl_certs)/account.key"

    let proxy_sites = "/sites"
    bf env set "PROXY_SITES" $proxy_sites

    let proxy_acme_challenge = ".well-known/acme-challenge"
    bf env set "PROXY_ACME_CHALLENGE" $proxy_acme_challenge
    bf env set "PROXY_WWW_ACME_CHALLENGE" $"(bf env NGINX_WWW)/($proxy_acme_challenge)"

    let getssl_flags = match (bf env check PROXY_GETSSL_DEBUG) {
        true => "-d -U"
        false => "-U"
    }
    bf env set "PROXY_GETSSL_FLAGS" $getssl_flags

    # return nothing
    return
}
