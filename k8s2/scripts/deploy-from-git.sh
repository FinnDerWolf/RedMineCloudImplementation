#!/usr/bin/env bash
set -euo pipefail

### === KONFIGURATION === ###
GIT_REPO="git@github.com:FinnDerWolf/RedMineCloudImplementation.git"

BRANCH="${BRANCH:-main}"
DEST_DIR="${DEST_DIR:-$HOME/redmine-deploy}"
OVERLAY="${OVERLAY:-production}"
### ====================== ###

echo "==> Deploye aus dem Git"
echo "Repo:    $GIT_REPO"
echo "Branch:  $BRANCH"
echo "Target:  $DEST_DIR"
echo "Overlay: $OVERLAY"

if [ ! -d "$DEST_DIR/.git" ]; then
  echo "==> Klone repository"
  git clone --branch "$BRANCH" "$GIT_REPO" "$DEST_DIR"
else
  echo "==> Update repository"
  cd "$DEST_DIR"
  git fetch --all --prune
  git reset --hard "origin/$BRANCH"
fi

cd "$DEST_DIR"

echo "==> Wende Kubernetes manifests an"
./k8s2/scripts/apply-redmine.sh "$OVERLAY"

echo "==> Cluster Status"
./k8s2/scripts/cluster-status.sh

echo "==> Deployment fertig"
