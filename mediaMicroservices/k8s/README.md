# Media Microservices on Kubernetes

## Pre-requirements

- A running Kubernetes cluster is needed.
- Pre-requirements mentioned [here](https://github.com/delimitrou/DeathStarBench/blob/master/mediaMicroservices/README.md) should be met.
- A running istio is required if you want to inject istio sidecar to service.

## Running the media service application

### Deploy services

run `<path-of-repo>/mediaMicroservices/k8s/scripts/deploy-all-services-and-configurations.sh`
and wait `kubectl -n media-microsvc get pod` to show all pods with status `Running`.

### Register users and movie information

- If you are using an "off-cluster" client then run
 `<path-of-repo>/mediaMicroservices/k8s/scripts/init_user_data.sh` to set proper
 web server `nginx-web-server` IP address. 

- If you are using an "on-cluster" client, set the web server IP address by running
 `<path-of-repo>/mediaMicroservices/k8s/scripts/init_user_data.sh on_cluster`.

- If you are running "on-cluster" copy necessary files to mms-client, and then log into mms-client to continue:
  - `mmsclient=$(kubectl get pod | grep mms-client- | cut -f 1 -d " ")`
  - `kubectl cp <path-of-repo> media-microsvc/"${mmsclient}":<path-of-repo>`
    - e.g., `kubectl cp /root/DeathStarBench media-microsvc/"${mmsclient}":/root`
  - `kubectl -n media-microsvcrsh exec -it deployment/mms-client bash`

- For both on and off cluster clients, initialize the databases:
  - `python3 <path-of-repo>/mediaMicroservices/scripts/write_movie_info.py && <path-of-repo>/mediaMicroservices/scripts/register_users.sh`
    - e.g., `python3 /root/DeathStarBench/mediaMicroservices/scripts/write_movie_info.py && /root/DeathStarBench/mediaMicroservices/scripts/register_users.sh`

### Running HTTP workload generator

#### Compose reviews

Take an example, running in on-cluster client:

```bash
cd <path-of-repo>/mediaMicroservices/wrk2
make clean
make
./wrk -D exp -t <num-threads> -c <num-conns> -d <duration> -L -s ./scripts/media-microservices/compose-review.lua http://<webserver-address>:8080/wrk2-api/review/compose -R <reqs-per-sec>
#   e.g., ./wrk -D exp -t 2 -c 2 -d 30 -L -s ./scripts/media-microservices/compose-review.lua http://nginx-web-server.media-microsvc.svc.cluster.local:8080/wrk2-api/review/compose -R 2
```

### View Jaeger traces

Use `kubectl -n media-microsvc get ep | grep jaeger-out` to get the location of jaeger service.

View Jaeger traces by accessing `http://<jaeger-ip-address>:<jaeger-port>` 


### Tips

If you are running on-cluster, you can use the following command to copy files off of the client.
e.g., to copy the results directory from the on-cluster client to the local machine:
  - `mmsclient=$(kubectl get pod | grep mms-client- | cut -f 1 -d " ")`
  - `kubectl cp media-microsvc/${mmsclient}:/root/DeathStarBench/mediaMicroservices/k8s/results /tmp`

## Inject istio sidecar for services

Once the media microservices are available to be run on kubernetes cluster, just follow the
[standard istio document](https://istio.io/latest/docs/setup/additional-setup/sidecar-injection/)
to inject a sidecar in them.
