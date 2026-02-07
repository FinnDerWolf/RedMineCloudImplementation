#!/bin/bash
# floating ip from first argument
CONTROL_PLANE_FLOATING_IP="$1"

# Kubeconfig temporär vom Controlplane kopieren
scp -o StrictHostKeyChecking=no \
  ubuntu@"$CONTROL_PLANE_FLOATING_IP":/etc/rancher/k3s/k3s.yaml \
  "/tmp/k3s-$CONTROL_PLANE_FLOATING_IP.yaml"

sed "s/127.0.0.1/$CONTROL_PLANE_FLOATING_IP/g" \
  "/tmp/k3s-$CONTROL_PLANE_FLOATING_IP.yaml" \
  > "/tmp/k3s-$CONTROL_PLANE_FLOATING_IP.yaml.tmp"

mv "/tmp/k3s-$CONTROL_PLANE_FLOATING_IP.yaml.tmp" \
   "/tmp/k3s-$CONTROL_PLANE_FLOATING_IP.yaml"

export KUBECONFIG="/tmp/k3s-$CONTROL_PLANE_FLOATING_IP.yaml"

cd terraform/modules/monitoring
terraform init -upgrade
terraform apply -auto-approve \
  -var="kubeconfig_path=/tmp/k3s-$CONTROL_PLANE_FLOATING_IP.yaml"

kubectl apply -f k8s2/monitoring/grafana-ingress.yaml

kubectl get nodes
kubectl -n monitoring get ingress

# temporäre kubeconfig wieder löschen
rm -f "/tmp/k3s-$CONTROL_PLANE_FLOATING_IP.yaml"
