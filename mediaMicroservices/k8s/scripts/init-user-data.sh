# !/bin/bash

function get_web_server_address {
    nginx_ep=`kubectl -n media-microsvc get ep | grep nginx-web-server`

    if [[ ! ${nginx_ep} =~ nginx-web-server.*:8080.* ]]; then
        echo "No nginx-web-server endpoint found"
        exit
    fi

    nginx_ip=`echo ${nginx_ep} | awk '{print $2}'`
    nginx_addr="http://${nginx_ip}"
    echo ${nginx_addr}
}

if [[ $1 == 'on_cluster' ]]; then
    web_server_address='http://nginx-web-server.media-microsvc.svc.cluster.local:8080'
elif [[ $1 == '' ]]; then
    web_server_address=$(get_web_server_address)
else
    echo 'Usage: init_user_data.sh [on_cluster]'
    exit
fi

cd ../../scripts
script_files='write_movie_info.py register_users.sh register_movies.sh compose_review.sh'
for file in ${script_files}
do
    sed -i "s|http:.*8080|${web_server_address}|g" $file
done


cd -
cd ../../wrk2/scripts/media-microservices
wrk_files='compose-review.lua'
for file in ${wrk_files}
do
    sed -i "s|http:.*8080|${web_server_address}|g" $file
done