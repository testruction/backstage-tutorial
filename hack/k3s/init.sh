#!/usr/bin/env bash
set -euo pipefail

hack/k3s/argocd.sh
hack/k3s/prometheus.sh
hack/k3s/backstage.sh
hack/k3s/webapp.sh
