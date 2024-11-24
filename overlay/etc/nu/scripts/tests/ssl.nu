use bf
use std assert
use ../bf/nginx/proxy ssl *


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
