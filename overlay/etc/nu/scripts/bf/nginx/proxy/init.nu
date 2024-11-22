use bf

# Initialise SSL for all configured domains
export def all []: nothing -> nothing {

}

# Initialise SSL for the specified domain
export def domain [
    domain: string  # The domain to initialise
]: nothing -> nothing {

}

# Initialise SSL for the root domain
export def root [

]: nothing -> nothing {
    domain (bf env "PROXY_DOMAIN")
}
