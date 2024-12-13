use bf
use conf.nu
use getssl.nu
use nginx.nu
use ssl.nu

# Initialise SSL for the specified domain(s).
# Order of precedence:
#   1. `init --all`
#   2. `init --root`
#   3. `init --domain xxxxxx`
export def main [
    --all (-a)              # Initialise root and all configured domains
    --domain (-d): string   # The domain to be initialised
    --root (-d)             # Initialise root domain
]: nothing -> nothing {
    # generate getssl configuration
    bf write "Creating getssl global configuration file." init
    getssl generate_global_conf

    # generate DHPARAM file
    bf write "Generating DHPARAM." init
    ssl generate_dhparam

    # closure to run init procedure
    let init_domain = {|x: record|
        bf write $"Initialising ($x.primary)." init

        # generate Nginx config
        bf write " .. generating Nginx configuration file." init
        nginx generate_site_conf $x

        # generate site getssl conf
        bf write " .. generating getssl configuration file." init
        getssl generate_site_conf $x.primary
        getssl update_site_conf $x

        # generate temporary SSL files
        bf write " .. generating temporary SSL certificates and keys." init
        ssl generate_temp_certs $x.primary
        ssl create_pem $x.primary
    }

    # initialise domain(s)
    if $all {
        get_all | each $init_domain
    }
    else if $root {
        do $init_domain (get_root)
    }
    else if $domain {
        do $init_domain (get_single $domain)
    }
    else {
        main --help
    }

    # done
    bf write ok "Done." init
}

# Check for clean install and delete.
export def setup_clean_install []: nothing -> nothing {
    bf write debug " .. removing SSL config and certificates:" init/setup_clean_install
    bf env "PROXY_GETSSL_GLOBAL_CFG" | remove
    bf env "PROXY_SITES" | $"($in)/*" | remove
    bf env "PROXY_SSL_CERTS" | $"($in)/*" | remove
    bf env "PROXY_SSL_DHPARAM" | remove
}

# Remove file(s) by converting input into a glob before calling `rm`.
def remove []: string -> nothing {
    let file = $in | into glob
    bf write debug $"    ($file)" init/remove
    rm --force --recursive $file
}

# Retrieve all configured domain record.
export def get_all []: nothing -> list<record> { conf get_domains }

# Retrieve a single domain record.
export def get_single [
    domain: string  # The domain to initialise
]: nothing -> record { conf get_domains | where primary == $domain | into record }

# Retrieve the root domain record.
export def get_root []: nothing -> record { get_single (bf env "PROXY_DOMAIN") }
