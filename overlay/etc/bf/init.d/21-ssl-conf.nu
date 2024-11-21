use bf
bf env load

# Generate SSL configuration file
def main []: nothing -> nothing {
    let template = match (bf env check PROXY_HARDEN) {
        true => "modern"
        false => "intermediate"
    }

    bf write $"Using ($template) SSL configuration - see https://ssl-config.mozilla.org."
    bf esh $"(bf env ETC_TEMPLATES)/ssl-($template).conf.esh" "/etc/nginx/http.d/ssl.conf"

    return
}
