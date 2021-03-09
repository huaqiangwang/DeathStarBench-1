# Hotel Reservations on Kubernetes

## Pre-requirements

- A running Kubernetes cluster is needed.
- Pre-requirements mentioned [here](https://github.com/delimitrou/DeathStarBench/blob/master/hotelReservation/README.md) should be met.

## Running the Hotel Reservation application

### Before you start

- Ensure that the necessary local images have been made.
  - `<path-of-repo>/hotelReservation/k8s/scripts/build-docker-img.sh`
- If necessary, update the addresses in `<path-of-repo>/hotelReservation/k8s/configmaps/config.json`
  - Currently the addresses are in a fairly generic form supported by on-cluster DNS. As long as
    access is from within the cluster and the name of the namespace has not been changed, it should be OK.

### Deploy services

run `<path-of-repo>/hotelReservation/k8s/scripts/deploy.sh`
and wait for `kubectl -n hotel-res get pod` to show all pods with status `Running`.

### Create istio sidecars

To inject istio sidecar to each service, perform following steps before the #deploy-services step:
```bash
kubectl create namespace hotel-res
kubectl label namespace hotel-res istio-injection=enabled
```

### Prepare HTTP workload generator

- Review the URL's embedded in `wrk2_lua_scripts/mixed-workload_type_1.lua` to be sure they are correct for your environment.
  The current value of `http://frontend.hotel-res.svc.cluster.local:5000` is valid for a typical "on-cluster" configuration.
- To use an "on-cluster" client, copy the necessary files to `hr-client`, and then log into `hr-client` to continue:
  - `hrclient=$(kubectl get pod | grep hr-client- | cut -f 1 -d " ")`
  - `kubectl cp <path-of-repo> hotel-res/"${hrclient}":<path-of-repo>`
    - e.g., `kubectl cp /root/DeathStarBench hotel-res/"${hrclient}":/root`

### Running HTTP workload generator

##### Template
```bash
cd <path-of-repo>/hotelReservation
./wrk -D exp -t <num-threads> -c <num-conns> -d <duration> -L -s ./wrk2_lua_scripts/mixed-workload_type_1.lua http://frontend.hotel-res.svc.cluster.local:5000 -R <reqs-per-sec>
```

##### Example
```bash
cd /root/DeathStarBench/hotelReservation
./wrk -D exp -t 2 -c 2 -d 30 -L -s ./wrk2_lua_scripts/mixed-workload_type_1.lua http://frontend.hotel-res.svc.cluster.local:5000 -R 2 
```


### View Jaeger traces

Use `kubectl -n hotel-res get ep | grep jaeger-out` to get the location of jaeger service.

View Jaeger traces by accessing:
- `http://<jaeger-ip-address>:<jaeger-port>`  (off cluster)
- `http://jaeger.hotel-res.svc.cluster.local:6831`  (on cluster)


### Tips

- If you are running on-cluster, you can use the following command to copy files off of the client.
e.g., to copy the results directory from the on-cluster client to the local machine:
  - `hrclient=$(kubectl get pod | grep hr-client- | cut -f 1 -d " ")`
  - `kubectl cp hotel-res/${hrclient}:/root/DeathStarBench/hotelReservation/k8s/results /tmp`
