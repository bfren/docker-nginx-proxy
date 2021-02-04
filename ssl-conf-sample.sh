#!/bin/bash

#======================================================================================================================
# This file should be modified to define domain arrays
# and then stored in /ssl/conf.sh
#
# DOMAINS is an associative array
#   key:    (string) primary domain name
#   value:  (string) upstream server
#
# ALIASES is an associative array
#   key:    (string) primary domain name - if it doesn't match one of the keys in DOMAINS, it will be ignored
#   value:  (string) alias domain names to be included in the SSL certificate, separated by a space
#
# NGXCONF is an optional associative array
#   key:    (string) primary domain name - if it doesn't match one of the keys in DOMAINS, it will be ignored
#   value:  (string) "custom" by convention - but if you set this to *anything*, Nginx config for this site won't be
#           automatically regenerated, so you won't get new features and be responsible for maintaining it yourself
#
# These arrays will generate configuration files that will be stored in /sites and /ssl/certs
# After generation they can be modified to suit your needs - after modification, the container should be restarted
#======================================================================================================================

DOMAINS["example.com"]="http://example"
ALIASES["example.com"]="www.example.com" "ex.com" "www.ex.com"
NGXCONF["example.com"]="custom"

DOMAINS["test.com"]="http://test"
ALIASES["test.com"]="www.test.com"
# no NGXCONF means Nginx configuration will be regenerated each time the container starts
# the advantage of this is you automatically get new features / bug fixes
