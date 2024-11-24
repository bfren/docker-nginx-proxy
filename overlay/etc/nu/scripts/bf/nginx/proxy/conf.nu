use bf

# Load ssl configuration
export def load []: nothing -> record<domains: list<record<primary: string, upstream: string, aliases: list, custom: bool>>> {
    bf env "PROXY_SSL_CONF" | open --raw $in | from json
}

# Generate Nginx SSL config
export def generate_nginx_ssl_conf []: nothing -> nothing {
    # get the template name
    let template = match (bf env check PROXY_HARDEN) {
        true => "modern"
        false => "intermediate"
    }

    # generate config file
    bf write $"Using ($template) SSL configuration."
    bf esh $"(bf env ETC_TEMPLATES)/ssl-($template).conf.esh" "/etc/nginx/http.d/ssl.conf"

    # return nothing
    return
}
