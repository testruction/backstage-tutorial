#!/usr/bin/env bash
set -euo pipefail

# Customize local development environment
# ----------------------------------------
BS_ARGO_TOKEN=$(argocd account generate-token --account backstage)
export BS_ARGO_TOKEN
yq -i '
  .app.listen.host = "0.0.0.0" |
  .app.listen.port = 3000 |
  .app.baseUrl = "http://localhost:3000" |
  .backend.listen.host = "0.0.0.0" |
  .backend.listen.port = 7007 |
  .backend.baseUrl = "http://localhost:7007" |
  .backend.cors.origin = "http://localhost:3000" |
  .catalog.locations[0].type = "file" |
  .catalog.locations[0].target = "../../../web-app/catalog-info.yaml" |
  .kubernetes.serviceLocatorMethod.type = "multiTenant" |
  .kubernetes.clusterLocatorMethods[0].type = "localKubectlProxy" |
  .proxy.'/prometheus0/api'.target = "http://localhost:9090/api/v1/" |
  .prometheus.proxyPath = "/prometheus0/api" |
  .argocd.username = "admin" |
  .argocd.password = "admin" |
  .argocd.appLocatorMethods[0].type = "config" |
  .argocd.appLocatorMethods[0].instances[0].name = "argocd" |
  .argocd.appLocatorMethods[0].instances[0].url = "http://localhost:10080" |
  .argocd.appLocatorMethods[0].instances[0].token = strenv(BS_ARGO_TOKEN)
' ./app-config.local.yaml

# Customize Argo CD application deployment
# ----------------------------------------
cp -vf ./deploy/argocd/applications/backstage.yaml ./deploy/argocd/applications/backstage.local.yaml

yq -i '
  .spec.source.helm.valuesObject.backstage.appConfig.argocd.appLocatorMethods[0].instances[0].token = strenv(BS_ARGO_TOKEN)
' ./deploy/argocd/applications/backstage.yaml

unset BS_ARGO_TOKEN

kubectl apply -f ./deploy/argocd/applications/backstage-rbac.yaml

argocd app create backstage --upsert -f ./deploy/argocd/applications/backstage.local.yaml
