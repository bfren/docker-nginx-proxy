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
    let custom = bf env check "PROXY_AUTO_CUSTOM"

    # generate file
    bf write "Generating conf.json using auto environment variables."
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
