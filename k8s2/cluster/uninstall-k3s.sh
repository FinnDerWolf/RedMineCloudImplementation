#!/usr/bin/env bash
set -euo pipefail

# auf dem server:
#   sudo /usr/local/bin/k3s-uninstall.sh
# auf dem worker:
#   sudo /usr/local/bin/k3s-agent-uninstall.sh

if [[ -f /usr/local/bin/k3s-uninstall.sh ]]; then
  sudo /usr/local/bin/k3s-uninstall.sh
  echo "k3s server geloescht"
elif [[ -f /usr/local/bin/k3s-agent-uninstall.sh ]]; then
  sudo /usr/local/bin/k3s-agent-uninstall.sh
  echo "k3s worker geloescht"
else
  echo "Kein k3s uninstall-script gefunden"
  exit 1
fi
