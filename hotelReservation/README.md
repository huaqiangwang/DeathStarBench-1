# Hotel Reservation

The application implements a hotel reservation service, build with Go and gRPC, and starting from the open-source project https://github.com/harlow/go-micro-services. The initial project is extended in several ways, including adding back-end in-memory and persistent databases, adding a recommender system for obtaining hotel recommendations, and adding the functionality to place a hotel reservation. 

<!-- ## Application Structure -->

<!-- ![Social Network Architecture](socialNet_arch.png) -->

Supported actions: 
* Get profile and rates of nearby hotels available during given time periods
* Recommend hotels based on user provided metrics
* Place reservations

## Pre-requirements
- Docker
- Docker-compose
- luarocks (apt-get install luarocks)
- luasocket (luarocks install luasocket)

## Running the social network application
### Before you start
- Install Docker and Docker Compose.
- In case you need to deploy multiple instances of the services(the default docker-compose file launches 1 instance for each service). Please copy docker-compose_multi-instances.yml and modify it according to your environment.
```bash
cp docker-compose_multi-instances.yml docker-compose.yml
vim docker-compose.yml
```  
- Make sure exposed ports in docker-compose files are available
- Make sure the cpuset in docker-compose files are available

### Start docker containers (no TLS)
Start docker containers by running `docker-compose up -d`. All images will be pulled from Docker Hub.

### Start docker containers with TLS gRPC
Running with default cipher suite: `TLS=1 docker-compose up -d`.

Running with specified cipher suite: `TLS=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256 docker-compose up -d`.

Check if TLS is enabled or not: `docker-compose logs user | grep TLS`.

The available cipher suite can be find at the file [options.go](tls/options.go#L21).

#### workload generation
```bash
$WRK_DIR/wrk -D exp -t <num-threads> -c <num-conns> -d <duration> -L -s ./wrk2_lua_scripts/mixed-workload_type_1.lua http://x.x.x.x:5000 -R <reqs-per-sec>
```

### Deploying in Kubernetes Cluster
Refer to `k8s/README.md`.
#### using [pprof](https://github.com/google/pprof "pprof") to profile  services
```bash
# install pprof
go get -u github.com/google/pprof
# look at 30 seconds CPU profile for geo service
go tool pprof http://localhost:18083/debug/pprof/profile?seconds=30
# load bash helper functions for pprof
source pprof_support.sh
# get service executables from docker
fetch_execs
# get 10 seconds pprof CPU profile of service geo
get_pprof_cpu geo 10
```
For more pprof usage examples, please check https://golang.org/pkg/net/http/pprof/ and https://github.com/google/pprof.

Please check the config.json file for pprof port number of different service.

### Questions and contact

You are welcome to submit a pull request if you find a bug or have extended the application in an interesting way. For any questions please contact us at: <microservices-bench-L@list.cornell.edu>
