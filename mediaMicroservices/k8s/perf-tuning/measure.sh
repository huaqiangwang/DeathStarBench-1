#! /bin/bash

SCENARIO=$1
NS=media-microsvc

WRK_SCRIPT=mediaMicroservices/wrk2/scripts/media-microservices/compose-review.lua
FRT_URL="http://nginx-web-server.${NS}.svc.cluster.local:8080/wrk2-api/review/compose"

function usage() {
  echo "Usage: measure.sh <scenario>"
  echo "       valid 'scenario' includes:"
  echo "         - single-instance: each uService has only one instance"
  echo "         - baseline: multi-instance case"
  echo "         - cpu-pinning: run uServices with pinned CPU setting"
}

case $SCENARIO in
    "single-instance")
        THREDS=4
        CONNECTION=2000
        DURATION=30
        QPS=8000
        ;;
    "baseline")
        THREDS=4
        CONNECTION=2000
        DURATION=30
        QPS=8000
        ;;
    "cpu-pinning")
        THREDS=4
        CONNECTION=2000
        DURATION=30
        QPS=8000
        ;;

    *)
        echo "Error: Bad parameter"
        echo ""
        usage

        exit -1
esac

kubectl -n $NS exec pod/wrk-client -- wrk -t $THREDS -c $CONNECTION -d $DURATION \
    -R $QPS -s ${WRK_SCRIPT} ${FRT_URL} &
