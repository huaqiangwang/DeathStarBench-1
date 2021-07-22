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

## Running on kubernetes cluster

Refer to `k8s/README.md`.

## Running on kubeernetes cluster with Helm

It is available to deploy services on k8s with help of helm, you need to deploy services in this way when you want to create multiple frontend services and each frontend service is receiving http requests from a dedicated wrk-client.

To deploy:

```bash
cd hotelReservation/ks8-helm/scripts
./deploy.sh
```

To issue hotel reservation http requests for benchmarking:

```bash
cd hotelReservation/ks8-helm/scripts
./measure.sh
```

## Running the social network application with docker-compose
### Before you start
- Install Docker and Docker Compose.
- In case you need to deploy multiple instances of the services(the default docker-compose file launches 1 instance for each service). Please copy docker-compose_multi-instances.yml and modify it according to your environment.
```bash
cp docker-compose_multi-instances.yml docker-compose.yml
vim docker-compose.yml
```  
- Make sure exposed ports in docker-compose files are available
- Make sure the cpuset in docker-compose files are available

### Running the containers
##### Docker-compose
- NOTLS: Start docker containers by running `docker-compose up -d`. All images will be pulled from Docker Hub.
- TLS: Start docker containers by running `TLS=1 docker-compose up -d`. All the gRPC communications will be protected by TLS.
- TLS with spcified ciphersuite: Start docker containers by running `TLS=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256 docker-compose up -d`. The available cipher suite can be find at the file [options.go](tls/options.go#L21).

Check if TLS is enabled or not: `docker-compose logs <service> | grep TLS`.


#### workload generation
```bash
$WRK_DIR/wrk -D exp -t <num-threads> -c <num-conns> -d <duration> -L -s ./wrk2_lua_scripts/mixed-workload_type_1.lua http://x.x.x.x:5000 -R <reqs-per-sec>
```

### Deploying in Kubernetes Cluster
Refer to `k8s/README.md`.

### Questions and contact

You are welcome to submit a pull request if you find a bug or have extended the application in an interesting way. For any questions please contact us at: <microservices-bench-L@list.cornell.edu>
