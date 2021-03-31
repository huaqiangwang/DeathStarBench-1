#! /bin/bash

SCENARIO=$1
SYSTEM="socialNetwork"
NS="social-network"
PATCH="patches/$SCENARIO.patch"
GITDIFF=`git diff --stat`
DOCKERIMAGE="social-network-microservices"

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

cd ..
for file in `ls *.yaml`
do
    sed -i "s/yg397\/social-network-microservices/$DOCKERIMAGE/g" $file
done
cd -

IMAGE_UUID=`docker images |grep '"^$SERVICE\s"' |awk '{print $3}'`
if [[ ${IMAGE_UUID} != '' ]]
then
    # Remove social-network-microservices image
    echo "Remove image $SERVICE"
    docker image rm --force ${IMAGE_UUID}
fi

# Apply patch
if [[ -f $PATCH ]]; then
    echo "Apply patch $PATCH ..."
    cd ../../../ && patch -p1 < "$SYSTEM/k8s/perf-tuning/$PATCH" && cd -
fi

# build images
cd ../scripts && ./build-docker-img.sh && cd -

# Start services and initialize database
cd ../scripts && ./deploy-all-services-and-configurations.sh && \
    ./fill-user-data.sh && cd -

