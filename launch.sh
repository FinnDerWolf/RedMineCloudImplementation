#!/bin/bash

# structure:
# terraform for application
# kubernetes cluster deployment
# terraform for monitoring on kubernetes cluster

set -euo pipefail

# terraform for application infrastructure
cd "terraform"
terraform init
terraform apply -auto-approve

# get output variables from terraform
CONTROL_PLANE_FLOATING_IP=$(terraform output -raw control_plane_floating_ip)
CONTROL_PLANE_PRIVATE_IP=$(terraform output -raw control_plane_private_ip)
WORKER_PRIVATE_IPS=$(terraform output -json worker_private_ips | grep -oE '"[^"]+"' | tr -d '"' )

echo "Control Plane Floating IP: $CONTROL_PLANE_FLOATING_IP"
echo "Control Plane Private IP:  $CONTROL_PLANE_PRIVATE_IP"

for ip in $WORKER_PRIVATE_IPS; do
  echo "Worker: $ip"
done

cd ..

# kubernetes cluster deployment
# make scripts executable
chmod +x k8s2/cluster/install-k3s-server.sh
chmod +x k8s2/cluster/join-workers.sh

# install k3s server on control plane node
ssh ubuntu@$CONTROL_PLANE_FLOATING_IP "sudo bash -s" < k8s2/cluster/install-k3s-server.sh $CONTROL_PLANE_FLOATING_IP

#Traefik hostPort Config aus Repo auf Control-Plane kopieren
scp k8s2/cluster/traefik-hostport.yaml ubuntu@$CONTROL_PLANE_FLOATING_IP:/tmp/traefik-config.yaml
ssh ubuntu@$CONTROL_PLANE_FLOATING_IP "sudo mv /tmp/traefik-config.yaml /var/lib/rancher/k3s/server/manifests/traefik-config.yaml"

# Deploye aus dem Git Repository auf Control Plane Noden und wende Kubernetes Manifeste an
ssh ubuntu@$CONTROL_PLANE_FLOATING_IP <<'EOF'
set -e

# Repo klonen (nur falls noch nicht vorhanden)
if [ ! -d "$HOME/Redmine" ]; then
  git clone https://github.com/FinnDerWolf/RedMineCloudImplementation.git "$HOME/Redmine"
fi

cd "$HOME/Redmine"

# Richtigen Branch auschecken
git fetch
git switch monitoringTest
ls -l

# Deploy-Script ausführbar machen
chmod +x k8s2/scripts/deploy-from-git.sh

# Deployment starten
export OVERLAY=production
./k8s2/scripts/deploy-from-git.sh
EOF

# Worker joinen und in k3s Cluster integrieren
WORKER_SSH_TARGETS=""
for ip in $WORKER_PRIVATE_IPS; do
  WORKER_SSH_TARGETS="$WORKER_SSH_TARGETS ubuntu@$ip"
done

./k8s2/cluster/join-workers.sh \
  --server "ubuntu@$CONTROL_PLANE_FLOATING_IP" \
  --workers "$WORKER_SSH_TARGETS"

# Deployment neustarten, um Pods auf worker zu verteilen
ssh ubuntu@$CONTROL_PLANE_FLOATING_IP "sudo k3s kubectl -n redmine rollout restart deployment redmine"

echo "Redmine Adresse: https://$CONTROL_PLANE_FLOATING_IP"




