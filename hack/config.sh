#!/usr/bin/env bash
set -euo pipefail

function core_config()
{
  touch app-config.local.yaml

  yq -i '
  .organization.name = "Testruction.io" |
  .permission.enabled = false |
  .app.title = "Backstage Demo" |
  .app.listen.host = "0.0.0.0" |
  .app.listen.host line_comment = "Required for Docker/WSL2" |
  .app.listen.port = 3000 |
  .app.baseUrl = "http://localhost:3000" |
  .backend.listen.host = "0.0.0.0" |
  .backend.listen.host line_comment = "Required for Docker/WSL2" |
  .backend.listen.port = 7007 |
  .backend.baseUrl = "http://localhost:7007" |
  .backend.cors.origin = "http://localhost:3000" |
  .backend.auth.keys[0].secret = "${FRONTEND_AUTH_KEY}" |
  .backend.csp.default-src[0] = "'self'" |
  .backend.csp.default-src[1] = "raw.githubusercontent.com" |
  .backend.csp.img-src[0] = "'self'" |
  .backend.csp.img-src[1] = "data:"
  ' app-config.local.yaml
}

function auth_config()
{
  yq -i '
  .auth.environment = "development" |
  .auth.providers.github.development.clientId = "${AUTH_GITHUB_CLIENT_ID}" |
  .auth.providers.github.development.clientSecret = "${AUTH_GITHUB_CLIENT_SECRET}"
  ' app-config.local.yaml
}

function techdocs_config()
{
  yq -i '
  .techdocs.sanitizer.allowedIframeHosts[0] = "www.github.com" |
  .techdocs.sanitizer.allowedIframeHosts[1] = "www.youtube.com" |
  .techdocs.generator.builder = "local" |
  .techdocs.generator.runIn = "docker" |
  .techdocs.generator.dockerImage = "spotify/techdocs" |
  .techdocs.generator.pullImage = true |
  .techdocs.publisher.type = "local"
  ' app-config.local.yaml
}

function github_config()
{
  yq -i '
  .integrations.github[0].host = "github.com" |
  .integrations.github[0].token = "${GITHUB_INTEGRATION_TOKEN}"
  ' app-config.local.yaml
}

function catalog_provider_github()
{
    yq -i '
    .catalog.locations[0].type = "url" |
    .catalog.locations[0].target = "https://github.com/testruction/backstage-tutorial/blob/main/software-catalog/core/locations.yaml" |
    .catalog.locations[0].rules[0].allow[0] = "User" |
    .catalog.locations[0].rules[0].allow[1] = "Group" |
    .catalog.locations[0].rules[0].allow[2] = "Domain" |
    .catalog.locations[1].type = "url" |
    .catalog.locations[1].target = "https://github.com/testruction/backstage-tutorial/blob/main/software-catalog/paypal/catalog-info.yaml" |
    .catalog.locations[2].type = "url" |
    .catalog.locations[2].target = "https://github.com/testruction/backstage-tutorial/blob/main/software-catalog/sock-shop/catalog-info.yaml" |
    .catalog.providers.github.default.branch = "main" |
    .catalog.providers.github.default.fallBackBranch = "master" |
    .catalog.providers.github.default.skipForkedRepos = true |
    .catalog.providers.github.default.organization = "testruction" |
    .catalog.providers.github.default.entityFilename = "catalog-info.yaml" |
    .catalog.providers.github.default.projectPattern = "[\s\S]*" |
    .catalog.providers.github.default.schedule.frequency.minutes = 30 |
    .catalog.providers.github.default.schedule.timeout.minutes = 3 |
    .catalog.providers.github.default.rules[0].allow[0] = "Resource" |
    .catalog.providers.github.default.rules[0].allow[1] = "Component" |
    .catalog.providers.github.default.rules[0].allow[2] = "API" |
    .catalog.providers.github.default.rules[0].allow[3] = "System" |
    .catalog.providers.github.default.rules[0].allow[4] = "Location"
    ' app-config.local.yaml
}

function kubernetes_config()
{
  yq -i '
  .kubernetes.serviceLocatorMethod.type = "multiTenant" |
  .kubernetes.clusterLocatorMethods[0].type = "localKubectlProxy"
  ' app-config.local.yaml
}

function argocd_config()
{
  yq -i '
  .argocd.username = "admin" |
  .argocd.password = "admin" |
  .argocd.appLocatorMethods[0].type = "config" |
  .argocd.appLocatorMethods[0].instances[0].name = "argocd" |
  .argocd.appLocatorMethods[0].instances[0].url = "http://localhost:10080" |
  .argocd.appLocatorMethods[0].instances[0].token = "${ARGOCD_AUTH_TOKEN}"
  ' app-config.local.yaml
}

function linguist_config()
{
  yq -i '
  .linguist.schedule.frequency.minutes = 3 |
  .linguist.schedule.timeout.minutes = 2 |
  .linguist.schedule.initialDelay.seconds = 15 |
  .linguist.age.days = 3 |
  .linguist.batchSize = 2 |
  .linguist.useSourceLocation = false |
  .linguist.tagsProcessor.bytesThreshold = 1000 |
  .linguist.tagsProcessor.languageTypes[0] = "programming" |
  .linguist.tagsProcessor.languageTypes[1] = "markup" |
  .linguist.tagsProcessor.languageTypes[2] = "data" |
  .linguist.tagsProcessor.languageTypes[3] = "prose" |
  .linguist.tagsProcessor.languageMap.Dockerfile = "''" |
  .linguist.tagsProcessor.languageMap.TSX = "react" |
  .linguist.tagsProcessor.languageMap.HCL = "terraform" |
  .linguist.tagsProcessor.languageMap.["Protocol Buffer"] = "protobuf" |
  .linguist.tagsProcessor.cacheTTL.hours = 24
  ' app-config.local.yaml
}

core_config
# auth_config
techdocs_config
github_config
catalog_provider_github
kubernetes_config
argocd_config
linguist_config
