#! /bin/bash

NS=social-network

WRK_SCRIPT=socialNetwork/wrk2/scripts/social-network/mixed-workload.lua
FRT_URL="http://nginx-thrift.${NS}.svc.cluster.local:8080/wrk2-api/post/compose"

kubectl -n $NS exec pod/wrk-client -- wrk -t 20 -c 2000 -d 30 -R 8000 -s ${WRK_SCRIPT} ${FRT_URL} &
