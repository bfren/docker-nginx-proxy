use std assert
use bf
use bf/nginx/proxy auto *
use vars.nu *


#======================================================================================================================
# is_enabled
#======================================================================================================================

def is_enabled_e [
    --ssl-conf-exists
    --auto-primary-is-empty
    --auto-upstream-is-empty
] {
    let ssl_conf = mktemp -t
    if not $ssl_conf_exists { rm $ssl_conf }
    {
        BF_PROXY_SSL_CONF: $ssl_conf
        BF_PROXY_AUTO_PRIMARY: (match ($auto_primary_is_empty) { true => "", false => "1" })
        BF_PROXY_AUTO_UPSTREAM: (match ($auto_upstream_is_empty) { true => "", false => "1" })
    }
}

export def is_enabled__returns_false_when_ssl_conf_exists [] {
    let e = is_enabled_e --ssl-conf-exists

    let result = with-env $e { is_enabled }

    assert equal false $result
}

export def is_enabled__returns_false_when_auto_primary_is_empty [] {
    let e = is_enabled_e --auto-primary-is-empty

    let result = with-env $e { is_enabled }

    assert equal false $result
}

export def is_enabled__returns_false_when_auto_upstream_is_empty [] {
    let e = is_enabled_e --auto-upstream-is-empty

    let result = with-env $e { is_enabled }

    assert equal false $result
}

export def is_enabled__returns_true [] {
    let e = is_enabled_e

    let result = with-env $e { is_enabled }

    assert equal true $result
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

