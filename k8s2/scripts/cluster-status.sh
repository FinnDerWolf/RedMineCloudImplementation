#!/usr/bin/env bash
set -euo pipefail

kubectl get nodes -o wide
echo
kubectl get pods -A
echo
kubectl get svc -A
