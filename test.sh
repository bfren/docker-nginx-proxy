#!/bin/sh

IMAGE=`cat VERSION`

docker buildx build \
    --load \
    --build-arg BF_IMAGE=nginx-proxy \
    --build-arg BF_VERSION=${IMAGE} \
    -f Dockerfile \
    -t nginx-proxy-test \
    . \
    && \
    docker run --entrypoint "/usr/bin/env" nginx-proxy-test env -i nu -c "use bf test ; test"
