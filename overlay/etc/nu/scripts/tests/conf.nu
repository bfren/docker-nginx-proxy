use bf
use std assert
use ../bf/nginx/proxy conf *

#======================================================================================================================
# generate_conf_json
#======================================================================================================================

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
        BF_PROXY_SSL_CONF: "/tmp/conf.json"
    }
}

export def generate_conf_json__outputs_primary [] {
    let primary = random chars --length 5
    let output = "/tmp/conf.json"
    let e = get_e --primary $primary | bf dump -e -t "Env"
    ls /etc/bf/templates | bf dump -e -t "Templ"
    echo $env.PATH | bf dump -e -t "Path"

    let result = with-env $e { generate_conf_json } | open $output | get domains.primary

    assert equal $primary $result
}
