use bf
use bf/nginx/proxy
bf env load

# Initialise SSL global config and proxy domain
def main []: nothing -> nothing {
    # setup for a clean install
    if (bf env check PROXY_CLEAN_INSTALL) {
        bf write "Clean install detected."
        proxy init setup_clean_install
    }

    # if auto init is enabled, generate config and ssl
    # otherwise, generate SSL for root domain only
    if (proxy auto is_enabled) {
        # set PROXY_AUTO so we know downstream that we are auto generating files
        bf env set "PROXY_AUTO" "1"

        # generate conf.json
        proxy auto generate_conf_json

        # if there are aliases enable canonical redirection
        if (bf env check "PROXY_AUTO_ALIASES") { bf env set "PROXY_SSL_REDIRECT_TO_CANONICAL" "1" }

        # initialise all domains (root plus auto)
        proxy init all
    } else {
        # initialise only the root domain
        proxy init root
    }
}
