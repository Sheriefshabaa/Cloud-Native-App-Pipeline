#!/bin/bash

# Apply MongoDB manifests
kubectl apply -f mongo-pvc.yaml
kubectl apply -f mongo-deployment.yaml
kubectl apply -f mongo-svc.yaml


# Apply Backend manifests
kubectl apply -f backend-deployment.yaml
kubectl apply -f backend-svc.yaml

# Apply Frontend manifests
kubectl apply -f frontend-deployment.yaml
kubectl apply -f frontend-svc.yaml