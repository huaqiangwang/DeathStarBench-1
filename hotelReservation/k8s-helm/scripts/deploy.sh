#!/bin/bash
cd ../../
helm install hotel-res k8s-helm --create-namespace -n hotel-res
