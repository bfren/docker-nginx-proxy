use bf
use conf.nu
use getssl.nu
use ssl.nu

# Initialise SSL for the specified domain(s).
#doc
# Order of precedence:
#   1. `init --all`
#   2. `init --root`
#   3. `init --domain xxxxxx`
export def main [
    --all (-a)              # If set, will initialise root and all configured domains
    --domain (-d): string   # Specify the domain to be initialised
    --root (-d)             # If set, will initialise root domain
]: nothing -> nothing {
    # generate getssl configuration
    getssl generate_conf

    # generate DHPARAM file
    ssl generate_dhparam

    # initialise domain(s)
    if $all { all_domains }
    else if $root { root }
    else if $domain { domain $domain }

    # return nothing
    return
}

# Check for clean install and delete
export def setup_clean_install []: nothing -> nothing {
    bf write debug " .. removing SSL config and certificates:" init/setup_clean_install
    bf env PROXY_GETSSL_GLOBAL_CFG | remove
    bf env PROXY_SITES | $"($in)/*" | remove
    bf env PROXY_SSL_CERTS | $"($in)/*" | remove
    bf env PROXY_SSL_DHPARAM | remove
}

# Remove file(s) by converting input into a glob before calling `rm`
def remove []: string -> nothing {
    let file = $in | into glob
    bf write debug $"    ($file)" init/remove
    rm --force --recursive $file
}

# Initialise SSL for all configured domains
def all_domains []: nothing -> nothing {
    let domains = conf get_domains
}

# Initialise SSL for the specified domain
def domain [
    domain: string  # The domain to initialise
]: nothing -> nothing {

}

# Initialise SSL for the root domain
def root []: nothing -> nothing {
    domain (bf env "PROXY_DOMAIN")
}
