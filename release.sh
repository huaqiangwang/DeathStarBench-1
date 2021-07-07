#!/usr/bin/env bash

set -e

function die() {
    message=${1-Died}
    echo "${BASH_SOURCE[1]}: line ${BASH_LINENO[0]}: ${FUNCNAME[1]}: $message." >&2
    exit 1
}

[ -z "$DOCKER_USERNAME" ] && die "Please set environment variable DOCKER_USERNAME"
[ -z "$DOCKER_PASSWORD" ] && die "Please set environment variable DOCKER_PASSWORD"


revid=$(git log -1 --oneline | cut -d ' ' -f 1)

BUILDDIR=/tmp/dsbpp-build-$revid

function prepdir() {
    rm -rf $BUILDDIR
    git clone https://github.com/intel-sandbox/DeathStarBenchPlusPlus $BUILDDIR
    cd $BUILDDIR
    git checkout $revid
}


#tag=$(git describe --abbrev=0 --tags)

function release() {
    name="$1"
    tag="$2"
    path="$3"
    image="${DOCKER_USERNAME}/${name}"
    platform="linux/amd64,linux/arm64"

    echo "Building '$image'. Context: '$path'"
    cd $BUILDDIR
    docker buildx inspect "$name" || docker buildx create --name "$name" --use --append
    docker buildx use "$name"
    docker buildx build --platform "$platform" -t "$image:$tag" -t "$image:latest" --push "$path"
    docker buildx imagetools inspect "$image:latest"
}

prepdir
docker login -u $DOCKER_USERNAME -p $DOCKER_PASSWORD
release "dsbpp_hotel_reserv" "$revid" hotelReservation/
