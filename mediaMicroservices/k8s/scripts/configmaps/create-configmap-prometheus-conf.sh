#!/bin/bash

N="media-microsvc"

cd $(dirname $0)/../..

kubectl create cm configmap-prometheus-conf --from-file=configmaps/prometheus -n ${N}

cd -
