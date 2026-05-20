use bf

export const KEY_SUFFIX = ".key"
export const CRT_SUFFIX = "/fullchain.crt"
export const CHAIN_KEY_SUFFIX = "/chain.key"
export const CHAIN_CRT_SUFFIX = "/chain.crt"
export const PEM_SUFFIX = ".pem"

# Generate a DHPARAM file if it does not already exist
export def generate_dhparam []: nothing -> nothing {
    let dhparam = bf env "PROXY_SSL_DHPARAM"
    if ($dhparam | bf fs is_not_file) {
        # don't use bf handle here so we can see progress
        ^openssl dhparam (bf env "PROXY_SSL_DHPARAM_BITS") | save --force $dhparam
    } else {
        bf write debug $" .. ($dhparam) already exists." ssl/generate_dhparam
    }
}

# Generate temporary SSL certificates for a domain
export def generate_temp_certs [
    domain: string      # the domain to generate temporary SSL for
]: nothing -> nothing {
    # get variables
    let base = $"(bf env "PROXY_SSL_CERTS")/($domain)"
    let key = $"($base)($KEY_SUFFIX)"
    let crt = $"($base)($CRT_SUFFIX)"
    let chain_key = $"($base)($CHAIN_KEY_SUFFIX)"
    let chain_crt = $"($base)($CHAIN_CRT_SUFFIX)"

    # do nothing if the domain certificate already exists
    if ($crt | path exists) {
        bf write debug " .. certificate already exists." ssl/generate_temp_certs
        return
    }

    # closure to generate a certificate
    let generate_cert = {|cn: string, keyout: string, crtout: string|
        let args = [
            -x509
            -sha256
            -nodes
            -days (bf env "PROXY_SSL_EXPIRY" | into duration | $in / 1day)
            -newkey rsa:(bf env "PROXY_SSL_KEY_BITS")
            -keyout $keyout
            -out $crtout
            -subj $"/C=NA/ST=NA/L=NA/O=NA/OU=NA/CN=($cn)"
        ]
        { ^openssl req ...$args } | bf handle
    }

    # generate certificates
    do $generate_cert $domain $key $crt
    do $generate_cert $domain $chain_key $chain_crt
}

# Create a PEM_SUFFIX file from a domain certificate and key
export def create_pem [
    domain: string      # the domain to generate a PEM_SUFFIX file for
]: nothing -> string {
    # get variables
    let base = $"(bf env "PROXY_SSL_CERTS")/($domain)"
    let key_file = $"($base)($KEY_SUFFIX)"
    let crt_file = $"($base)($CRT_SUFFIX)"
    let pem_file = $"($base)/($domain)($PEM_SUFFIX)"

    # return error if files do not exist
    if ($key_file | bf fs is_not_file) or ($crt_file | bf fs is_not_file) {
        bf write notok $"Unable to locate certificate or key file for ($domain)." ssl/create_pem
        return ""
    }

    # create pem file
    let key = open --raw $key_file
    let crt = open --raw $crt_file
    echo $"($key)(char newline)($crt)" | save --force $pem_file

    # return path to pem file
    $pem_file
}
