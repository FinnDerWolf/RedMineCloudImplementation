#!/usr/bin/env bash
set -euo pipefail

kubectl delete namespace redmine --ignore-not-found=true
echo "Namespace redmine geloescht (mit allen resourcen)."
