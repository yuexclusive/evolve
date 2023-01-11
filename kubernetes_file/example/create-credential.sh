#! /bin/bash
kubectl create -n istio-system secret tls test-credential-2 --key=/Users/yu/docker_volumes/tls/example/*.example.com_key.key --cert=/Users/yu/docker_volumes/tls/example/*.example.com.crt