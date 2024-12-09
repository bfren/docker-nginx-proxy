use bf
use bf/nginx/proxy conf
bf env load

# Generate SSL configuration file
def main []: nothing -> nothing { conf generate_nginx_server_conf }
