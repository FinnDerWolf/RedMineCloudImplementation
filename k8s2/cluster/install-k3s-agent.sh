#!/usr/bin/env bash
set -euo pipefail


#   ./install-k3s-agent.sh <SERVER_PRIVATE_IP> <TOKEN>
#
#   ./install-k3s-agent.sh 10.0.0.10 K10abcd...::server:...

SERVER_IP="${1:-}"
TOKEN="${2:-}"

if [[ -z "$SERVER_IP" || -z "$TOKEN" ]]; then
  echo "Nutzung: $0 <SERVER_PRIVATE_IP> <TOKEN>"
  exit 1
fi

NODE_IP="$(ip -4 route get 1.1.1.1 | awk '{for(i=1;i<=NF;i++) if ($i=="src") print $(i+1)}' | head -n1)"
if [[ -z "$NODE_IP" ]]; then
  echo "Keine NODE_IP"
  exit 1
fi

curl -sfL https://get.k3s.io | sudo env \
  K3S_URL="https://${SERVER_IP}:6443" \
  K3S_TOKEN="${TOKEN}" \
  K3S_NODE_IP="${NODE_IP}" \
  sh -

echo "k3s worker joined: ${SERVER_IP}"
