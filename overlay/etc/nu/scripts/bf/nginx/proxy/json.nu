use bf

# Load ssl configuration
export def get_domains []: nothing -> list<record<primary: string, upstream: string, aliases: list, custom: bool>> {
    bf env "PROXY_SSL_CONF" | open --raw $in | from json | get domains
}
