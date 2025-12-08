use std assert
use bf
use bf/nginx/proxy nginx *
use vars.nu *


#======================================================================================================================
# generate_server_conf
#======================================================================================================================

def generate_nginx_ssl_conf_e [
    --harden            # Optional harden switch
] {
    {
        BF_ETC_TEMPLATES: $ETC_TEMPLATES
        BF_PROXY_HARDEN: (match $harden { true => "1", false => "" })
    }
}

export def generate_nginx_ssl_conf__outputs_intermediate_conf [] {
    let e = generate_nginx_ssl_conf_e
    let expected = "c6f62672330e60f47657a720c2ffd693"

    let result = with-env $e { generate_server_conf } | open --raw $NGINX_SSL_CONF | hash md5

    assert equal $expected $result
}

export def generate_nginx_ssl_conf__outputs_modern_conf [] {
    let e = generate_nginx_ssl_conf_e --harden
    let expected = "641b08342873b272be06190413aacf8c"

    let result = with-env $e { generate_server_conf } | open --raw $NGINX_SSL_CONF | hash md5

    assert equal $expected $result
}


#======================================================================================================================
# generate_site_conf
#======================================================================================================================

def generate_site_conf_e [
    --acme-challenge: string
    --certs: string
    --dhparam: string
    --nginx-public: string
    --nginx-www: string
    --redirect-to-canonical
    --resolver: string
    --root-domain: string
    sites_dir
] {
    {
        BF_ETC_TEMPLATES: $ETC_TEMPLATES
        BF_NGINX_PUBLIC: ($nginx_public | default (random chars))
        BF_NGINX_WWW: ($nginx_www | default (random chars))
        BF_PROXY_ACME_CHALLENGE: ($acme_challenge | default (random chars))
        BF_PROXY_DOMAIN: ($root_domain | default (random chars))
        BF_PROXY_SSL_CERTS: ($certs | default (random chars))
        BF_PROXY_SSL_DHPARAM: ($dhparam | default (random chars))
        BF_PROXY_SSL_REDIRECT_TO_CANONICAL: (match $redirect_to_canonical { true => "1" false => "0" })
        BF_PROXY_SITES: $sites_dir
        BF_PROXY_UPSTREAM_DNS_RESOLVER: ($resolver | default (random chars))
    }
}

export def generate_site_conf__creates_site_directory_when_does_not_exist [] {
    let primary = random chars
    let domain = generate_domain --primary $primary
    let sites_dir = $"/tmp/(random chars)"
    let e = generate_site_conf_e $sites_dir

    let result = with-env $e { generate_site_conf $domain } | echo $sites_dir | path exists

    assert equal true $result
}

export def generate_site_conf__keeps_config_when_exists [] {
    let primary = random chars
    let domain = generate_domain --primary $primary true
    let sites_dir = mktemp -d -t
    let content = random chars
    $content | save --force $"($sites_dir)/($primary).conf"
    let e = generate_site_conf_e $sites_dir

    let result = with-env $e { generate_site_conf $domain } | open --raw $in

    assert equal $content $result
}

export def generate_site_conf__outputs_acme_challenge [] {
    let domain = generate_domain
    let sites_dir = mktemp -d -t
    let acme_challenge = random chars
    let e = generate_site_conf_e --acme-challenge $acme_challenge $sites_dir

    let result = with-env $e { generate_site_conf $domain } | open --raw $in

    assert str contains $result $"location ^~ /($acme_challenge) {"
}

export def generate_site_conf__outputs_acme_challenge_when_root [] {
    let primary = random chars
    let domain = generate_domain --primary $primary
    let sites_dir = mktemp -d -t
    let acme_challenge = random chars
    let e = generate_site_conf_e --acme-challenge $acme_challenge --root-domain $primary $sites_dir

    let result = with-env $e { generate_site_conf $domain } | open --raw $in

    assert str contains $result $"location ^~ /($acme_challenge) {"
}

export def generate_site_conf__outputs_ssl_certs [] {
    let primary = random chars
    let domain = generate_domain --primary $primary
    let sites_dir = mktemp -d -t
    let certs = random chars
    let e = generate_site_conf_e --certs $certs $sites_dir

    let result = with-env $e { generate_site_conf $domain } | open --raw $in

    assert str contains $result $"ssl_trusted_certificate         ($certs)/($primary)/chain.crt;"
    assert str contains $result $"ssl_certificate                 ($certs)/($primary)/fullchain.crt;"
    assert str contains $result $"ssl_certificate_key             ($certs)/($primary).key;"
}

export def generate_site_conf__outputs_ssl_certs_when_root [] {
    let primary = random chars
    let domain = generate_domain --primary $primary
    let sites_dir = mktemp -d -t
    let certs = random chars
    let e = generate_site_conf_e --certs $certs --root-domain $primary $sites_dir

    let result = with-env $e { generate_site_conf $domain } | open --raw $in

    assert str contains $result $"ssl_trusted_certificate         ($certs)/($primary)/chain.crt;"
    assert str contains $result $"ssl_certificate                 ($certs)/($primary)/fullchain.crt;"
    assert str contains $result $"ssl_certificate_key             ($certs)/($primary).key;"
}

