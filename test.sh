#!/bin/sh

IMAGE=nginx-proxy
VERSION=`cat VERSION`
ALPINE=${1:-3.20}
TAG=${IMAGE}-test

docker buildx build \
    --load \
    --build-arg BF_IMAGE=${IMAGE} \
    --build-arg BF_VERSION=${VERSION} \
    -f Dockerfile \
    -t ${TAG} \
    . \
    && \
    docker run --env-file ./test.env --entrypoint /test ${TAG}
