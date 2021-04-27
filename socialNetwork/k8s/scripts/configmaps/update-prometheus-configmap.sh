#!/bin/bash

NS="social-network"

cd $(dirname $0)/../..

kubectl create cm configmap-prometheus-conf --from-file=prometheus-config --dry-run --save-config -o yaml -n ${NS} | kubectl apply -f - -n ${NS}

cd -
