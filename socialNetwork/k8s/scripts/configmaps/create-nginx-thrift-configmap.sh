#!/bin/bash

NS="social-network"

# file
cd $(dirname $0)/../..
kubectl create cm nginx-thrift        --from-file=nginx-web-server/conf/nginx.conf -n ${NS}

# directories
kubectl create cm nginx-thrift-luascripts --from-file=nginx-web-server/lua-scripts -n ${NS}
kubectl create cm nginx-thrift-luascripts-api-home-timeline --from-file=nginx-web-server/lua-scripts/api/home-timeline -n ${NS}
kubectl create cm nginx-thrift-luascripts-api-post --from-file=nginx-web-server/lua-scripts/api/post -n ${NS}
kubectl create cm nginx-thrift-luascripts-api-user --from-file=nginx-web-server/lua-scripts/api/user -n ${NS}
kubectl create cm nginx-thrift-luascripts-api-user-timeline --from-file=nginx-web-server/lua-scripts/api/user-timeline -n ${NS}
kubectl create cm nginx-thrift-luascripts-wrk2-api-home-timeline --from-file=nginx-web-server/lua-scripts/wrk2-api/home-timeline -n ${NS}
kubectl create cm nginx-thrift-luascripts-wrk2-api-post --from-file=nginx-web-server/lua-scripts/wrk2-api/post -n ${NS}
kubectl create cm nginx-thrift-luascripts-wrk2-api-user --from-file=nginx-web-server/lua-scripts/wrk2-api/user -n ${NS}
kubectl create cm nginx-thrift-luascripts-wrk2-api-user-timeline --from-file=nginx-web-server/lua-scripts/wrk2-api/user-timeline -n ${NS}

cd ../
kubectl create cm nginx-thrift-genlua --from-file=gen-lua -n ${NS}
kubectl create cm nginx-thrift-pages  --from-file=nginx-web-server/pages -n ${NS}
kubectl create cm nginx-thrift-pages-javascript  --from-file=nginx-web-server/pages/javascript -n ${NS}
kubectl create cm nginx-thrift-pages-style  --from-file=nginx-web-server/pages/style -n ${NS}
kubectl create cm ssl-keys        --from-file=keys -n ${NS}
