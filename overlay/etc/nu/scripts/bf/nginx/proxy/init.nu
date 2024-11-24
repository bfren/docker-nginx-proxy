use bf

# Check for clean install and delete
export def setup_clean_install []: nothing -> nothing {
    bf write debug " .. removing SSL config and certificates:"
    bf env PROXY_GETSSL_GLOBAL_CFG | remove
    bf env PROXY_SITES | $"($in)/*" | remove
    bf env PROXY_SSL_CERTS | $"($in)/*" | remove
    bf env PROXY_SSL_DHPARAM | remove
}

# Remove file(s) by converting input into a glob before calling `rm`
def remove []: string -> nothing {
    let file = $in | into glob
    bf write debug $"    ($file)"
    rm --force --recursive $file
}

# Initialise SSL for all configured domains
export def all []: nothing -> nothing {

}

# Initialise SSL for the specified domain
export def domain [
    domain: string  # The domain to initialise
]: nothing -> nothing {

}

# Initialise SSL for the root domain
export def root [

]: nothing -> nothing {
    domain (bf env "PROXY_DOMAIN")
}
