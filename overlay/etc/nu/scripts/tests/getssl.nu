use std assert
use bf
use bf/nginx/proxy getssl *
use vars.nu *


#======================================================================================================================
# generate_global_conf
#======================================================================================================================

def generate_conf_e [
    --use-live-server
    --email: string
    --account-key: string
    --renew-window: duration
    --skip-check
    file: string
] {
    {
        BF_ETC_TEMPLATES: $ETC_TEMPLATES
        BF_PROXY_GETSSL_GLOBAL_CFG: $file
        BF_PROXY_GETSSL_USE_LIVE_SERVER: (match ($use_live_server) { true => "1" false => "0" })
        BF_PROXY_GETSSL_EMAIL: ($email | default (random chars))
        BF_PROXY_GETSSL_ACCOUNT_KEY: ($account_key | default (random chars))
        BF_PROXY_GETSSL_RENEW_WINDOW: ($renew_window | default (random int 14..28 | into duration --unit day))
        BF_PROXY_GETSSL_SKIP_HTTP_TOKEN_CHECK: (match $skip_check { true => "1" false => "0" })
    }
}

def get_tmp_file []: nothing -> string { $"/(mktemp -d -t)/getssl-global.conf" }

export def generate_conf__does_nothing_if_file_exists [] {
    let file = get_tmp_file
    let content = random chars
    $content | save $file
    let e = generate_conf_e $file

    let result = with-env $e { generate_global_conf } | open --raw $file

    assert equal $content $result
}

export def generate_conf__generates_conf_if_file_does_not_exist [] {
    let file = get_tmp_file
    let e = generate_conf_e $file

    let result = with-env $e { generate_global_conf } | open --raw $file

    assert not equal "" $result
}

export def generate_conf__use_live_server_true_outputs_live_server [] {
    let file = get_tmp_file
    let e = generate_conf_e --use-live-server=true $file

    let result = with-env $e { generate_global_conf } | open --raw $file

    assert str contains $result $"(char newline)CA=\"https://acme-v02.api.letsencrypt.org\"(char newline)"
}

export def generate_conf__use_live_server_false_outputs_staging_server [] {
    let file = get_tmp_file
    let e = generate_conf_e --use-live-server=false $file

    let result = with-env $e { generate_global_conf } | open --raw $file

    assert str contains $result $"(char newline)CA=\"https://acme-staging-v02.api.letsencrypt.org\"(char newline)"
}

export def generate_conf__outputs_email [] {
    let file = get_tmp_file
    let email = random chars
    let e = generate_conf_e --email $email $file

    let result = with-env $e { generate_global_conf } | open --raw $file

    assert str contains $result $"(char newline)ACCOUNT_EMAIL=\"($email)\"(char newline)"
}

export def generate_conf__outputs_account_key [] {
    let file = get_tmp_file
    let key = random chars
    let e = generate_conf_e --account-key $key $file

    let result = with-env $e { generate_global_conf } | open --raw $file

    assert str contains $result $"(char newline)ACCOUNT_KEY=\"($key)\"(char newline)"
}

export def generate_conf__outputs_renew_allow [] {
    let file = get_tmp_file
    let renew = random int 14..28 | into duration --unit day
    let e = generate_conf_e --renew-window $renew $file

    let result = with-env $e { generate_global_conf } | open --raw $file

    assert str contains $result $"(char newline)RENEW_ALLOW=\"($renew / 1day | into string)\"(char newline)"
}

export def generate_conf__outputs_skip_http_check_false [] {
    let file = get_tmp_file
    let e = generate_conf_e --skip-check=false $file

    let result = with-env $e { generate_global_conf } | open --raw $file

    assert str contains $result $"(char newline)SKIP_HTTP_TOKEN_CHECK=\"false\"(char newline)"
}

export def generate_conf__outputs_skip_http_check_true [] {
    let file = get_tmp_file
    let e = generate_conf_e --skip-check=true $file

    let result = with-env $e { generate_global_conf } | open --raw $file

    assert str contains $result $"(char newline)SKIP_HTTP_TOKEN_CHECK=\"true\"(char newline)"
}


#======================================================================================================================
# replace
#======================================================================================================================

export def replace__does_nothing_if_key_is_empty [] {
    let file = mktemp -t
    let content = random chars
    $content | save --force $file

    let result = replace "" (random chars) $file | open --raw $file

    assert equal $content $result
}

export def replace__replaces_line_with_empty_value [] {
    let key = random chars
    let file = mktemp -t
    echo $"#($key)=(random chars)" | save --force $file
    let expected = $"($key)="

    let result = replace $key "" $file | open --raw $file

    assert equal $expected $result
}

export def replace__replaces_line_with_hash [] {
    let key = random chars
    let value = random chars
    let file = mktemp -t
    echo $"#($key)=(random chars)" | save --force $file
    let expected = $"($key)=($value)"

    let result = replace $key $value $file | open --raw $file

    assert equal $expected $result
}

export def replace__replaces_line_without_hash [] {
    let key = random chars
    let value = random chars
    let file = mktemp -t
    echo $"($key)=(random chars)" | save --force $file
    let expected = $"($key)=($value)"

    let result = replace $key $value $file | open --raw $file

    assert equal $expected $result
}

export def replace__adds_double_quotes [] {
    let key = random chars
    let value = random chars
    let file = mktemp -t
    echo $"#($key)=(random chars)" | save --force $file
    let expected = $"($key)=\"($value)\""

    let result = replace --add-quotes $key $value $file | open --raw $file

    assert equal $expected $result
}


#======================================================================================================================
# generate_site_conf
#======================================================================================================================

export def generate_site_conf__does_nothing_when_config_exists [] {
    let primary = random chars
    let certs = mktemp -d -t
    let cfg = random chars
    let e = {
        BF_PROXY_SSL_CERTS: $certs
        BF_PROXY_GETSSL_CFG: $cfg
    }
    let content = random chars
    let cfg = $"($certs)/($primary)/($cfg)"
    $cfg | path dirname | mkdir $in
    $content | save --force $cfg

    let result = with-env $e { generate_site_conf $primary } | open --raw

    assert equal $content $result
}

export def generate_site_conf__creates_default_config [] {
    let primary = "do not use random value or hash will break"
    let certs = mktemp -d -t
    let cfg = "getssl.cfg"
    let e = {
        BF_PROXY_SSL_CERTS: $certs
        BF_PROXY_GETSSL_CFG: $cfg
    }
    let cfg = $"($certs)/($primary)/($cfg)"
    let expected = "7146e789a83077202ab129d461959016"

    let result = with-env $e { generate_site_conf $primary } | open --raw | hash md5

    assert equal $expected $result
}
