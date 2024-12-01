export const ETC_TEMPLATES = "/etc/bf/templates"
export const NGINX_SSL_CONF = "/etc/nginx/http.d/ssl.conf"

# Generate a random domain record
export def generate_domain [
    --aliases: list<string>     # set aliases instead of random list
    --primary: string           # set primary instead of random characters
    --upstream: string          # set upstream instead of random characters
    custom?: bool               # set custom instead of random boolean
]: nothing -> record<primary: string, upstream: string, aliases: list, custom: bool> {
    {
        "primary": ($primary | default (random chars))
        "upstream": ($upstream | default (random chars))
        "aliases": ($aliases | default [(random chars) (random chars)] )
        "custom": ($custom | default (random bool))
    }
}
