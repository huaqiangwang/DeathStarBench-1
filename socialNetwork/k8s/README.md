# Social Network Microservices on Kubernetes

## Pre-requirements

- A running Kubernetes cluster is needed.
- Pre-requirements mentioned [here](https://github.com/delimitrou/DeathStarBench/blob/master/socialNetwork/README.md) should be met.

## Running the social network application on Kubernetes

### Deploy services

Run the script `<path-of-repo>/socialNetwork/openshift/scripts/deploy-all-services-and-configurations.sh`

### Using `wrk-client` as an "on-cluster" client

After customization, If you are running "on-cluster" copy necessary files to `ubuntu-client`, and then log into `ubuntu-client` to continue:
  - `kubectl exec -it pod/wrk-client -- bash`

### Register users and construct social graphs

- If using an on-cluster client:
  - Use `nginx-thrift.social-network.svc.cluster.local` as cluster-ip and paste it at `<path-of-repo>/socialNetwork/scripts/init_social_graph.py:71`
- Register users and construct social graph by running `cd <path-of-repo>/socialNetwork && python3 scripts/init_social_graph.py`.
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


### Local image customization

If local image customization is needed, then the script
`<path-of-repo>/socialNetwork/openshift/scripts/build-docker-img.sh`
can be used to create them. In this case the relevant yaml files will need to
be edited to refer to the new images.
e.g., `image: image-registry.openshift-image-registry.svc:5000/social-network/social-network-microservices:openshift`
