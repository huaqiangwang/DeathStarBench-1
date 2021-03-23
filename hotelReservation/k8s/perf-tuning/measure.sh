#! /bin/bash

NS=hotel-res

WRK_SCRIPT=hotelReservation/wrk2_lua_scripts/mixed-workload_type_1.lua
FRT_URL=http://frontend.hotel-res.svc.cluster.local:5000

kubectl -n $NS exec pod/wrk-client -- wrk -t 20 -c 200 -d 30 -R 20000 -s ${WRK_SCRIPT} ${FRT_URL} &
