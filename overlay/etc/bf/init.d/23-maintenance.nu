use bf
use bf/nginx/proxy maintenance
bf env load

# Generate maintenance helper config and html page
def main []: nothing -> nothing {
    bf write "Generating maintenance files."
    maintenance generate_helper_conf
    maintenance generate_html
    return
}
