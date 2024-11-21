use std assert
use ../bf/nginx/proxy conf *

#======================================================================================================================
# generate_conf_json
#======================================================================================================================

def get_e [
    primary?: string
    upstream?: string
    aliases?: string
    custom?: string
]: nothing -> record {
    return {
        BF_ETC_TEMPLATES: "/etc/bf/templates"
        BF_PROXY_AUTO_PRIMARY: (match $primary { null => (random chars), _ => $primary })
        BF_PROXY_AUTO_UPSTREAM: (match $upstream { null => (random chars), _ => $upstream })
        BF_PROXY_AUTO_ALIASES: $aliases
        BF_PROXY_AUTO_CUSTOM: $custom
        BF_PROXY_SSL_CONF: "/tmp/conf.json"
    }
}

export def generate_conf_json__outputs_primary [] {
    let primary = random chars
    let upstream = random chars
    let output = "/tmp/conf.json"
    let e = get_e

    let result = with-env $e { generate_conf_json } | open $output

    echo $result
}
