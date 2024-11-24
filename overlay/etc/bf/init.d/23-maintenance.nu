use bf
bf env load

# Generate maintenance page and config
def main []: nothing -> nothing {
    bf write "Generating maintenance files."
    bf esh template "/etc/nginx/helpers/proxy-maintenance.conf"
    bf esh template $"(bf env NGINX_PUBLIC)/maintenance.html"

    return
}
