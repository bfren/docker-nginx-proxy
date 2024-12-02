use bf

# Generate a DHPARAM file if it does not already exist
export def generate_dhparam []: nothing -> nothing {
    let dhparam = bf env "PROXY_SSL_DHPARAM"
    if ($dhparam | bf fs is_not_file) {
        bf write debug $"Creating dhparam file: ($dhparam)." ssl/generate_dhparam
        ^openssl dhparam (bf env "PROXY_SSL_DHPARAM_BITS") | save --force $dhparam
    }
}

# Generate temporary SSL certificates for a domain
export def generate_temp_certs [
    domain: record      # the domain record to generate temporary SSL for
]: nothing -> nothing {

}
