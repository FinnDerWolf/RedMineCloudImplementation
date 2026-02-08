#!/bin/bash

# structure:
# terraform for application
# kubernetes cluster deployment
# terraform for monitoring on kubernetes cluster

set -euo pipefail

# helper functions
wait_for_ssh() {
  HOST="$1"
  USER="${2:-ubuntu}"

  echo "Waiting for SSH on $USER@$HOST"

  for i in {1..30}; do
    if ssh -o StrictHostKeyChecking=no \
           -o BatchMode=yes \
           -o ConnectTimeout=3 \
           "$USER@$HOST" "echo ok" >/dev/null 2>&1; then
      echo "SSH available on $HOST"
      return 0
    fi
    sleep 5
  done

  echo "SSH not reachable on $HOST"
  exit 1
}

wait_for_namespace() {
  HOST="$1"
  NAMESPACE="$2"
  USER="${3:-ubuntu}"

  echo "Waiting for namespace '$NAMESPACE'"

  for i in {1..30}; do
    if ssh -o StrictHostKeyChecking=no "$USER@$HOST" \
      "sudo k3s kubectl get ns $NAMESPACE" >/dev/null 2>&1; then
      echo "Namespace '$NAMESPACE' found"
      return 0
    fi
    sleep 5
  done

  echo "Namespace '$NAMESPACE' not found"
  exit 1
}

# terraform for application infrastructure
cd terraform
terraform init
terraform apply -auto-approve

CONTROL_PLANE_FLOATING_IP=$(terraform output -raw control_plane_floating_ip)
CONTROL_PLANE_PRIVATE_IP=$(terraform output -raw control_plane_private_ip)
WORKER_PRIVATE_IPS=$(terraform output -json worker_private_ips | grep -oE '"[^"]+"' | tr -d '"' )

echo "Control Plane Floating IP: $CONTROL_PLANE_FLOATING_IP"
echo "Control Plane Private IP:  $CONTROL_PLANE_PRIVATE_IP"
for ip in $WORKER_PRIVATE_IPS; do
  echo "Worker IP: $ip"
done

cd ..

# kubernetes cluster deployment
# make scripts executable
chmod +x k8s2/cluster/install-k3s-server.sh
chmod +x k8s2/cluster/join-workers.sh

# wait for control plane node
wait_for_ssh "$CONTROL_PLANE_FLOATING_IP"

# install k3s server on control plane node
ssh -o StrictHostKeyChecking=no ubuntu@"$CONTROL_PLANE_FLOATING_IP" \
  "sudo bash -s" < k8s2/cluster/install-k3s-server.sh "$CONTROL_PLANE_FLOATING_IP"

# wait again in case of reboot
wait_for_ssh "$CONTROL_PLANE_FLOATING_IP"

# traefik hostPort config
scp -o StrictHostKeyChecking=no \
  k8s2/cluster/traefik-hostport.yaml \
  ubuntu@"$CONTROL_PLANE_FLOATING_IP":/tmp/traefik-config.yaml

ssh -o StrictHostKeyChecking=no ubuntu@"$CONTROL_PLANE_FLOATING_IP" \
  "sudo mv /tmp/traefik-config.yaml /var/lib/rancher/k3s/server/manifests/traefik-config.yaml"

# GitHub Token lokal abfragen (wird NICHT in YAML/Git gespeichert)
echo
read -s -p "GitHub Token (for DB backup/restore): " GITHUB_TOKEN
echo
if [ -z "${GITHUB_TOKEN}" ]; then
  echo "WARN: Kein Token eingegeben."
  echo "GitHub Backup/Restore wird nicht funktionieren."
  echo "Restore wird aber nicht blockieren, weil initContainer 'skippt' wenn kein Backup existiert."
fi

# deploy from git repository on control plane
ssh -o StrictHostKeyChecking=no ubuntu@"$CONTROL_PLANE_FLOATING_IP" \
  "bash -s" -- "$GITHUB_TOKEN" <<'EOF'
set -euo pipefail

GH_TOKEN="${1:-}"

if [ ! -d "$HOME/Redmine" ]; then
  git clone https://github.com/FinnDerWolf/RedMineCloudImplementation.git "$HOME/Redmine"
fi

cd "$HOME/Redmine"

git fetch
git pull
git switch main

ls -l

chmod +x k8s2/scripts/deploy-from-git.sh

# Secret anlegen/ersetzen, BEVOR Workloads (Postgres/CronJob) deployed werden.
# initContainer im Postgres-Pod braucht github-token, um Backup zu laden
# CronJob braucht github-token, um Backup hochzuladen
# Ohne Secret kann es zu Init-Errors oder Job-Fails kommen

if [ -n "$GH_TOKEN" ]; then
  echo "Creating/updating github-token secret in namespace redmine..."
  sudo k3s kubectl create namespace redmine >/dev/null 2>&1 || true

  sudo k3s kubectl -n redmine delete secret github-token --ignore-not-found >/dev/null 2>&1 || true
  sudo k3s kubectl -n redmine create secret generic github-token \
    --from-literal=token="$GH_TOKEN"
else
  echo "No GH token provided -> github-token secret NOT created (backup/restore disabled)."
fi

export OVERLAY=production
./k8s2/scripts/deploy-from-git.sh
EOF

# join workers
WORKER_SSH_TARGETS=""
for ip in $WORKER_PRIVATE_IPS; do
  WORKER_SSH_TARGETS="$WORKER_SSH_TARGETS ubuntu@$ip"
done

./k8s2/cluster/join-workers.sh \
  --server "ubuntu@$CONTROL_PLANE_FLOATING_IP" \
  --workers "$WORKER_SSH_TARGETS"

# wait for kubernetes state and restart deployment
wait_for_namespace "$CONTROL_PLANE_FLOATING_IP" "redmine"

ssh -o StrictHostKeyChecking=no ubuntu@"$CONTROL_PLANE_FLOATING_IP" \
  "sudo k3s kubectl -n redmine rollout restart deployment redmine"

echo "Redmine Deployment finished"


# terraform für Monitoring Infrastruktur
chmod +x k8s2/scripts/deployMonitoring.sh
./k8s2/scripts/deployMonitoring.sh "$CONTROL_PLANE_FLOATING_IP"


echo "Deployment finished"
echo "Redmine address: http://$CONTROL_PLANE_FLOATING_IP"
