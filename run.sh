#!/bin/sh

IMAGE=`cat VERSION`

docker buildx build \
    --load \
    --build-arg BF_IMAGE=nginx-proxy \
    --build-arg BF_VERSION=${IMAGE} \
    -f Dockerfile \
    -t nginx-proxy-dev \
    . \
    && \
    docker run -it --env-file ./test.env nginx-proxy-dev sh
