use std assert
use bf
use bf/nginx/proxy maintenance *
use vars.nu *


#======================================================================================================================
# generate_helper_conf
#======================================================================================================================

export def generate_helper_conf__outputs_conf [] {
    let helpers = mktemp -d -t
    let public = random chars
    let e = {
        BF_ETC_TEMPLATES: $ETC_TEMPLATES
        BF_NGINX_ETC_HELPERS: $helpers
        BF_NGINX_PUBLIC: $public
    }

    let result = with-env $e { generate_helper_conf } | open --raw $"($helpers)/proxy-maintenance.conf"

    assert str contains $result $"root                                ($public);"
}


#======================================================================================================================
# generate_html
#======================================================================================================================

export def generate_html__outputs_html [] {
    let public = mktemp -d -t
    let refresh = random int 5..50
    let e = {
        BF_ETC_TEMPLATES: $ETC_TEMPLATES
        BF_NGINX_PUBLIC: $public
        BF_PROXY_MAINTENANCE_REFRESH: ($refresh | into duration --unit sec)
    }

    let result = with-env $e { generate_html } | open --raw $"($public)/maintenance.html"

    assert str contains $result $"This page will auto-refresh in <span id=\"remaining\">($refresh)</span>s."
    assert str contains $result $"let remaining = ($refresh);"
}
