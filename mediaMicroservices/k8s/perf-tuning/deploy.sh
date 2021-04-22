#! /bin/bash

SCENARIO=$1
SYSTEM="mediaMicroservices"
NS="media-microsv"
PATCH="patches/$SCENARIO.patch"
GITDIFF=`git diff --stat`
KUBELET_CONF_FILE='/var/lib/kubelet/config.yaml' 
CPU_MANAGER_STATE='/var/lib/kubelet/cpu_manager_state'

function usage() {
  echo "Usage: deply.sh <scenario>"
  echo "       valid 'scenario' includes:"
  echo "         - single-instance: each uService has only one instance"
  echo "         - baseline: multi-instance case"
  echo "         - cpu-pinning: run uServices with pinned CPU setting"
}

function kubelet_cpu_manager_clear() {
    sudo sed -i '/#### BLOCK START/,+7 d' ${KUBELET_CONF_FILE}

    sudo grep -e '#### BLOCK START: CPU MANAGER' ${KUBELET_CONF_FILE} >/dev/null

    if [[ $? == 0 ]]; then
        # found. error!
        echo "Failed in clearing kubelet cpu manager information" >&2
        exit 2
    fi
}

function kubelet_cpu_manager_set_static() {
    echo "#### BLOCK START: CPU MANAGER SETTING BY DSB PERF-TURN" |sudo tee -a ${KUBELET_CONF_FILE} >/dev/null
    echo "#### DON'T EDIT THIS BLOCK" |sudo tee -a ${KUBELET_CONF_FILE} >/dev/null
    echo "cpuManagerPolicy: static" |sudo tee -a ${KUBELET_CONF_FILE} >/dev/null
    echo "kubeReserved:" |sudo tee -a ${KUBELET_CONF_FILE} >/dev/null
    echo "  cpu: 500m" |sudo tee -a ${KUBELET_CONF_FILE} >/dev/null
    echo "systemReserved:" |sudo tee -a ${KUBELET_CONF_FILE} >/dev/null
    echo "  cpu: 500m" |sudo tee -a ${KUBELET_CONF_FILE} >/dev/null
    echo "#### BLOCK END" |sudo tee -a ${KUBELET_CONF_FILE} >/dev/null
    sudo grep '#### BLOCK START: CPU MANAGER' ${KUBELET_CONF_FILE} >/dev/null
    if [[ $? != 0 ]]; then
        echo "Failed in setting CPU manager policy to kubelet"
        # not found. error!
        exit 2
    fi
}

function kubelet_restart() {
    sudo rm ${CPU_MANAGER_STATE}
    sudo systemctl restart kubelet
    sleep 15
}

function kubelet_check_cpu_static_policy() {
    sudo grep -e '"policyName".*static"' ${CPU_MANAGER_STATE} >/dev/null
    if [[ $? == 0 ]]; then
        echo 'static'
        return
    fi 

    echo 'none'
}

case $SCENARIO in
    "single-instance")
        ;;
    "baseline")
        ;;
    "cpu-pinning")
        kubelet_cpu_manager_clear
        kubelet_cpu_manager_set_static
        kubelet_restart
        policy=$(kubelet_check_cpu_static_policy)
        if [[ $policy != 'static' ]]; then
            echo "Failed in settting CPU manager policy to 'static'!"
            exit 3
        fi
        ;;

    *)
        echo "Error: Bad parameter"
        echo ""
        usage
      
        exit 1
        ;;
esac

echo "DSB $SYSTEM performance tunning test, scenario: $SCENARIO"

if [[ $GITDIFF != '' ]]
then
    echo "You have un-commited changes, abort!"
    exit -1
fi

# Destroy services resources ...

if [[ `kubectl get ns |grep $NS` != '' ]]
then
    echo "Destroy $SYSTEM ..."
    pwd
    ../scripts/zap.sh <<EOF
y
y
EOF
fi

# Apply patch
if [[ -f $PATCH ]]; then
    echo "Apply patch $PATCH ..."
    cd ../../../ && patch -p1 < "$SYSTEM/k8s/perf-tuning/$PATCH" && cd -
fi

IMAGE_UUID=`docker images |grep mediamicroservices |awk '{print $3}'`
if [[ ${IMAGE_UUID} != '' ]]
then
    echo "Remove $SYSTEM  docker images"
    docker image rm --force ${IMAGE_UUID}
fi

cd ..
for file in `ls *.yaml`
do
    sed -i 's/yg397\/media-microservices/mediamicroservices/g' $file
done

nginxconf=nginx-web-server.yaml
sed -i 's/yg397\/openresty-thrift:xenial/openresty-thrift:xenial/g' $nginxconf
cd -

# stop at any error
set -e

# build images
docker build -t mediamicroservices:latest -f ../../Dockerfile ../../
docker build -t openresty-through:xenial -f ../../docker/openresty-thrift/xenial/Dockerfile ../../docker/openresty-thrift

# Start services
cd ../scripts && ./deploy-all-services-and-configurations.sh && \
    ./init-user-data.sh && cd -

python3 ../../scripts/write_movie_info.py \
    && ../../scripts/register_movies.sh \
    && ../../scripts/register_users.sh

# sending request through 'wrk' on machine out of cluster
#wrk

set +e
