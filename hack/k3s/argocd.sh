#!/usr/bin/env bash

#!/usr/bin/env bash
set -euo pipefail

sudo curl -sSL -o /usr/local/bin/argocd \
  https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
sudo chmod +x /usr/local/bin/argocd

ADMIN_PWD="admin"
ADMIN_BCRYPT=$(argocd account bcrypt --password $ADMIN_PWD)
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update

helm upgrade --install \
  --wait \
  --namespace argo-cd \
  --create-namespace \
  --set configs.secret.argocdServerAdminPassword="${ADMIN_BCRYPT}" \
  --set server.extraArgs[0]="--insecure" \
  --set server.service.type="LoadBalancer" \
  --set server.service.servicePortHttp="10080" \
  --set controller.metrics.enabled="true" \
  --set controller.metrics.serviceMonitor.enabled="true" \
  --set dex.enabled="false" \
  --set dex.metrics.enabled="false" \
  --set dex.metrics.serviceMonitor.enabled="false" \
  --set redis.metrics.enabled="true" \
  --set redis.metrics.serviceMonitor.enabled="true" \
  --set server.metrics.enabled="true" \
  --set server.metrics.serviceMonitor.enabled="true" \
  --set repoServer.metrics.enabled="true" \
  --set repoServer.metrics.serviceMonitor.enabled="true" \
  --set applicationSet.enabled="false" \
  --set applicationSet.metrics.enabled="false" \
  --set applicationSet.metrics.serviceMonitor.enabled="false" \
  --set notifications.enabled="false" \
  --set notifications.metrics.enabled="false" \
  --set notifications.metrics.serviceMonitor.enabled="false" \
  gitops argo/argo-cd

argocd login  localhost:10080 --insecure --plaintext --username "admin" --password "${ADMIN_PWD}"

# GitOps account
kubectl -n argo-cd patch configmap/argocd-cm \
--type='json' \
--patch '[{"op": "add", "path": "/data/accounts.sysops", "value": "apiKey,login"}]'

# Backstage account
kubectl -n argo-cd patch configmap/argocd-cm \
--type='json' \
--patch '[{"op": "add", "path": "/data/accounts.backstage", "value": "apiKey,login"}]'

# Account RBAC
kubectl -n argo-cd patch configmap/argocd-rbac-cm \
--type='json' \
--patch '[{"op": "add", "path": "/data/policy.csv", "value": "g, sysops, role:admin\ng, backstage, role:readonly\n"}]'
