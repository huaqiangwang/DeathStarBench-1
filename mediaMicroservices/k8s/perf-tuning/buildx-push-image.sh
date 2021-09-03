#!env bash

# build images
PLATS="linux/amd64"
#PLATS="linux/arm64"
#PLATS="linux/arm64,linux/amd64"
docker run --rm --privileged multiarch/qemu-user-static --reset -p yes
docker buildx create --name builder --driver docker-container --use
docker buildx inspect --bootstrap
#docker buildx build --platform $PLATS -t aenniwang/thrift-microservice-media-deps:xenial -f ../../docker/thrift-microservice-deps/cpp/Dockerfile ../../docker/thrift-microservice-deps --push
#docker buildx build  --platform $PLATS -t aenniwang/openresty-thrift-media:xenial -f ../../docker/openresty-thrift/xenial/Dockerfile ../../docker/openresty-thrift --push
docker buildx build  --platform $PLATS -t aenniwang/mediamicroservices:loop2 -f ../../Dockerfile ../../ --push

