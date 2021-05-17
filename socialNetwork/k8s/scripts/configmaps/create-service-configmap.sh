#!/bin/bash

NS="social-network"
cd $(dirname $0)/../../..

kubectl create cm service-config  --from-file=config -n ${NS}