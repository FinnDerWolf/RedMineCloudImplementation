#!/usr/bin/env bash
set -euo pipefail

SERVER=""
WORKERS=""

# Optional: SSH Optionen
SSH_OPTS="${SSH_OPTS:-}"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --server) SERVER="$2"; shift 2 ;;
    --workers) WORKERS="$2"; shift 2 ;;
    *)
      echo "Unbekannte Argumente $1"
      echo 'Nutzung: join-workers.sh --server ubuntu@IP --workers "ubuntu@IP ubuntu@IP ..."'
      exit 1
      ;;
  esac
done

[[ -z "$SERVER" || -z "$WORKERS" ]] && {
  echo 'Nutzunge: join-workers.sh --server ubuntu@IP --workers "ubuntu@IP ubuntu@IP ..."'
  exit 1
}

echo "==> Hole k3s token vom Server ($SERVER)"
TOKEN=$(ssh ${SSH_OPTS} "$SERVER" "sudo cat /var/lib/rancher/k3s/server/node-token")

echo "==> Suche Server private IP (RFC1918) auf dem Server"
SERVER_IP=$(ssh ${SSH_OPTS} "$SERVER" \
  "ip -4 addr show | grep -E 'inet (10\.|192\.168|172\.(1[6-9]|2[0-9]|3[0-1]))' | awk '{print \$2}' | cut -d/ -f1 | head -n1")

[[ -z "$SERVER_IP" ]] && {
  echo "Fehler: Konnte keine private server IP finden auf $SERVER"
  exit 1
}

echo "==> Server private IP: $SERVER_IP"
echo "==> Joining workers via jump host: $SERVER"

for W in $WORKERS; do
  echo "==> Joining worker $W (durch jump host)"
  ssh ${SSH_OPTS} -J "$SERVER" "$W" \
    "curl -sfL https://get.k3s.io | K3S_URL=https://$SERVER_IP:6443 K3S_TOKEN=$TOKEN sh -"
done

echo "==> Alle Worker erfolgreich gejoint"