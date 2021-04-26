#! /bin/bash

# Apply patch
# which should be applied on clean resources

function usage() {
  echo "Usage: deply.sh <scenario>"
  echo "       valid 'scenario' includes:"
  echo "         - baseline: multi-instance case"
}

SCENARIO=$1

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
    
PATCH="patches/$SCENARIO.patch"
GITDIFF=`git diff --stat`

echo "DSB hotelReservation performance tuning test, scenario: $SCENARIO"

if [[ $GITDIFF != '' ]]
then
    echo "You have un-commited changes, abort!"
    exit -1
fi

# Destroy services resources ...
NS=`kubectl get ns |grep 'hotel-res'`
if [[ ${NS} != '' ]]
then
    echo "Destroy hotelReservation services ..."
    pwd
    ../scripts/zap.sh <<EOF
y
y
EOF
fi

IMAGE_UUID=`docker images |grep frontend |awk '{print $3}'`
if [[ ${IMAGE_UUID} != '' ]]
then
    echo "Remove hotel-res docker images"
    docker image rm --force ${IMAGE_UUID}
fi

# Apply patch
echo "Apply patch $PATCH ..."
cd ../../../ && patch -p1 < "hotelReservation/k8s/perf-tuning/$PATCH" && cd -

cd ../scripts && ./build-docker-img.sh && cd -

# Start services
cd ../scripts && ./deploy.sh && cd -
