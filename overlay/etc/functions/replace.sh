#!/bin/bash

replace () { replace_d "${1}" "\"${2}\"" ${3}; }

replace_d () {

    K=${1}
    V=${2}
    FILE=${3}

    if [ ! -z "${V}" ] ; then
        echo " -- ${K}=${V} in ${FILE}..."
        sed -i "s|^#\?${K}.*$|${K}=${V}|i" ${FILE}
    fi

}
