#! /bin/bash

NS=media-microsvc

WRK_SCRIPT=mediaMicroservices/wrk2/scripts/media-microservices/compose-review.lua
FRT_URL="http://nginx-web-server.${NS}.svc.cluster.local:8080/wrk2-api/review/compose"

kubectl -n $NS exec pod/wrk-client -- wrk -t 20 -c 2000 -d 30 -R 8000 -s ${WRK_SCRIPT} ${FRT_URL} &
