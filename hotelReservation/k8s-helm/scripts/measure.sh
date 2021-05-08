#! /bin/bash

NS=hotel-res

WRK_SCRIPT=hotelReservation/wrk2_lua_scripts/mixed-workload_type_1.lua

wrk_clients=`kubectl -n $NS get pods | grep wrk-client | awk '{print $1}' | tr '\n' ' '`

i=0
port=5000
for client in ${wrk_clients}
do
FRT_URL="http://frontend$i.hotel-res.svc.cluster.local:$port"

cmd="kubectl -n $NS exec pod/$client -- wrk -t 20 -c 200 -d 30 -R 20000 -s ${WRK_SCRIPT}  ${FRT_URL}"
echo $cmd
$cmd &
i=$((i+1))
done
wait

