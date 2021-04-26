#!/bin/bash
DIR=$(dirname -- "$0")
EXECNAME=$(basename -- "$0")

THREADS=10
CONNS=50

CORENUM="$(nproc)"

CPUS="0-${CORENUM}"
DURATION=""
QPS=""


OUTPUTDIR=`mktemp -d`

declare -a PIDS
declare -a OUTPUTS


function usage() {
    echo "$EXECNAME: [ -t <threads> ] [ -c <connections> ] [ -C '<cpulist>' ]  -d <duration>  -R <QPS>"
    echo "    <threads>       number of threads, default is 10"
    echo "    <connections>   number of connections, default is 50"
    echo "    <cpulist>       cpu list to bind wrk to, default is 0-${CORENUM}"
    echo "    <duration>      how many seconds to run"
    echo "    <QPS>           request per second"
    exit $1
}

function get_port {
  let "p = $1 + 5000"
  echo $p
}


function launch_wrk {
  port=$(get_port $1)
  taskset -c "${CPUS}" ${DIR}/../mediaMicroservices/wrk2/wrk -D exp -t ${THREADS}  -c ${CONNS} -d ${DURATION} -L -s ${DIR}/wrk2_lua_scripts/mixed-workload_type_1.lua -R $QPS http://localhost:${port} > ${OUTPUTDIR}/frontend$1 &
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


function parse_args {
    while getopts "t:c:R:d:C:h" opt; do
        case $opt in
	  t) THREADS=$OPTARG;;
	  c) CONNS=$OPTARG;;
	  R) QPS=$OPTARG;;
	  d) DURATION=$OPTARG;;
	  C) CPUS="$OPTARG";;
	  h) usage 0;;
        esac
    done

    [[ "x${QPS}" == "x" ]] && usage 1
    [[ "x${DURATION}" == "x" ]] && usage 1
}

parse_args $@

TOTAL=`docker-compose -f ${DIR}/docker-compose.yml ps | grep frontend | wc -l`
echo "Totally frontend count: ${TOTAL}"

for (( c=0; c<${TOTAL}; c++ ))
do
    launch_wrk $c
done

wait_all
print_all

echo "All wrk logs are in the directory of ${OUTPUTDIR}"
