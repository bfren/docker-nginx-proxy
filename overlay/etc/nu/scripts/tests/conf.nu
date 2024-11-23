use bf
use std assert
use ../bf/nginx/proxy conf *

const ETC_TEMPLATES = "/etc/bf/templates"


#======================================================================================================================
# generate_nginx_ssl_conf
#======================================================================================================================

const NGINX_SSL_OUTPUT = "/etc/nginx/http.d/ssl.conf"

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

    let result = with-env $e { generate_nginx_ssl_conf } | open --raw $NGINX_SSL_OUTPUT | hash md5
    open $NGINX_SSL_OUTPUT | bf dump -e -t "ssl"

    assert equal $expected $result
}

export def generate_nginx_ssl_conf__outputs_modern_conf [] {
    let e = generate_nginx_ssl_conf_e --harden
    let expected = "73f99a3458030a8dae265a10355032e3"

    let result = with-env $e { generate_nginx_ssl_conf } | open --raw $NGINX_SSL_OUTPUT | hash md5

    assert equal $expected $result
}

#======================================================================================================================
# generate_conf_json
#======================================================================================================================

const CONF_JSON_OUTPUT = "/tmp/conf.json"

def get_conf_json_e [
    --primary: string   # Optional primary domain name
    --upstream: string  # Optional upstream server
    --aliases: string   # Optional domain aliases
    --custom            # Optional 'custom' conf switch
]: nothing -> record {
    {
        BF_ETC_TEMPLATES: $ETC_TEMPLATES
        BF_PROXY_AUTO_PRIMARY: (match $primary { null => (random chars), _ => $primary })
        BF_PROXY_AUTO_UPSTREAM: (match $upstream { null => (random chars), _ => $upstream })
        BF_PROXY_AUTO_ALIASES: $aliases
        BF_PROXY_AUTO_CUSTOM: (match $custom { true => "1", false => "" })
        BF_PROXY_SSL_CONF: $CONF_JSON_OUTPUT
    }
}

export def generate_conf_json__outputs_primary [] {
    let primary = random chars --length 5
    let e = get_conf_json_e --primary $primary

    let result = with-env $e { generate_conf_json } | open $CONF_JSON_OUTPUT | get domains.0.primary

    assert equal $primary $result
}

export def generate_conf_json__outputs_upstream [] {
    let upstream = random chars --length 5
    let e = get_conf_json_e --upstream $upstream

    let result = with-env $e { generate_conf_json } | open $CONF_JSON_OUTPUT | get domains.0.upstream

    assert equal $upstream $result
}

export def generate_conf_json__outputs_aliases [] {
    let aliases = 0..2 | each {|| random chars --length 5 }
    let aliases_in = $aliases | str join " "
    let e = get_conf_json_e --aliases $aliases_in

    let result = with-env $e { generate_conf_json } | open $CONF_JSON_OUTPUT | get domains.0.aliases

    assert equal $aliases $result
}

export def generate_conf_json__does_not_output_aliases [] {
    let e = get_conf_json_e

    let result = with-env $e { generate_conf_json } | open $CONF_JSON_OUTPUT | get -i domains.0.aliases

    assert equal null $result
}

export def generate_conf_json__outputs_custom [] {
    let e = get_conf_json_e --custom

    let result = with-env $e { generate_conf_json } | open $CONF_JSON_OUTPUT | get domains.0.custom

    assert equal true $result
}

export def generate_conf_json__does_not_output_custom [] {
    let e = get_conf_json_e

    let result = with-env $e { generate_conf_json } | open $CONF_JSON_OUTPUT | get -i domains.0.custom

    assert equal null $result
}
