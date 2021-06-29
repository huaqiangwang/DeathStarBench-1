#!/bin/bash

EXEC=docker

PROJECT="social-network"

cd $(dirname $0)/..

# ENTER IN THE SOCIAL-NETWORK ROOT FOLDER
cd ../
ROOT_FOLDER=$(pwd)

# BUILD MEDIA FRONTEND IMAGE
SERVICE="media-frontend"
TAG="xenial"
if [[ $($EXEC images | grep "^$SERVICE\s" | wc -l) -le 0 ]]; then
  cd docker/media-frontend/
  $EXEC build -t "$SERVICE":"$TAG" -f xenial/Dockerfile .
  cd $ROOT_FOLDER
else
  echo "$SERVICE image already exist"
fi
echo "Images:"
$EXEC images | grep "$TAG"

# BUILD OPENRESTY-THRIFT
SERVICE="openresty-thrift-social"
TAG="xenial"
if [[ $($EXEC images | grep "^$SERVICE\s" | wc -l) -le 0 ]]; then
  cd docker/openresty-thrift/
  $EXEC build -t "$SERVICE":"$TAG" -f xenial/Dockerfile .
  cd $ROOT_FOLDER
else
  echo "$SERVICE image already exist"
fi
echo "Images:"
$EXEC images | grep "$TAG"

# BUILD SOCIAL-NETWORK MICROSERVICE DEPS
SERVICE="thrift-microservice-social-deps"
TAG="xenial"
if [[ $($EXEC images | grep "^$SERVICE\s" | wc -l) -le 0 ]]; then
  cd docker/thrift-microservice-deps
  $EXEC build -t "$SERVICE":"$TAG" -f cpp/Dockerfile .
else
  echo "$SERVICE image already exist"
fi
echo "Images:"
$EXEC images | grep "$TAG"

# BUILD SOCIAL-NETWORK MICROSERVICE
SERVICE="social-network-microservices"
TAG="latest"
if [[ $($EXEC images | grep "^$SERVICE\s" | wc -l) -le 0 ]]; then
  cd $ROOT_FOLDER
  $EXEC build -t "$SERVICE":"$TAG" .
else
  echo "$SERVICE image already exist"
fi
echo "Images:"
$EXEC images | grep "$TAG"
