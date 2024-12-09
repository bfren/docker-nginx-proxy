use std assert
use bf
use bf/nginx/proxy init *
use vars.nu *


#======================================================================================================================
# setup_clean_install
#======================================================================================================================

export def setup_clean_install__removes_files [] {
    let getssl_global_cfg = mktemp -t
    let sites = mktemp -d -t
    let ssl_certs = mktemp -d -t
    let ssl_dhparam = mktemp -t
    cd $sites ; mktemp ; mktemp
    cd $ssl_certs ; mktemp ; mktemp
    let e = {
        BF_PROXY_GETSSL_GLOBAL_CFG: $getssl_global_cfg
        BF_PROXY_SITES: $sites
        BF_PROXY_SSL_CERTS: $ssl_certs
        BF_PROXY_SSL_DHPARAM: $ssl_dhparam
    }

    let result = with-env $e { setup_clean_install } | {
        GETSSL_GLOBAL_CFG: ($getssl_global_cfg | path exists)
        SITES: ($sites | path exists)
        SITES_FILES: (ls $sites | length)
        SSL_CERTS: ($ssl_certs | path exists)
        SSL_CERTS_FILES: (ls $ssl_certs | length)
        SSL_DHPARAM: ($ssl_dhparam | path exists)
    }

    assert equal false $result.GETSSL_GLOBAL_CFG
    assert equal true $result.SITES
    assert equal 0 $result.SITES_FILES
    assert equal true $result.SSL_CERTS
    assert equal 0 $result.SSL_CERTS_FILES
    assert equal false $result.SSL_DHPARAM
}


#======================================================================================================================
# get_all
#======================================================================================================================

export def get_all__returns_all_domains [] {
    let conf = {
        "domains": [ (generate_domain), (generate_domain), (generate_domain) ]
    }
    let file = mktemp -t
    $conf | to json | save -f $file
    let e = {
        BF_PROXY_SSL_CONF: $file
    }

    let result = with-env $e { get_all }

    assert equal $conf.domains $result
}


#======================================================================================================================
# get_root
#======================================================================================================================

export def get_root__returns_root_domain [] {
    let conf = {
        "domains": [ (generate_domain), (generate_domain), (generate_domain) ]
    }
    let root = $conf.domains.1
    let file = mktemp -t
    $conf | to json | save -f $file
    let e = {
        BF_PROXY_DOMAIN: $root.primary
        BF_PROXY_SSL_CONF: $file
    }

    let result = with-env $e { get_root }

    assert equal $root $result
}


#======================================================================================================================
# get_single
#======================================================================================================================

export def get_single__returns_single_domain [] {
    let conf = {
        "domains": [ (generate_domain), (generate_domain), (generate_domain) ]
    }
    let single = $conf.domains.1
    let file = mktemp -t
    $conf | to json | save -f $file
    let e = {
        BF_PROXY_SSL_CONF: $file
    }

    let result = with-env $e { get_single $single.primary }

    assert equal $single $result
}
