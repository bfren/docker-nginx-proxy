use bf
use std assert
use ../bf/nginx/proxy conf *

#======================================================================================================================
# generate_conf_json
#======================================================================================================================

const OUTPUT = "/tmp/conf.json"

def get_e [
    --primary: string   # Optional primary domain name
    --upstream: string  # Optional upstream server
    --aliases: string   # Optional domain aliases
    --custom: string    # Optional 'custom' conf switch
]: nothing -> record {
    {
        BF_ETC_TEMPLATES: "/etc/bf/templates"
        BF_PROXY_AUTO_PRIMARY: (match $primary { null => (random chars), _ => $primary })
        BF_PROXY_AUTO_UPSTREAM: (match $upstream { null => (random chars), _ => $upstream })
        BF_PROXY_AUTO_ALIASES: $aliases
        BF_PROXY_AUTO_CUSTOM: $custom
        BF_PROXY_SSL_CONF: $OUTPUT
    }
}

export def generate_conf_json__outputs_primary [] {
    let primary = random chars --length 5
    let e = get_e --primary $primary

    let result = with-env $e { generate_conf_json } | open $OUTPUT | get domains.primary | first

    assert equal $primary $result
}

export def generate_conf_json__outputs_upstream [] {
    let upstream = random chars --length 5
    let e = get_e --upstream $upstream

    let result = with-env $e { generate_conf_json } | open $OUTPUT | get domains.upstream | first

    assert equal $upstream $result
}

export def generate_conf_json__outputs_aliases [] {
    let aliases = 0..2 | each {|| random chars --length 5 } | bf dump -e -t "aliases"
    let aliases_in = $aliases | str join " "
    let e = get_e --aliases $aliases_in

    let result = with-env $e { generate_conf_json } | open $OUTPUT | get domains.aliases | first

    assert equal $aliases $result
}
