#!/usr/bin/env bash

function core_config()
{
    touch app-config.local.yaml

    yq -i '
    .organization.name = "Testruction" |
    .permission.enabled = true |
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
    .auth.providers.github.development.clientId = "${GITHUB_CLIENT_ID}" |
    .auth.providers.github.development.clientSecret = "${GITHUB_CLIENT_SECRET}"
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

function core_catalogue_config()
{
  yq -i '
  .catalog.providers.github.backstageId.organization = "testruction" |
  .catalog.providers.github.backstageId.catalogPath = "/catalog-info.yaml" |
  .catalog.providers.github.backstageId.filers.branch = "main" |
  .catalog.providers.github.backstageId.filers.repository = "backstage-tutorial" |
  .catalog.providers.github.backstageId.schedule.frequency.minutes = 15 |
  .catalog.providers.github.backstageId.schedule.timeout.minutes = 10
  ' app-config.local.yaml
}

function microservices_demo_catalogue_config()
{
  yq -i '
  .catalog.providers.github.backstageId.organization = "testruction" |
  .catalog.providers.github.backstageId.catalogPath = "/software-catalog/sock-shop/_index.yaml" |
  .catalog.providers.github.backstageId.filers.branch = "main" |
  .catalog.providers.github.backstageId.filers.repository = "backstage-tutorial" |
  .catalog.providers.github.backstageId.schedule.frequency.minutes = 15 |
  .catalog.providers.github.backstageId.schedule.timeout.minutes = 10
  ' app-config.local.yaml
}

function microservices_demo_catalogue_config()
{
  yq -i '
  .catalog.providers.github.backstageId.organization = "testruction" |
  .catalog.providers.github.backstageId.catalogPath = "/software-catalog/paypal/paypal.yaml" |
  .catalog.providers.github.backstageId.filers.branch = "main" |
  .catalog.providers.github.backstageId.filers.repository = "backstage-tutorial" |
  .catalog.providers.github.backstageId.schedule.frequency.minutes = 15 |
  .catalog.providers.github.backstageId.schedule.timeout.minutes = 10
  ' app-config.local.yaml
}

function fastapi_demo_catalogue_config()
{
  yq -i '
  .catalog.providers.github.backstageId.organization = "testruction" |
  .catalog.providers.github.backstageId.catalogPath = "/catalogue-info.yaml" |
  .catalog.providers.github.backstageId.filers.branch = "main" |
  .catalog.providers.github.backstageId.filers.repository = "fastapi-sqlalchemy-cockroachdb" |
  .catalog.providers.github.backstageId.schedule.frequency.minutes = 15 |
  .catalog.providers.github.backstageId.schedule.timeout.minutes = 10
  ' app-config.local.yaml
}

function kubernetes_config()
{
  yq -i '
  .kubernetes.serviceLocatorMethod.type = "multiTenant" |
  .kubernetes.clusterLocatorMethods[0].type = "localKubectlProxy" |
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
  .argocd.appLocatorMethods[0].instances[0].token = strenv(BS_ARGO_TOKEN)
  ' app-config.local.yaml
}
core_config
# auth_config
techdocs_config
github_config
core_catalogue_config
microservices_demo_catalogue_config
fastapi_demo_catalogue_config
kubernetes_config
argocd_config
