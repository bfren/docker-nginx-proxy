use bf

# Generate conf.json as part of auto setup
export def generate_conf_json []: nothing -> nothing {
    # setup variables
    let primary = bf env "PROXY_AUTO_PRIMARY"
    let upstream = bf env "PROXY_AUTO_UPSTREAM"
    let aliases = match (bf env -s "PROXY_AUTO_ALIASES") {
        "" => ""
        $a => ($a | split words | str join "\", \"" | $"\"($in)\"")
    }
    let custom = bf env -s "PROXY_AUTO_CUSTOM"

    # generate file
    bf write "Generating conf.json using auto environment variables." auto/generate_conf_json
    let e = {
        PRIMARY: $primary
        UPSTREAM: $upstream
        ALIASES: $aliases
        CUSTOM: $custom
    }
    with-env $e { bf esh template (bf env "PROXY_SSL_CONF") }

    # return nothing
    return
}

# If SSL config does not exist and auto primary / upstream are set, returns true
export def is_enabled []: nothing -> bool {
    # check conditions
    let ssl_does_not_exist = bf env PROXY_SSL_CONF | bf fs is_not_file
    let auto_primary_is_set = bf env -s PROXY_AUTO_PRIMARY | is-not-empty
    let auto_upstream_is_set = bf env -s PROXY_AUTO_UPSTREAM | is-not-empty

    # all conditions must be true
    return ($ssl_does_not_exist and $auto_primary_is_set and $auto_upstream_is_set)
}
