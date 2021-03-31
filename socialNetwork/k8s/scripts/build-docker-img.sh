#!/bin/bash

EXEC=docker

TAG="latest"
PROJECT="social-network"

cd $(dirname $0)/..

# ENTER IN THE SOCIAL-NETWORK ROOT FOLDER
cd ../
ROOT_FOLDER=$(pwd)

# BUILD MEDIA FRONTEND IMAGE
SERVICE="media-frontend"
if [[ $($EXEC images | grep $SERVICE | wc -l) -le 0 ]]; then
  cd docker/media-frontend/
  $EXEC build -t "$SERVICE":"$TAG" -f xenial/Dockerfile .
  cd $ROOT_FOLDER
else
  echo "$SERVICE image already exist"
fi

# BUILD OPENRESTY-THRIFT
SERVICE="openresty-thrift"
if [[ $($EXEC images | grep '"^$SERVICE\s"' | wc -l) -le 0 ]]; then
  cd docker/openresty-thrift/
  $EXEC build -t "$SERVICE":"$TAG" -f xenial/Dockerfile .
  cd $ROOT_FOLDER
else
  echo "$SERVICE image already exist"
fi

# BUILD SOCIAL-NETWORK MICROSERVICE DEPS
SERVICE="thrift-microservice-deps"
if [[ $($EXEC images | grep '"^$SERVICE\s"' | wc -l) -le 0 ]]; then
  cd docker/thrift-microservice-deps
  $EXEC build -t "$SERVICE":"$TAG" -f cpp/Dockerfile .
else
  echo "$SERVICE image already exist"
fi

# BUILD SOCIAL-NETWORK MICROSERVICE
SERVICE="social-network-microservices"
if [[ $($EXEC images | grep '"^$SERVICE\s"' | wc -l) -le 0 ]]; then
  cd $ROOT_FOLDER
  $EXEC build -t "$SERVICE":"$TAG" .
else
  echo "$SERVICE image already exist"
fi

echo "Images:"
$EXEC images | grep "$TAG"
