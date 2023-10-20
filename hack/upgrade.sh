#! /usr/bin/env bash
set -euo pipefail

source hack/init.sh

yarn backstage-cli versions:bump --pattern '@{backstage,roadiehq,drodil,k-phoen,veecode}/*'
