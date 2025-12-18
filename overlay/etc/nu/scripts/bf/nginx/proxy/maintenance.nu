use bf
use bf esh template

# Generate Nginx configuration to map the maintenance html file
export def generate_helper_conf []: nothing -> string {
    let e = {
        PUBLIC: (bf env NGINX_PUBLIC)
    }
    with-env $e { template $"(bf env NGINX_ETC_HELPERS)/proxy-maintenance.conf" }
}

# Generate maintenance HTML file
export def generate_html []: nothing -> string {
    let e = {
        REFRESH_SECONDS: (bf env PROXY_MAINTENANCE_REFRESH | into duration | $in / 1sec)
    }
    with-env $e { template $"(bf env NGINX_PUBLIC)/maintenance.html" }
}
