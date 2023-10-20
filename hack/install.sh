#!/usr/bin/env bash
set -euo pipefail

function install_nvm()
{
  VERSION="0.39.5"
  
  einfo "Installing Node Version Manager (nvm) version ${VERSION}"

  if ! command -v nvm || [ ! "$(nvm --version)" == "${VERSION}" ]
  then
    wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v${VERSION}/install.sh | bash

    set -o allexport
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
    set +o allexport
  fi

  eok "Using node version $(nvm --version)"
}

function install_nodejs()
{
  VERSION="18.18.0"
  
  einfo "Installing Node.JS version ${VERSION}"

  if ! command -v node || [ ! $(node --version) == "v${VERSION}" ]
  then
    nvm install "${VERSION}"
  fi

  nvm use "${VERSION}"
}

function install_yarn()
{
  VERSION="1.22.19"
  
  einfo "Installing Yarn version ${VERSION}"

  if ! command -v yarn || [[ "$(yarn --version)" != "${VERSION}" ]]
  then
    npm install --global yarn
  fi
  
  yarn set version ${VERSION}

  eok "Using Yarn version ${VERSION}"
}

function install_yq()
{
    VERSION="4.35.1"

    if ! command -v yq || [[ ! $(yq --version) == *"${VERSION}" ]]
    then
        curl -sSL https://github.com/mikefarah/yq/releases/download/v${VERSION}/yq_linux_amd64.tar.gz \
        | tar xvzf -
        sudo mv -vf ./yq_linux_amd64 /usr/local/bin/yq
        sudo ./install-man-page.sh
        sudo chmod +x /usr/local/bin/yq

        rm -vf yq_linux_amd64.tar.gz ./install-man-page.sh ./yq**
    fi

    eok "Using YQ version ${VERSION}"
}

install_nvm
install_nodejs
install_yarn
install_yq