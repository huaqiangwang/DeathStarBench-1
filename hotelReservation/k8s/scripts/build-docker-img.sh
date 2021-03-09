#!/bin/bash

NS=hotel-res

# ENTER THE ROOT FOLDER
cd $(dirname $0)/../../

for i in frontend geo profile rate recommend rsv search user
do
  IMAGE=hotel_reserv_${i}_single_node
  echo Processing image ${IMAGE}
  if [[ $(docker images | grep $IMAGE | wc -l) -le 0 ]]; then
    docker build -t "$IMAGE" -f Dockerfile .
  else
    echo "$IMAGE image already exists"
  fi
  echo
done

echo "Images:"
docker images | grep "$TAG"

cd - >/dev/null
