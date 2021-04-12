#!/bin/bash

N="media-microsvc"

cd $(dirname $0)/../..

kubectl create cm configmap-prometheus-conf --from-file=configmaps/prometheus --dry-run --save-config -o yaml -n ${N} | kubectl apply -f - -n ${N}

cd -
