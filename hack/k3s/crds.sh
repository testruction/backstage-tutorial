#!/usr/bin/env bash
set -euo pipefail

# Prometheus Operator / Kube-Prometheus
VERSION='6.0.0'
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

helm upgrade --install \
  --version "${VERSION}" \
  prometheus-operator-crds prometheus-community/prometheus-operator-crds
