use bf
use bf/nginx/proxy
bf env load

# Initialise SSL global config and proxy domain
def main []: nothing -> nothing {
    # check for clean install
    if (bf env check PROXY_CLEAN_INSTALL) {
        bf write "Clean install detected - removing:"
        bf env PROXY_GETSSL_GLOBAL_CFG | remove
        bf env PROXY_SITES | $"$($in)/*" | remove
        bf env PROXY_SSL_CERTS | $"$($in)/*" | remove
        bf env PROXY_SSL_DHPARAM | remove
    }

    # check for auto setup
    let proxy_ssl_does_not_exist = bf env PROXY_SSL_CONF | bf fs is_not_file
    let proxy_auto_primary_is_set = bf env -s PROXY_AUTO_PRIMARY | is-not-empty
    let proxy_auto_upstream_is_set = bf env -s PROXY_AUTO_UPSTREAM | is-not-empty

    # if there is no SSL config, and auto environment variables are set, generate config and ssl
    # otherwise, generate SSL for root domain only
    if $proxy_ssl_does_not_exist and $proxy_auto_primary_is_set and $proxy_auto_upstream_is_set {
        # set PROXY_AUTO so we know downstream that we are auto generating files
        bf env set "PROXY_AUTO" "1"

        # generate conf.json
        proxy conf generate_conf_json

        # if there are aliases enable canonical redirection
        if (bf env check "PROXY_AUTO_ALIASES") { bf env set "PROXY_SSL_REDIRECT_TO_CANONICAL" "1" }

        # initialise all domains (effectively proxy plus auto)
        proxy init all
    } else {
        proxy init root
    }
}

# Remove file(s) by converting input into a glob before calling `rm`
def remove []: string -> nothing {
    let file = $in | into glob
    bf write debug $" .. ($file)"
    rm --force --recursive $file
}
