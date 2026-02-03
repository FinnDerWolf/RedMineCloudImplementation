#!/usr/bin/env bash
set -euo pipefail

#   ./install-k3s-server.sh <FLOATING_IP> 
#
#   ./install-k3s-server.sh 203.0.113.10

FLOATING_IP="${1:-}"
DISABLE_TRAEFIK="${2:-}"

if [[ -z "$FLOATING_IP" ]]; then
  echo "Nutzung: $0 <FLOATING_IP> [--disable-traefik]"
  exit 1
fi

NODE_IP="$(ip -4 route get 1.1.1.1 | awk '{for(i=1;i<=NF;i++) if ($i=="src") print $(i+1)}' | head -n1)"
if [[ -z "$NODE_IP" ]]; then
  echo "Keine NODE_IP"
  exit 1
fi

INSTALL_ARGS=(server "--node-ip=${NODE_IP}" "--tls-san=${FLOATING_IP}")

if [[ "${DISABLE_TRAEFIK}" == "--disable-traefik" ]]; then
  INSTALL_ARGS+=("--disable" "traefik")
fi

curl -sfL https://get.k3s.io | sudo sh -s - "${INSTALL_ARGS[@]}"

echo
echo "k3s server installiert"
echo "Node token:"
sudo cat /var/lib/rancher/k3s/server/node-token

echo
echo "Cluster status:"
sudo k3s kubectl get nodes -o wide
