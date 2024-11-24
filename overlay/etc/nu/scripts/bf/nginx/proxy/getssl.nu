use bf

# Generate getssl configuration file if it does not already exist
export def generate_conf []: nothing -> nothing {
    let getssl_cfg = bf env PROXY_GETSSL_GLOBAL_CFG
    if ($getssl_cfg | bf fs is_not_file) {
        # get environment variables
        let e = {
            USE_LIVE_SERVER: (bf env PROXY_GETSSL_USE_LIVE_SERVER)
            ACCOUNT_EMAIL: (bf env PROXY_GETSSL_EMAIL)
            ACCOUNT_KEY: (bf env PROXY_GETSSL_ACCOUNT_KEY)
            RENEW_ALLOW: (bf env PROXY_GETSSL_RENEW_WINDOW_DAYS)
            SKIP_HTTP_TOKEN_CHECK: (bf env check PROXY_GETSSL_SKIP_HTTP_TOKEN_CHECK | into string)
        }

        # generate configuration
        bf write debug "Creating getssl global configuration file" getssl/generate_conf
        with-env $e { bf esh template $getssl_cfg }
    }
}
