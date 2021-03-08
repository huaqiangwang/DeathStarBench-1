#!/bin/bash

NS=hotel-res

cd $(dirname $0)/..

kubectl create namespace ${NS} 2>/dev/null

./scripts/create-configmaps.sh
for i in *.yaml
do
  kubectl apply -f ${i} -n ${NS} &
done
wait

echo "Finishing in 30 seconds"
sleep 30

kubectl get pods -n ${NS}

cd - >/dev/null

