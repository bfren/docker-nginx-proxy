#!/bin/bash

#======================================================================================================================
# This file should be modified to define domain arrays
# and then stored in /ssl/conf/sites.sh
#
# DOMAINS is an associative array
#   key:    (string) primary domain name
#   value:  (string) upstream server
#
# ALIASES is an associative array
#   key:    (string) primary domain name - if it doesn't match one of the keys in DOMAINS, it will be ignored
#   value:  (string array) alias domain names to be included in the SSL certificate
#
# These arrays will generate configuration files that will be stored in /ssl/conf
# After generation they can be modified to suit your needs - after modification, the container should be restarted
#======================================================================================================================

DOMAINS["example.com"]="http://example"
ALIASES["example.com"]=("www.example.com" "ex.com" "www.ex.com")

DOMAINS["test.com"]="http://test"
ALIASES["test.com"]=("www.test.com")
