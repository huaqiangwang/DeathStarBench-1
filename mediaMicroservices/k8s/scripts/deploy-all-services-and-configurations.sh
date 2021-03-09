#!/bin/bash

cd $(dirname $0)/..
NS="media-microsvc"

kubectl create namespace ${NS}

./scripts/create-all-configmap.sh 
./scripts/create-destination-rule-all.sh

for service in *.yaml
do
  kubectl apply -f $service -n ${NS}
done

echo "Finishing in 30 seconds"
sleep 30

mmsclient=$(kubectl -n ${NS} get pod | grep mms-client- | cut -f 1 -d " ")

echo "After all pods have been created, follow <repo>/mediaMicroservices/k8s/README.md for later operations."

cd - >/dev/null
