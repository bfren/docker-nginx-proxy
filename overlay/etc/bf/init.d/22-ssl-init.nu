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

    # initialise only the root domain
    proxy init --root
}
