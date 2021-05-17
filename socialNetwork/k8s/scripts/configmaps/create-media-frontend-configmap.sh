#!/bin/bash

cd $(dirname $0)/../..

kubectl create cm media-frontend-nginx --from-file=media-frontend/conf/nginx.conf  -n social-network
kubectl create cm media-frontend-lua   --from-file=media-frontend/lua-scripts -n social-network
