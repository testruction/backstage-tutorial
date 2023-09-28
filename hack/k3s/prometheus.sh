#!/usr/bin/env bash
set -euo pipefail

argocd app create kube-prometheus --upsert -f deploy/argocd/applications/kube-prometheus.yaml

