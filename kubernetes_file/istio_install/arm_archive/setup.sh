#!/bin/bash

# create k8s cluster by kind
kind create cluster --config=kind.yaml

#kubectl top
# wget https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml -O metrics-server-components.yaml

# kubectl apply -f metrics-server-components.yaml

# arm for istio
istioctl operator init --hub=docker.io/querycapistio --tag=1.13.3

# istio
istioctl install -f ./istio.yaml -y

# kubectl label namespace default istio-injection=enabled --overwrite

# kubectl label namespace default istio-injection-

# sudo kubectl port-forward -n istio-system service/istio-ingressgateway 80

# cert-manager
# kubectl apply -f https://github.com/jetstack/cert-manager/releases/latest/download/cert-manager.yaml
