#!/usr/bin/env bash
set -euo pipefail

OVERLAY="${1:-base}"

case "$OVERLAY" in
  base)
    kubectl apply -k "$(dirname "$0")/../apps/redmine/base"
    ;;
  staging|production)
    kubectl apply -k "$(dirname "$0")/../apps/redmine/overlays/${OVERLAY}"
    ;;
  *)
    echo "Nutzung: $0 [base|staging|production]"
    exit 1
    ;;
esac

kubectl -n redmine get pods -o wide
kubectl -n redmine get svc -o wide
