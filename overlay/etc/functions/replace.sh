#!/bin/bash

replace () {

    K=${1}
    V=${2}
    FILE=${3}

    if [ ! -z "${V}" ] ; then
        sed -i "s|^#\?${K}.*$|${K}=${V}|i" ${FILE}
    fi

}