export def generate_site_conf__includes_custom_conf [] {
    let primary = random chars
    let domain = generate_domain --primary $primary true
    let sites_dir = mktemp -d -t
    let e = generate_site_conf_e $sites_dir

    let result = with-env $e { generate_site_conf $domain } | open --raw $in

    assert str contains $result $"include                     ($sites_dir)/($primary).d/*.conf;"
}

export def generate_site_conf__includes_custom_conf_when_root [] {
    let primary = random chars
    let domain = generate_domain --primary $primary true
    let sites_dir = mktemp -d -t
    let e = generate_site_conf_e --root-domain $primary $sites_dir

    let result = with-env $e { generate_site_conf $domain } | open --raw $in

    assert str contains $result $"include                         ($sites_dir)/($primary).d/*.conf;"
}

export def generate_site_conf__outputs_dhparam [] {
    let domain = generate_domain
    let sites_dir = mktemp -d -t
    let dhparam = random chars
    let e = generate_site_conf_e --dhparam $dhparam $sites_dir

    let result = with-env $e { generate_site_conf $domain } | open --raw $in

    assert str contains $result $"ssl_dhparam                     ($dhparam);"
}

export def generate_site_conf__outputs_dhparam_when_root [] {
    let primary = random chars
    let domain = generate_domain --primary $primary
    let sites_dir = mktemp -d -t
    let dhparam = random chars
    let e = generate_site_conf_e --dhparam $dhparam --root-domain $primary $sites_dir

    let result = with-env $e { generate_site_conf $domain } | open --raw $in

    assert str contains $result $"ssl_dhparam                     ($dhparam);"
}

export def generate_site_conf__outputs_dns_resolver [] {
    let domain = generate_domain
    let sites_dir = mktemp -d -t
    let resolver = random chars
    let e = generate_site_conf_e --resolver $resolver $sites_dir

    let result = with-env $e { generate_site_conf $domain } | open --raw $in

    assert str contains $result $"resolver                    ($resolver) valid=30s;"
}

export def generate_site_conf__outputs_server_names [] {
    let primary = random chars
    let aliases = [(random chars) (random chars) (random chars)]
    let server_names = $primary | append $aliases | str join " "
    let domain = generate_domain --primary $primary --aliases $aliases
    let sites_dir = mktemp -d -t
    let e = generate_site_conf_e $sites_dir

    let result = with-env $e { generate_site_conf $domain } | open --raw $in

    assert str contains $result $"# serve HTTP site for these domain names
    server_name                     ($server_names);"
    assert str contains $result $"# serve HTTPS site for these domain names
    server_name                     ($server_names);"
}

export def generate_site_conf__without_aliases_outputs_only_primary_to_server_names [] {
    let domain = generate_domain | reject aliases
    let sites_dir = mktemp -d -t
    let e = generate_site_conf_e $sites_dir

    let result = with-env $e { generate_site_conf $domain } | open --raw $in

    assert str contains $result $"# serve HTTP site for these domain names
    server_name                     ($domain.primary);"
    assert str contains $result $"# serve HTTPS site for these domain names
    server_name                     ($domain.primary);"
}

export def generate_site_conf__allows_changes_when_custom_is_true [] {
    let domain = generate_domain true
    let sites_dir = mktemp -d -t
    let e = generate_site_conf_e $sites_dir

    let result = with-env $e { generate_site_conf $domain } | open --raw $in

    assert str contains $result "# You can make changes to this file."
}

export def generate_site_conf__disallows_changes_when_custom_is_false [] {
    let domain = generate_domain false
    let sites_dir = mktemp -d -t
    let e = generate_site_conf_e $sites_dir

    let result = with-env $e { generate_site_conf $domain } | open --raw $in

    assert str contains $result "# WARNING: This file is generated. Do not make changes to this file."
}

export def generate_site_conf__disallows_changes_when_custom_is_not_set [] {
    let domain = generate_domain | reject custom
    let sites_dir = mktemp -d -t
    let e = generate_site_conf_e $sites_dir

    let result = with-env $e { generate_site_conf $domain } | open --raw $in

    assert str contains $result "# WARNING: This file is generated. Do not make changes to this file."
}

export def generate_site_conf__outputs_nginx_public_when_root [] {
    let primary = random chars
    let domain = generate_domain --primary $primary
    let sites_dir = mktemp -d -t
    let nginx_public = random chars
    let e = generate_site_conf_e --nginx-public $nginx_public --root-domain $primary $sites_dir

    let result = with-env $e { generate_site_conf $domain } | open --raw $in

    assert str contains $result $"root                            ($nginx_public);"
}

