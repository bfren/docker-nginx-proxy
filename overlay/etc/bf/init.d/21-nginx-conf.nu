use bf
use bf/nginx/proxy nginx
bf env load

# Generate Nginx server SSL configuration file
def main []: nothing -> nothing { nginx generate_server_conf }
