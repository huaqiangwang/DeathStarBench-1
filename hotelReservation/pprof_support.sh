#!/bin/bash

DIR=$(dirname -- "$0")

SYMFSROOT="/tmp/hotelReservation_symfs"

function fetch_execs () {
	rm -rf $SYMFSROOT
	mkdir -p $SYMFSROOT/go/bin

	for cmd in `ls "${DIR}/cmd" `; do
	    sudo docker cp -L hotel_reserv_rate:/go/bin/${cmd} ${SYMFSROOT}/go/bin
	done
	echo "Fechted all the service executables under ${SYMFSROOT}"
}


function get_pprof_cpu() {
	service=$1
	case $service in
	  frontend)
	    port=5000
	    ;;
	  profile)
            port=18081
	    ;;
	  search)
	    port=18082
	    ;;
	  geo)
	    port=18083
	    ;;
	  rate)
            port=18084
	    ;;
	  recommendation)
	    port=18085
	    ;;
	  user)
	    port=18086
	    ;;
	  reservation)
	    port=18087
	    ;;
	  *)
	    echo "Error: Unknown service $service!"
            return 1
	    ;;
	esac
	seconds=$2

	if [ "${seconds}x" == "x" ]; then
		seconds=30
	fi
	timestamp=`date -Iseconds | cut -d '+' -f 1 | sed 's/:/_/g'`
        output="/tmp/pprof.profile.samples.cpu.${service}.${timestamp}.pb.gz"
	go tool pprof -proto -output ${output} "http://localhost:$port/debug/pprof/profile?seconds=${seconds}" && echo "Please use pprof data file ${output} for further analysis"
}