export def generate_site_conf__outputs_nginx_www [] {
    let domain = generate_domain
    let sites_dir = mktemp -d -t
    let nginx_www = random chars
    let e = generate_site_conf_e --nginx-www $nginx_www $sites_dir

    let result = with-env $e { generate_site_conf $domain } | open --raw $in

    assert str contains $result $"root                        ($nginx_www);"
}

export def generate_site_conf__outputs_nginx_www_when_root [] {
    let primary = random chars
    let domain = generate_domain --primary $primary
    let sites_dir = mktemp -d -t
    let nginx_www = random chars
    let e = generate_site_conf_e --nginx-www $nginx_www --root-domain $primary $sites_dir

    let result = with-env $e { generate_site_conf $domain } | open --raw $in

    assert str contains $result $"root                        ($nginx_www);"
}

export def generate_site_conf__redirects_to_canonical [] {
    let primary = random chars
    let domain = generate_domain --primary $primary
    let sites_dir = mktemp -d -t
    let e = generate_site_conf_e --redirect-to-canonical $sites_dir

    let result = with-env $e { generate_site_conf $domain } | open --raw $in

    assert str contains $result $"return                      301 https://($primary)$request_uri;"
    assert str contains $result $"if \($host != ($primary)\) {
        return                      301 https://($primary)$request_uri;
    }"
}

export def generate_site_conf__redirects_to_canonical_when_root [] {
    let primary = random chars
    let domain = generate_domain --primary $primary
    let sites_dir = mktemp -d -t
    let e = generate_site_conf_e --root-domain $primary $sites_dir

    let result = with-env $e { generate_site_conf $domain } | open --raw $in

    assert str contains $result $"return                      301 https://($primary)$request_uri;"
    assert str contains $result $"if \($host != ($primary)\) {
        return                      301 https://($primary)$request_uri;
    }"
}

export def generate_site_conf__redirects_to_current_host [] {
    let domain = generate_domain
    let sites_dir = mktemp -d -t
    let e = generate_site_conf_e $sites_dir

    let result = with-env $e { generate_site_conf $domain } | open --raw $in

    assert str contains $result "return                      301 https://$host$request_uri;"
}

export def generate_site_conf__outputs_upstream [] {
    let upstream = random chars
    let domain = generate_domain --upstream $upstream
    let sites_dir = mktemp -d -t
    let nginx_www = random chars
    let e = generate_site_conf_e --nginx-www $nginx_www $sites_dir

    let result = with-env $e { generate_site_conf $domain } | open --raw $in

    assert str contains $result $"set $upstream               ($upstream);"
}


#======================================================================================================================
# reenerate_site_conf
#======================================================================================================================

export def regenerate_site_conf__keeps_config_when_custom_is_true [] {
    let primary = random chars
    let domain = generate_domain --primary $primary true
    let sites_dir = mktemp -d -t
    let content = random chars
    $content | save --force $"($sites_dir)/($primary).conf"
    let e = generate_site_conf_e $sites_dir

    let result = with-env $e { regenerate_site_conf $domain } | open --raw $in

    assert equal $content $result
}

export def regenerate_site_conf__regenerates_config_when_custom_is_false [] {
    let primary = random chars
    let domain = generate_domain --primary $primary false
    let sites_dir = mktemp -d -t
    let content = random chars
    $content | save --force $"($sites_dir)/($primary).conf"
    let e = generate_site_conf_e $sites_dir

    let result = with-env $e { regenerate_site_conf $domain } | open --raw $in

    assert not equal $content $result
}

export def regenerate_site_conf__regenerates_config_when_custom_is_true_and_force_is_enabled [] {
    let primary = random chars
    let domain = generate_domain --primary $primary true
    let sites_dir = mktemp -d -t
    let content = random chars
    $content | save --force $"($sites_dir)/($primary).conf"
    let e = generate_site_conf_e $sites_dir

    let result = with-env $e { regenerate_site_conf --force $domain } | open --raw $in

    assert not equal $content $result
}

export def regenerate_site_conf__keeps_config_dir_when_clean_is_false [] {
    let primary = random chars
    let domain = generate_domain --primary $primary true
    let sites_dir = mktemp -d -t
    let site_dir = $"($sites_dir)/($primary).d"
    mkdir $site_dir
    mktemp --tmpdir-path $site_dir
    let e = generate_site_conf_e $sites_dir

    let result = with-env $e { regenerate_site_conf $domain } | ls $site_dir | length

    assert equal 1 $result
}

export def regenerate_site_conf__regenerates_config_dir_when_clean_is_true [] {
    let primary = random chars
    let domain = generate_domain --primary $primary true
    let sites_dir = mktemp -d -t
    let site_dir = $"($sites_dir)/($primary).d"
    mkdir $site_dir
    mktemp --tmpdir-path $site_dir
    let e = generate_site_conf_e $sites_dir

    let result = with-env $e { regenerate_site_conf --clean $domain } | ls $site_dir | length

    assert equal 0 $result
}
