use std assert
use bf
use bf/nginx/proxy conf *
use vars.nu *


#======================================================================================================================
# get_domains
#======================================================================================================================

export def get_domains__returns_list_of_domains [] {
    let conf = {
        "domains": [
            {
                "primary": (random chars)
                "upstream": (random chars)
                "aliases": [(random chars) (random chars)]
                "custom": (random bool)
            }
        ]
    }
    let file = mktemp -t
    $conf | to json | save -f $file
    let e = {
        BF_PROXY_SSL_CONF: $file
    }

    let result = with-env $e { get_domains }

    assert equal $conf.domains $result
}


#======================================================================================================================
# generate_nginx_ssl_conf
#======================================================================================================================

def generate_nginx_ssl_conf_e [
    --harden            # Optional harden switch
] {
    {
        BF_ETC_TEMPLATES: $ETC_TEMPLATES
        BF_PROXY_HARDEN: (match $harden { true => "1", false => "" })
    }
}

export def generate_nginx_ssl_conf__outputs_intermediate_conf [] {
    let e = generate_nginx_ssl_conf_e
    let expected = "c8864a579b0ec2cb4070f27affb4e05f"

    let result = with-env $e { generate_nginx_ssl_conf } | open --raw $NGINX_SSL_CONF | hash md5
    open $NGINX_SSL_CONF | bf dump -e -t "ssl"

    assert equal $expected $result
}

export def generate_nginx_ssl_conf__outputs_modern_conf [] {
    let e = generate_nginx_ssl_conf_e --harden
    let expected = "73f99a3458030a8dae265a10355032e3"

    let result = with-env $e { generate_nginx_ssl_conf } | open --raw $NGINX_SSL_CONF | hash md5

    assert equal $expected $result
}
