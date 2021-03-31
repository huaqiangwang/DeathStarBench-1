# !/bin/bash

function get_web_server_address {
    for t in {1..30}
    do
        eps=`kubectl -n social-network get ep`
        if [[ $eps =~ 'none' ]]; then
            sleep 1
            continue
        fi
        nginx_ep=`kubectl -n social-network get ep | grep nginx-thrift`

        if [[ ! ${nginx_ep} =~ nginx-thrift.*:8080.* ]]; then
            echo ""
            break
        fi

        nginx_ip=`echo ${nginx_ep} | awk '{print $2}'`
        nginx_addr="http://${nginx_ip}"
        echo ${nginx_addr}
        break
    done
    echo ""
}

if [[ $1 == 'on_cluster' ]]; then
    web_server_address='http://nginx-thrift.social-network.svc.cluster.local:8080'
elif [[ $1 == '' ]]; then
    web_server_address=$(get_web_server_address)
    if [[ ${web_server_address} == '' ]]; then
        echo "No nginx-web-server endpoint found"
        exit
    fi
else
    echo 'Usage: init_user_data.sh [on_cluster]'
    exit
fi

cd ../../scripts
script_files='init_social_graph.py'
for file in ${script_files}
do
    echo ${web_server_address}
    sed -i "s|http:.*8080|${web_server_address}|g" $file
done
# fill data
pwd
python3 init_social_graph.py
cd -

cd ../../wrk2/scripts/social-network
wrk_files='compose-post.lua mixed-workload.lua read-home-timeline.lua read-user-timeline.lua'
for file in ${wrk_files}
do
    sed -i "s|http:.*8080|${web_server_address}|g" $file
done
cd -


