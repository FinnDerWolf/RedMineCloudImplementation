#!/usr/bin/env bash
set -euo pipefail

echo "Create argocd namespace if missing"
kubectl get ns argocd >/dev/null 2>&1 || kubectl create namespace argocd

echo "Install Argo CD (official stable manifest)"
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

echo "Wait for argocd-server to be ready"
kubectl -n argocd rollout status deploy/argocd-server --timeout=300s || true

echo "Apply project + applications + ingress"
kubectl apply -f k8s2/argocd/projects/default-project.yaml
kubectl apply -f k8s2/argocd/apps/redmine-staging.yaml
kubectl apply -f k8s2/argocd/apps/redmine-production.yaml
kubectl apply -f k8s2/argocd/ingress/argocd-ingress.yaml || true

echo
echo "Done."
echo "Initial admin password:"
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d; echo"