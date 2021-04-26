# Media Microservices on Kubernetes

## Pre-requirements

- A running Kubernetes cluster is needed.
- Pre-requirements mentioned [here](https://github.com/intel-sandbox/DeathStarBenchPlusPlus/blob/master/mediaMicroservices/README.md) should be met.
- A running istio is required if you want to inject istio sidecar to service.

## Running Predefined Performance Tuning Scenarios

**NOTE: This is the recommended and easier way to deploy and run the system.**

To deploy a fresh uService system:

``` bash
cd k8s/perf-tuning/
./deploy.sh <scenario>
```

To measure performance:

``` bash
./measure.sh <scenario>
```

Refer to [k8s/perf-tuning/README.md](https://github.com/intel-sandbox/DeathStarBenchPlusPlus/blob/master/mediaMicroservices/k8s/perf-tuning/README.md)

## Running Manually

**NOTE: This part is for you who want to customize the deployment and the testing part.** 

### Before you start



- Ensure that the necessary local images have been made. Otherwise, run following commands to create images:

```bash
cd mediaMicroservices
docker build -t mediamicroservices:latest -f ./Dockerfile .
docker build -t openresty-through:xenial -f ./docker/openresty-thrift/xenial/Dockerfile ./docker/openresty-thrift
```

### Deploy services

run `<path-of-repo>/mediaMicroservices/k8s/scripts/deploy-all-services-and-configurations.sh`
and wait `kubectl -n media-microsvc get pod` to show all pods with status `Running`.

### Register users and movie information

Run following comamnds on the host:

```bash
cd k8s/scripts 
./init-user-data.sh
python3 ../../scripts/write_movie_info.py
../../scripts/register_movies.sh
../../scripts/register_users.sh
```

### Running HTTP workload generator


We use the pod 'media-microsvc\wrk-client' as the on-cluster workload generator.

To generate workload request, perform:

``` bash
kubectl -n media-microsvc exec -it pod/wrk-client -- wrk -D exp -t <num-threads> -c <num-conns> -d <duration> -L -s <lua script> http://nginx-web-server.media-microsvc.svc.cluster.local:8080 -R <reqs-per-sec>
```

### View Jaeger traces

Use `kubectl -n media-microsvc get ep | grep jaeger-out` to get the location of jaeger service.

View Jaeger traces by accessing `http://<jaeger-ip-address>:<jaeger-port>` 

### Inject istio sidecar for services

Once the media microservices are available to be run on kubernetes cluster, just follow the
[standard istio document](https://istio.io/latest/docs/setup/additional-setup/sidecar-injection/)
to inject a sidecar in them.
