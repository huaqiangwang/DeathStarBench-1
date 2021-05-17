# Social Network Microservices on Kubernetes

## Pre-requirements

- A running Kubernetes cluster is needed.
- Pre-requirements mentioned [here](https://github.com/intel-sandbox/DeathStarBenchPlusPlus/blob/master/socialNetwork/README.md) should be met.

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

### Deploy services

Run the script `<path-of-repo>/socialNetwork/k8s/scripts/deploy-all-services-and-configurations.sh`


### Register users and construct social graphs

- Register users and construct social graph by running `cd <path-of-repo>/socialNetwork && k8s/scripts/fill-user-data.sh`.
  This will initialize a social graph based on [Reed98 Facebook Networks](http://networkrepository.com/socfb-Reed98.php), with 962 users and 18.8K social graph edges. 

### Running HTTP workload generator

There are three type of applications in the workload: compose post, write home timeline, and read home timeline.
The applications run independently and each one has a different workflow, using different micro-services.

`wrk` command is offered in `wrk-client` client, you can send requests to social network system with following commands:

```bash
`kubectl -n social-network exec -it pod/wrk-client -- /socialNetwork/wrk2/wrk <wrk Parameters>`
```

For all load generating commands below, it should be possible to use `nginx-thrift.social-network.svc.cluster.local:8080` for `cluster-ip`.

#### Compose posts

```bash
kubectl -n social-network exec -it pod/wrk-client -- bash
cd <path-of-repo>/socialNetwork/wrk2
./wrk -D exp -t <num-threads> -c <num-conns> -d <duration> -L -s ./scripts/social-network/compose-post.lua http://<cluster-ip>/wrk2-api/post/compose -R <reqs-per-sec>
```

#### Read home timelines

```bash
kubectl -n social-network exec -it pod/wrk-client -- bash
cd <path-of-repo>/socialNetwork/wrk2
./wrk -D exp -t <num-threads> -c <num-conns> -d <duration> -L -s ./scripts/social-network/read-home-timeline.lua http://<cluster-ip>/wrk2-api/home-timeline/read -R <reqs-per-sec>
```

#### Read user timelines

```bash
kubectl -n social-network exec -it pod/wrk-client -- bash
cd <path-of-repo>/socialNetwork/wrk2
./wrk -D exp -t <num-threads> -c <num-conns> -d <duration> -L -s ./scripts/social-network/read-user-timeline.lua http://<cluster-ip>/wrk2-api/user-timeline/read -R <reqs-per-sec>
```

#### View Jaeger traces

Use `kubectl -n social-network get svc jaeger-out` to get the NodePort of jaeger service.

 View Jaeger traces by accessing `http://<node-ip>:<NodePort>` 

### Insert `Istio` side car

Follow these instructions to run socialNetwork with `istio` side cars:

1. Install istio if you don't have it.
   Follow the [guide](https://istio.io/latest/docs/setup/getting-started/) from official page.

1. Create `social-network` namespace:

    ```shell
    kubectl create namespace social-network
    ```

1. Deploy socialNetwork system

    ```shell
    ./<path-of-repo>/socialNetwork/k8s/scripts/deploy-all-services-and-configurations.sh
    ```

1. Check the pods status

    ``` shell
    kubectl -n social-network get pods
    NAME                                            READY   STATUS    RESTARTS   AGE
    compose-post-redis-7fb7ff8f47-kwkbf             2/2     Running   0          82m
    compose-post-service-75bd998b6d-ttdcd           2/2     Running   0          82m
    home-timeline-redis-5947c8ffc5-7j7sc            2/2     Running   0          82m
    home-timeline-service-5896fcc5fd-vj4x2          2/2     Running   0          82m
    jaeger-79df655c6-gvrmj                          2/2     Running   0          82m
    media-frontend-5956fcd84-n7dp7                  2/2     Running   0          82m
    media-memcached-768c9985c8-wgfmz                2/2     Running   0          82m
    media-mongodb-c8bdc64b-rmlc9                    2/2     Running   0          82m
    media-service-6d959b697-988dg                   2/2     Running   0          82m
    nginx-thrift-56bc5599d4-jlfnv                   2/2     Running   0          82m
    post-storage-memcached-79cd5b8b78-tf4hv         2/2     Running   0          82m
    post-storage-mongodb-6d866887b8-fgws8           2/2     Running   0          82m
    post-storage-service-7fb997c4fc-t6678           2/2     Running   0          82m
    social-graph-mongodb-8687d4789b-fxn8s           2/2     Running   0          82m
    social-graph-redis-677cc876d6-xwbrf             2/2     Running   0          82m
    social-graph-service-7b7f79bfd6-wl7fz           2/2     Running   1          82m
    text-service-7c468fc545-vh4kj                   2/2     Running   0          82m
    ubuntu-client-6865d964c8-2t6wc                  2/2     Running   1          82m
    unique-id-service-6c99d65994-xpwm2              2/2     Running   0          82m
    url-shorten-memcached-5475f97899-9flzc          2/2     Running   0          82m
    url-shorten-mongodb-ff59d867f-kntjf             2/2     Running   0          82m
    url-shorten-service-8d7cddb88-q4q5s             2/2     Running   0          82m
    user-memcached-6679b757d9-65ps9                 2/2     Running   0          82m
    user-mention-service-57bb6d76b6-4ttqm           2/2     Running   0          82m
    user-mongodb-7d6fd48455-pjwkt                   2/2     Running   0          82m
    user-service-798b687c4f-hhgtj                   2/2     Running   0          82m
    user-timeline-mongodb-7f7854fdf9-9tn9r          2/2     Running   0          82m
    user-timeline-redis-7dbf4f75f9-b5x8g            2/2     Running   0          82m
    user-timeline-service-5f447bff8-6kcqr           2/2     Running   0          82m
    write-home-timeline-rabbitmq-5669b9dd49-qjj6n   2/2     Running   0          82m
    write-home-timeline-service-747b4f87c7-d87ff    2/2     Running   1          82m
    wrk-client                                      2/2     Running   1          82m
    ```

1. Initialize socialNetwork system by following the [data register section](#register-users-and-construct-social-graphs)

1. Send `mixed` requests to frontend.

    ```shell
    kubectl -n social-network exec -it exec pod/wrk-client bash

    #NOTE: switched to the wrk-client bash environment ...

    wrk-client # wrk2/wrk -t 10 -c 30 -d 30 -R 5000 -s wrk2/scripts/social-network/mixed-workload.lua http://nginx-thrift:8080
    ```

    The final output from `wrk-client` container should like these:

    ``` terminal
    Running 30s test @ http://nginx-thrift:8080
      10 threads and 30 connections
      Thread calibration: mean lat.: 0.399ms, rate sampling interval: 10ms
      Thread calibration: mean lat.: 0.407ms, rate sampling interval: 10ms
      Thread calibration: mean lat.: 0.413ms, rate sampling interval: 10ms
      Thread calibration: mean lat.: 0.448ms, rate sampling interval: 10ms
      Thread calibration: mean lat.: 0.430ms, rate sampling interval: 10ms
      Thread calibration: mean lat.: 0.416ms, rate sampling interval: 10ms
      Thread calibration: mean lat.: 0.405ms, rate sampling interval: 10ms
      Thread calibration: mean lat.: 0.400ms, rate sampling interval: 10ms
      Thread calibration: mean lat.: 0.397ms, rate sampling interval: 10ms
      Thread calibration: mean lat.: 0.373ms, rate sampling interval: 10ms
      Thread Stats   Avg      Stdev     99%   +/- Stdev
        Latency   420.04us  320.79us   1.46ms   83.90%
        Req/Sec   526.73     86.92   666.00     74.13%
      149972 requests in 30.00s, 14.14MB read
      Non-2xx or 3xx responses: 149972
    Requests/sec:   4999.05
    Transfer/sec:    482.81KB
    ```
