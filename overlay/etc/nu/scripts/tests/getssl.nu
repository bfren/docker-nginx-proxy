use std assert
use bf
use bf/nginx/proxy getssl *
use vars.nu *


#======================================================================================================================
# generate_conf
#======================================================================================================================

def generate_conf_e [
    --use-live-server
    --email: string
    --account-key: string
    --renew-window: int
    --skip-check
    file: string
] {
    {
        BF_ETC_TEMPLATES: $ETC_TEMPLATES
        BF_PROXY_GETSSL_GLOBAL_CFG: $file
        BF_PROXY_GETSSL_USE_LIVE_SERVER: (match ($use_live_server) { true => "1" false => "0" })
        BF_PROXY_GETSSL_EMAIL: ($email | default (random chars))
        BF_PROXY_GETSSL_ACCOUNT_KEY: ($account_key | default (random chars))
        BF_PROXY_GETSSL_RENEW_WINDOW_DAYS: ($renew_window | default (random int 14..28))
        BF_PROXY_GETSSL_SKIP_HTTP_TOKEN_CHECK: (match $skip_check { true => "1" false => "0" })
    }
}

def get_tmp_file []: nothing -> string { $"/(mktemp -d -t)/getssl-global.conf" }

export def generate_conf__does_nothing_if_file_exists [] {
    let file = get_tmp_file
    let content = random chars
    $content | save $file
    let e = generate_conf_e $file

    let result = with-env $e { generate_conf } | open --raw $file

    assert equal $content $result
}

export def generate_conf__generates_conf_if_file_does_not_exist [] {
    let file = get_tmp_file
    let e = generate_conf_e $file

    let result = with-env $e { generate_conf } | open --raw $file

    assert not equal "" $result
}

export def generate_conf__use_live_server_true_outputs_live_server [] {
    let file = get_tmp_file
    let e = generate_conf_e --use-live-server=true $file

    let result = with-env $e { generate_conf } | open --raw $file

    assert str contains $result $"(char newline)CA=\"https://acme-v02.api.letsencrypt.org\"(char newline)"
}

export def generate_conf__use_live_server_false_outputs_staging_server [] {
    let file = get_tmp_file
    let e = generate_conf_e --use-live-server=false $file

    let result = with-env $e { generate_conf } | open --raw $file

    assert str contains $result $"(char newline)CA=\"https://acme-staging-v02.api.letsencrypt.org\"(char newline)"
}

export def generate_conf__outputs_email [] {
    let file = get_tmp_file
    let email = random chars
    let e = generate_conf_e --email $email $file

    let result = with-env $e { generate_conf } | open --raw $file

    assert str contains $result $"(char newline)ACCOUNT_EMAIL=\"($email)\"(char newline)"
}

export def generate_conf__outputs_account_key [] {
    let file = get_tmp_file
    let key = random chars
    let e = generate_conf_e --account-key $key $file

    let result = with-env $e { generate_conf } | open --raw $file

    assert str contains $result $"(char newline)ACCOUNT_KEY=\"($key)\"(char newline)"
}

export def generate_conf__outputs_renew_allow [] {
    let file = get_tmp_file
    let renew = random int 14..28
    let e = generate_conf_e --renew-window $renew $file

    let result = with-env $e { generate_conf } | open --raw $file

    assert str contains $result $"(char newline)RENEW_ALLOW=\"($renew)\"(char newline)"
}

export def generate_conf__outputs_skip_http_check_false [] {
    let file = get_tmp_file
    let e = generate_conf_e --skip-check=false $file

    let result = with-env $e { generate_conf } | open --raw $file

    assert str contains $result $"(char newline)SKIP_HTTP_TOKEN_CHECK=\"false\"(char newline)"
}

export def generate_conf__outputs_skip_http_check_true [] {
    let file = get_tmp_file
    let e = generate_conf_e --skip-check=true $file

    let result = with-env $e { generate_conf } | open --raw $file

    assert str contains $result $"(char newline)SKIP_HTTP_TOKEN_CHECK=\"true\"(char newline)"
}
