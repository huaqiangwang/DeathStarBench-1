#! /bin/bash

SCENARIO=$1
SYSTEM="mediaMicroservices"
NS="media-microsv"
PATCH="patches/$SCENARIO.patch"
GITDIFF=`git diff --stat`

function usage() {
  echo "Usage: deply.sh <scenario>"
  echo "       valid 'scenario' includes:"
  echo "         - baseline: multi-instance case"
}


case $SCENARIO in
    "baseline")
        ;;
    *)
        echo "Error: Bad parameter"
        echo ""
        usage
      
        exit -1
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
cd -

# Apply patch
if [[ -f $PATCH ]]; then
    echo "Apply patch $PATCH ..."
    cd ../../../ && patch -p1 < "$SYSTEM/k8s/perf-tuning/$PATCH" && cd -
fi

# build images
docker build -t mediamicroservices:latest -f ../../Dockerfile ../../

# Start services
cd ../scripts && ./deploy-all-services-and-configurations.sh && \
    ./init-user-data.sh && cd -

python3 ../../scripts/write_movie_info.py \
    && ../../scripts/register_movies.sh \
    && ../../scripts/register_users.sh

# sending request through 'wrk' on machine out of cluster
#wrk
