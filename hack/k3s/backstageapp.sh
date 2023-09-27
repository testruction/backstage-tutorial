#!/usr/bin/env bash
set -euo pipefail

# Customize local development environment
# ----------------------------------------
yq -i '
  .app.listen.host = "0.0.0.0" |
  .app.listen.port = 3000 |
  .app.baseUrl = strenv(KC_FRONTEND_URL) |
  .backend.listen.host = "0.0.0.0" |
  .backend.listen.port = 7007 |
  .backend.baseUrl = strenv(KC_BACKEND_URL) |
  .backend.cors.origin = strenv(KC_FRONTEND_URL) |
  .catalog.locations[0].type = "file" |
  .catalog.locations[0].target = "../../../web-app/catalog-info.yaml" |
  .kubernetes.serviceLocatorMethod.type = "multiTenant" |
  .kubernetes.clusterLocatorMethods[0].type = "localKubectlProxy" |
  .argocd.username = "admin" |
  .argocd.password = "admin" |
  .argocd.appLocatorMethods[0].type = "config" |
  .argocd.appLocatorMethods[0].instances[0].name = "argocd" |
  .argocd.appLocatorMethods[0].instances[0].url = "http://localhost:10080" |
  .argocd.appLocatorMethods[0].instances[0].token = strenv(BS_ARGO_TOKEN)
' ./app-config.local.yaml

# Customize Argo CD application deployment
# ----------------------------------------
BS_ARGO_TOKEN=$(argocd account generate-token --account backstage)
export BS_ARGO_TOKEN

yq -i '
  .spec.source.helm.valuesObject.backstage.appConfig.argocd.appLocatorMethods[0].instances[0].token = strenv(BS_ARGO_TOKEN)
' ./deploy/argocd/applications/backstage.yaml

unset BS_ARGO_TOKEN

kubectl apply -f ./deploy/argocd/applications/backstage-rbac.yaml

argocd app create backstage -f ./deploy/argocd/applications/backstage.yaml
