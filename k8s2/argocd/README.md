# Argo CD

## Apply
From your control-plane node (or anywhere with kubectl access to the cluster):

```bash
bash k8s2/argocd/scripts/install-argocd.sh
```

## Get initial admin password
```bash
kubectl -n argocd get secret argocd-initial-admin-secret \
  -o jsonpath="{.data.password}" | base64 -d; echo
```

## Access
Port-forward:

```bash
kubectl -n argocd port-forward svc/argocd-server 8080:443
```

Then open: https://ip:8080

Login: `admin`
Password: from the command above.
