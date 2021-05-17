#!/bin/bash

NS=social-network

cd $(dirname $0)/../../..

# Since the nginx-thrift service is not built upon the C++ jaeger client,
# this service requires the jaeger-config.json in a different format than
# the one in the ConfigMap jaeger-config. Then, we create a new ConfigMap.
kubectl create cm nginx-thrift-jaeger --from-file=nginx-web-server/jaeger-config.json -n ${NS} --dry-run --save-config -o yaml | kubectl apply -f - -n ${NS}
