# Hotel Reservations on Kubernetes

## Pre-requirements

- A running Kubernetes cluster is needed.
- Pre-requirements mentioned [here](https://github.com/intel-sandbox/DeathStarBenchPlusPlus/blob/master/hotelReservation/README.md) should be met.

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

Refer to [k8s/perf-tuning/README.md](https://github.com/intel-sandbox/DeathStarBenchPlusPlus/blob/master/hotelReservation/k8s/perf-tuning/README.md)

## Running Manually

**NOTE: This part is for you who want to customize the deployment and the testing part.** 

### Before you start

- Ensure that the necessary local images have been made. Otherwise, run `<path-of-repo>/hotelReservation/k8s/scripts/build-docker-img.sh`

- If necessary, update the addresses in `<path-of-repo>/hotelReservation/k8s/configmaps/config.json`
  - Currently the addresses are in a fairly generic form supported by on-cluster DNS. As long as
    access is from within the cluster and the name of the namespace has not been changed, it should be OK.

### Deploy services

Run `<path-of-repo>/hotelReservation/k8s/scripts/deploy.sh`
and wait for `kubectl -n hotel-res get pod` to show all pods with status `Running`.

### Running workload generator

We use the pod 'hotel-res\wrk-client' as the on-cluster workload generator.

To generate workload HTTP requests, perform:

``` bash
kubectl -n hotel-res exec -it pod/wrk-client -- wrk -D exp -t <num-threads> -c <num-conns> -d <duration> -L -s ./wrk2_lua_scripts/mixed-workload_type_1.lua http://frontend.hotel-res.svc.cluster.local:5000 -R <reqs-per-sec>
```

### View Jaeger traces

Use `kubectl -n hotel-res get ep | grep jaeger-out` to get the location of jaeger service.

View Jaeger traces by accessing:
- `http://<jaeger-ip-address>:<jaeger-port>`  (off cluster)
- `http://jaeger.hotel-res.svc.cluster.local:6831`  (on cluster)
