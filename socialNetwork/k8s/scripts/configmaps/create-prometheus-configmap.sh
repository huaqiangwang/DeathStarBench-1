#!/bin/bash

cd $(dirname $0)/../..

kubectl create cm configmap-prometheus-conf --from-file=prometheus-config -n social-network

cd -
