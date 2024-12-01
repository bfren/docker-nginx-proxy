use bf

# Generate getssl global configuration file if it does not already exist
export def generate_global_conf []: nothing -> nothing {
    let getssl_cfg = bf env PROXY_GETSSL_GLOBAL_CFG
    if ($getssl_cfg | bf fs is_not_file) {
        # get environment variables
        let e = {
            USE_LIVE_SERVER: (bf env PROXY_GETSSL_USE_LIVE_SERVER)
            ACCOUNT_EMAIL: (bf env PROXY_GETSSL_EMAIL)
            ACCOUNT_KEY: (bf env PROXY_GETSSL_ACCOUNT_KEY)
            RENEW_ALLOW: (bf env PROXY_GETSSL_RENEW_WINDOW_DAYS)
            SKIP_HTTP_TOKEN_CHECK: (bf env check PROXY_GETSSL_SKIP_HTTP_TOKEN_CHECK | into string)
        }

        # generate configuration
        bf write debug "Creating getssl global configuration file" getssl/generate_global_conf
        with-env $e { bf esh template $getssl_cfg }
    }
}

# Generate getssl site configuration file
export def generate_site_conf [
    domain: record      # the domain record to generate temporary SSL for
]: nothing -> string {
    # check for existing getssl config
    let certs = bf env "PROXY_SSL_CERTS"
    let file = $"($certs)/($domain.primary)/(bf env PROXY_GETSSL_CFG)"
    if ($file | path exists) {
        bf write debug " .. getssl configuration file already exists."
        return $file
    }

    # build arguments
    let args = [
        (bf env --safe "PROXY_GETSSL_FLAGS")
        "-w" # set working directory
        (bf env "PROXY_SSL_CERTS")
        "-c" # create default configuration files
        $domain.primary
    ] | compact --empty | bf dump -t "args"

    # execute getssl
    { ^getssl ...$args } | bf handle

    # return cfg file path
    return $file
}

# Replace a value in a given config file
export def replace [
    key: string         # config key to replace
    value: string       # config value to set
    file: string        # file path to load / save
] {
    # do nothing for empty key
    if ($key | is-empty) { return }

    # replace value
    let find = $"^#?($key).*$" | bf dump -t "regex"
    open --raw $file | str replace --all --regex $find $"($key)=($value)" | save --force $file
}
