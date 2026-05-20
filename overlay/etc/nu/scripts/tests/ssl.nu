use std assert
use bf
use bf/nginx/proxy ssl *


#======================================================================================================================
# generate_dhparam
#======================================================================================================================

def generate_dhparam_e [
    file: string
] {
    {
        BF_PROXY_SSL_DHPARAM: $file
        BF_PROXY_SSL_DHPARAM_BITS: 1024
    }
}

export def generate_dhparam__does_nothing_if_file_exists [] {
    let file = mktemp -t
    let content = random chars
    $content | save --force $file
    let e = generate_dhparam_e $file

    let result = with-env $e { generate_dhparam } | open --raw $file

    assert equal $content $result
}

export def generate_dhparam__generates_dhparam_if_file_does_not_exist [] {
    let file = $"/tmp/(random chars)"
    let e = generate_dhparam_e $file

    let result = with-env $e { generate_dhparam } | open $file

    assert not equal "" $result
}


#======================================================================================================================
# generate_temp_certs
#======================================================================================================================

def generate_temp_certs_e [
    --bits: int = 1024
    --expiry: duration = 3650day
    certs: string
] {
    {
        BF_PROXY_SSL_CERTS: $certs
        BF_PROXY_SSL_EXPIRY: $expiry
        BF_PROXY_SSL_KEY_BITS: $bits
    }
}

export def generate_temp_certs__does_nothing_if_crt_exists [] {
    let certs = mktemp -d -t
    let domain = random chars
    mkdir $"($certs)/($domain)"
    let content = random chars
    let crt = $"($certs)/($domain)/($CRT_SUFFIX)"
    echo $content | save --force $crt
    let e = generate_temp_certs_e $certs

    let result = with-env $e { generate_temp_certs $domain } | open --raw $crt

    assert equal $content $result
}

export def generate_temp_certs__generates_all_files [] {
    let certs = mktemp -d -t
    let domain = random chars
    mkdir $"($certs)/($domain)"
    let e = generate_temp_certs_e $certs

    let result = with-env $e { generate_temp_certs $domain }

    assert equal true ($"($certs)/($domain)($KEY_SUFFIX)" | path exists)
    assert equal true ($"($certs)/($domain)($CRT_SUFFIX)" | path exists)
    assert equal true ($"($certs)/($domain)($CHAIN_KEY_SUFFIX)" | path exists)
    assert equal true ($"($certs)/($domain)($CHAIN_CRT_SUFFIX)" | path exists)
}


#======================================================================================================================
# create_pem
#======================================================================================================================

export def create_pem__does_nothing_if_crt_does_not_exist [] {
    let certs = mktemp -d -t
    let domain = random chars
    mkdir $"($certs)/($domain)"
    random chars | save --force $"($certs)/($domain)($KEY_SUFFIX)"
    let e = generate_temp_certs_e $certs

    let result = with-env $e { create_pem $domain } | echo $in | path exists

    assert equal false $result
}

export def create_pem__does_nothing_if_key_does_not_exist [] {
    let certs = mktemp -d -t
    let domain = random chars
    mkdir $"($certs)/($domain)"
    random chars | save --force $"($certs)/($domain)($CRT_SUFFIX)"
    let e = generate_temp_certs_e $certs

    let result = with-env $e { create_pem $domain } | echo $in | path exists

    assert equal false $result
}

export def create_pem__merges_key_and_crt_files [] {
    let certs = mktemp -d -t
    let domain = random chars
    let cert = $"($certs)/($domain)"
    let key = random chars
    let key_file = $"($cert)($KEY_SUFFIX)"
    let crt = random chars
    let crt_file = $"($cert)($CRT_SUFFIX)"
    let pem = $"($key)(char newline)($crt)"
    let pem_file = $"($cert)/($domain)($PEM_SUFFIX)"
    let e = generate_temp_certs_e $certs
    mkdir $cert
    echo $key | save --force $key_file
    echo $crt | save --force $crt_file

    let result = with-env $e { create_pem $domain } | open --raw $pem_file

    assert equal $pem $result
}

export def create_pem__overwrites_existing_pem_file [] {
    let certs = mktemp -d -t
    let domain = random chars
    let cert = $"($certs)/($domain)"
    let key = random chars
    let key_file = $"($cert)($KEY_SUFFIX)"
    let crt = random chars
    let crt_file = $"($cert)($CRT_SUFFIX)"
    let pem = $"($key)(char newline)($crt)"
    let pem_file = $"($cert)/($domain)($PEM_SUFFIX)"
    let e = generate_temp_certs_e $certs
    mkdir $cert
    echo $key | save --force $key_file
    echo $crt | save --force $crt_file
    random chars | save --force $pem_file

    let result = with-env $e { create_pem $domain } | open --raw $pem_file

    assert equal $pem $result
}
