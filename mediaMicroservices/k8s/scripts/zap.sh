#!/bin/bash

NS=media-microsvc

echo "Are you really sure you want to erase the ${NS} world? (y/n)"
read a

if [[ "${a}z" != "yz" ]]
then
	echo "The population of the world thanks you!"
	exit 1
fi

echo "Are you really really really sure? (y/n)"
read a

if [[ "${a}z" != "yz" ]]
then
	echo "Doomsday narrowly averted..."
	exit 1
fi


work="cast-info-memcached cast-info-mongodb cast-info-service compose-review-memcached compose-review-service jaeger movie-id-memcached movie-id-mongodb movie-id-service movie-info-memcached movie-info-mongodb movie-info-service movie-review-mongodb movie-review-redis movie-review-service nginx-web-server plot-memcached plot-mongodb plot-service rating-redis rating-service review-storage-memcached review-storage-mongodb review-storage-service text-service unique-id-service user-memcached user-mongodb user-review-mongodb user-review-redis user-review-service user-service prometheus"


echo deleting services and deployments

for d in ${work}
do
	kubectl delete service/$d -n ${NS} &
 	kubectl delete deployment/$d -n ${NS} &
#	kubectl delete pod/$d -n ${NS} &
done
wait

daemonset="cadvisor"
echo "Deleting services and daemonsets"
for d in ${daemonset}
do
    kubectl delete daemonset/$d -n ${NS} &
	kubectl delete service/${d}-out -n ${NS} &
done
wait

echo deleting cm
for c in configmap-gen-lua configmap-jaeger-config-json configmap-lua-scripts configmap-lua-scripts-cast-info configmap-lua-scripts-movie configmap-lua-scripts-movie-info configmap-lua-scripts-plot configmap-lua-scripts-review configmap-lua-scripts-user configmap-nginx-conf configmap-prometheus-conf
do
	kubectl delete cm/${c} -n ${NS} &
done
wait

echo finally deleting namespace ${NS}
kubectl delete namespace/${NS}

echo Finishing in 5 seconds...
sleep 5