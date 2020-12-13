#!/usr/bin/with-contenv bash

set -euo pipefail

#======================================================================================================================
# Replace a key/value pair in a file
#   $1  (string) Key
#   $2  (string) Value
#   $3  (string) File path
#======================================================================================================================

replace () { replace_d "${1}" "\"${2}\"" ${3}; }

replace_d () {

    K=${1}
    V=${2}
    FILE=${3}

    if [ ! -z "${V}" ] ; then
        _echo " -- ${K}=${V} in ${FILE}..."
        sed -i "s|^#\?${K}.*$|${K}=${V}|i" ${FILE}
    fi

}
