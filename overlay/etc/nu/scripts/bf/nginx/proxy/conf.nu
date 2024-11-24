use bf

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
