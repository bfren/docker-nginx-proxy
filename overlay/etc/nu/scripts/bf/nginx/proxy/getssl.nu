use bf

# Generate getssl global configuration file if it does not already exist
export def generate_global_conf []: nothing -> nothing {
    let getssl_cfg = bf env "PROXY_GETSSL_GLOBAL_CFG"
    if ($getssl_cfg | bf fs is_not_file) {
        # get environment variables
        let e = {
            USE_LIVE_SERVER: (bf env "PROXY_GETSSL_USE_LIVE_SERVER")
            ACCOUNT_EMAIL: (bf env "PROXY_GETSSL_EMAIL")
            ACCOUNT_KEY: (bf env "PROXY_GETSSL_ACCOUNT_KEY")
            RENEW_ALLOW: (bf env "PROXY_GETSSL_RENEW_WINDOW" | into duration | $in / 1day)
            SKIP_HTTP_TOKEN_CHECK: (bf env check "PROXY_GETSSL_SKIP_HTTP_TOKEN_CHECK" | into string)
        }

        # generate configuration
        with-env $e { bf esh template $getssl_cfg }
    } else {
        bf write debug " .. getssl global configuration file already exists." getssl/generate_global_conf
    }
}

# Generate getssl site configuration file
export def generate_site_conf [
    domain: string      # the domain to generate getssl config for
]: nothing -> string {
    # check for existing getssl config
    let certs = bf env "PROXY_SSL_CERTS"
    let file = $"($certs)/($domain)/(bf env "PROXY_GETSSL_CFG")"
    if ($file | path exists) {
        bf write debug " .. getssl configuration file already exists." getssl/generate_site_conf
        return $file
    }

    # build arguments
    let args = [
        (bf env --safe "PROXY_GETSSL_FLAGS")
        "-w" # set working directory
        (bf env "PROXY_SSL_CERTS")
        "-c" # create default configuration files
        $domain
    ] | compact --empty # in case BF_PROXY_GETSSL_FLAGS is not set

    # execute getssl
    bf write debug " .. getssl configuration file already exists." getssl/generate_site_conf
    { ^getssl ...$args } | bf handle

    # return cfg file path
    return $file
}

# Update getssl site configuration file with domain-specific values
export def update_site_conf [
    domain: record      # the domain to generate getssl config for
]: nothing -> string {
    # get variables
    let certs = bf env "PROXY_SSL_CERTS"
    let file = $"($certs)/($domain.primary)/(bf env "PROXY_GETSSL_CFG")"

    # SANS
    let sans = $domain | get --optional aliases | default [] | str join ","
    replace -q "SANS" $sans $file

    # certificate
    let cert = $"($certs)/($domain.primary)"
    replace -q "DOMAIN_CERT_LOCATION" $"($cert).crt" $file
    replace -q "DOMAIN_KEY_LOCATION" $"($cert).key" $file

    # ACL
    let acl = bf env "PROXY_WWW_ACME_CHALLENGE"
    replace "ACL" $"\(\"($acl)\"\)" $file
    replace -q "USE_SINGLE_ACL" "true" $file

    # return cfg file path
    return $file
}

# Replace a value in a given config file
export def replace [
    key: string         # config key to replace
    value: string       # config value to set
    file: string        # file path to load / save
    --add-quotes (-q)   # add double quotes to the value before inserting
]: nothing -> nothing {
    # do nothing for empty key
    if ($key | is-empty) { return }

    # add quotes
    let quoted_value = match $add_quotes { true => $"\"($value)\"" false => $value }

    # replace value
    let find = $"^#?($key).*$"
    load_cfg $key $file | str replace --all --multiline --regex $find $"($key)=($quoted_value)" | save --force $file
}

# Load cfg file and ensure the given key exists
export def load_cfg [
    key: string
    file: string
] {
    let cfg = open --raw $file
    match ($cfg | str contains $key) {
        true => $cfg
        false => ($cfg | append $"#($key)=" | str join (char newline))
    }
}
