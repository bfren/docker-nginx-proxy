use std assert
use bf
use bf/nginx/proxy conf *
use vars.nu *


#======================================================================================================================
# get_domains
#======================================================================================================================

export def get_domains__returns_list_of_domains [] {
    let conf = { "domains": [ (generate_domain) ] }
    let file = mktemp -t
    $conf | to json | save -f $file
    let e = {
        BF_PROXY_SSL_CONF: $file
    }

    let result = with-env $e { get_domains }

    assert equal $conf.domains $result
}
