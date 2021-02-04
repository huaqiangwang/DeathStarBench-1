#!/bin/bash
[[ "$#" -ne 2 ]] && echo "Usage: $0 <duration> <rate_per_sec> " && exit 1

DIR=$(dirname -- "$0")
DURATION="$1"
QPS="$2"

OUTPUTDIR=`mktemp -d`

TOTAL=`docker-compose -f ${DIR}/docker-compose.yml ps | grep frontend | wc -l`

declare -a PIDS
declare -a OUTPUTS


function get_port {
  let "p = $1 + 5000"
  echo $p
}


function launch_wrk {
  port=$(get_port $1)
  ${DIR}/../mediaMicroservices/wrk2/wrk -D exp -t 16 -c 16 -d $DURATION -L -s ${DIR}/wrk2_lua_scripts/mixed-workload_type_1.lua -R $QPS http://localhost:${port} > ${OUTPUTDIR}/frontend$1 &
  pid=$!
  PIDS+=("$pid")
  OUTPUTS+=("${OUTPUTDIR}/frontend$1")
  echo "Launched wrk for frontend$1 with $pid"
}


function wait_all {
	for p in ${PIDS[@]}; do
		echo "wait $p"
		wait $p
	done
}

function print_all {
	for o in ${OUTPUTS[@]}; do
		echo "... summary of $(basename -- $o) ..."
		cat $o | tail
		echo ""
	done
}


for (( c=0; c<${TOTAL}; c++ ))
do
    launch_wrk $c
done

wait_all
print_all

echo "All wrk logs are in the directory of ${OUTPUTDIR}"
