#!/usr/bin/env bash
set -euo pipefail

argocd app create kube-prometheus -f deploy/argocd/applications/kube-prometheus.yaml

