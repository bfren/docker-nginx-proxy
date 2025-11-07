use bf

# Generate Nginx SSL config
export def generate_server_conf []: nothing -> nothing {
    # get the template name
    let template = match (bf env check PROXY_HARDEN) {
        true => "modern"
        false => "intermediate"
    }

    # generate config file
    bf write $"Using ($template) SSL configuration." nginx/generate_server_conf
    bf esh $"(bf env "ETC_TEMPLATES")/ssl-($template).conf.esh" "/etc/nginx/http.d/ssl.conf"

    # return nothing
    return
}

# Generate Nginx site config
export def generate_site_conf [
    domain: record      # the domain record to generate config for
]: nothing -> string {
    # get type-hinted variables
    let primary: string = $domain | get primary
    let upstream: string = $domain | get upstream
    let aliases: list<string> = $domain | get --optional aliases | default []
    let custom: bool = $domain | get --optional custom | default false
    let is_root = $primary == (bf env "PROXY_DOMAIN")

    # generate paths
    let site = $"(bf env PROXY_SITES)/($primary)"
    let conf = $"($site).conf"
    let dir = $"($site).d"
    let template = $"(bf env "ETC_TEMPLATES")/nginx-(match ($is_root) { true => "root" false => "site" }).conf.esh"

    # ensure custom site config directory exists
    if ($dir | bf fs is_not_dir) { mkdir $dir }

    # check for existing configuration file
    if ($conf | path exists) {
        # if custom config is enabled, don't touch the file
        if $custom {
            bf write debug "    keeping custom configuration." nginx/generate_site_conf
            return $conf
        }

        # remove file so it can be regenerated
        bf write debug "    removing file so it can be regenerated." nginx/generate_site_conf
        rm -f $conf
    } else {
        bf write debug "    site is not yet configured." nginx/generate_site_conf
    }

    # set environment values
    let e = {
        ACME_CHALLENGE: (bf env "PROXY_ACME_CHALLENGE")
        CERTS: (bf env "PROXY_SSL_CERTS")
        CUSTOM_CONF: $dir
        DHPARAM: (bf env "PROXY_SSL_DHPARAM")
        DNS_RESOLVER: (bf env "PROXY_UPSTREAM_DNS_RESOLVER")
        DOMAIN_NAME: $primary
        DOMAIN_NAMES: ($primary | append $aliases | str join " ")
        IS_CUSTOM: ($custom | into string)
        NGINX_PUBLIC: (bf env "NGINX_PUBLIC")
        NGINX_WWW: (bf env "NGINX_WWW")
        REDIRECT_TO_CANONICAL: (bf env check "PROXY_SSL_REDIRECT_TO_CANONICAL" | into string)
        UPSTREAM: $upstream
    }

    # generate config file
    bf write debug "    generating file." nginx/generate_site_conf
    with-env $e { bf esh $template $conf }

    # return path to config file
    return $conf
}
