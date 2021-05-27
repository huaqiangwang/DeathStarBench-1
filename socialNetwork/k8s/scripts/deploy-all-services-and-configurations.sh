#!/bin/bash

cd $(dirname $0)/..
NS="social-network"

kubectl create namespace ${NS}

python3 ./scripts/config.py
./scripts/create-all-configmap.sh

# The following script optionally creates local docker images suitable for local customization.
# ./scripts/build-docker-img.sh

for service in *.yaml ;  do
  kubectl apply -f $service -n ${NS}
done

# kubectl expose service nginx-thrift -n ${NS}
# kubectl expose service jaeger-out -n ${NS}

echo "After all pods are running:"
echo "Follow the instructions in k8s/README.md to configure and run init_social_graph.py to load the dataset."

cd - >/dev/null
