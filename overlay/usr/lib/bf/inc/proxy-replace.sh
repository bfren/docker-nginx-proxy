#!/usr/bin/with-contenv bash


#======================================================================================================================
# Replace a key/value pair in a file.
#
# Arguments
#   1   Key
#   2   Value
#   3   File path
#======================================================================================================================

replace () { replace-d "${1}" "\"${2}\"" ${3}; }

replace-d () {

    K=${1}
    V=${2}
    FILE=${3}

    [[ ! -z "${V}" ]] && sed -i "s|^#\?${K}.*$|${K}=${V}|i" ${FILE}

}
