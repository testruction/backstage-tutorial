#!/usr/bin/env bash
set -euo pipefail

source hack/share/custom-logger.sh -V

function init_env()
{
  if [ ! -f .env ]
  then
      ewarn 'Environment ".env" file not found'
      ewarn 'Creating using default settings from ".env.example"'
      cp .env.example .env
  fi

  set -o allexport
  source .env
  set +o allexport
  eok "Environment variables initialized from \"${PWD}/.env\""

  if [[ -z ${GITHUB_INTEGRATION_TOKEN} ]]
  then
      eerror "La variable \"GITHUB_INTEGRATION_TOKEN\" value is absent in file \".env\""
      exit 1
#   elif [[ -z ${GITHUB_CLIENT_ID} ]]
#   then
#       eerror "The \"GITHUB_CLIENT_ID\" value is absent in file \".env\""
#       exit 1
#   elif [[ -z ${GITHUB_CLIENT_SECRET} ]]
#   then
#       eerror "La variable \"GITHUB_CLIENT_SECRET\" value is absent in file \".env\""
#       exit 1
  fi
}

function createorupdate_dependencies()
{
    einfo "Installing Backstage dependencies"
    yarn install 
}

function createorupdate_local_config()
{
    einfo "Configuring Backstage local development environment"
    hack/config.sh
}

init_env
createorupdate_dependencies
createorupdate_local_config
