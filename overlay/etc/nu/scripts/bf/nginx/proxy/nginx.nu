use bf
use conf.nu

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
    let conf_d = $"($site).d"
    let template = $"(bf env "ETC_TEMPLATES")/nginx-(match ($is_root) { true => "root" false => "site" }).conf.esh"

    # ensure custom site config directory exists
    if ($conf_d | bf fs is_not_dir) { mkdir $conf_d }

    # check for existing configuration file
    if ($conf | path exists) {
        bf write debug "    config file already exists." nginx/generate_site_conf
        return $conf
    }

    # set environment values
    let e = {
        ACME_CHALLENGE: (bf env "PROXY_ACME_CHALLENGE")
        CERTS: (bf env "PROXY_SSL_CERTS")
        CUSTOM_CONF: $conf_d
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
    bf write debug "    generating config file." nginx/generate_site_conf
    with-env $e { bf esh $template $conf }

    # return path to config file
    $conf
}

# Regenerate Nginx site config for a specified domain
export def regenerate_site_conf [
    domain: record      # the domain record to regenerate nginx config for
    --clean (-c)        # if set, the config directory will be removed as well
    --force (-f)        # if set, custom config files will be removed as well
]: nothing -> string {

    bf write $"Regenerating Nginx config for ($domain.primary)..." nginx/regenerate_site_conf
    let site = $"(bf env PROXY_SITES)/($domain.primary)"
    let conf = $"($site).conf"
    let conf_d = $"($site).d"

    # remove config directory if clean is enabled
    if $clean {
        bf write debug "    removing config directory." nginx/regenerate_site_conf
        rm --force --recursive $conf_d
    }

    # remove custom config only if force is enabled
    let custom: bool = $domain | get --optional custom | default false
    if $custom {
        if $force {
            bf write debug "    force enabled, removing custom config file." nginx/regenerate_site_conf
            rm --force $conf
        }
    } else {
        bf write debug "    removing standard config file." nginx/regenerate_site_conf
        rm --force $conf
    }

    # generate new config
    generate_site_conf $domain
}
