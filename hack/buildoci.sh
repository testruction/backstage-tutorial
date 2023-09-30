#!/usr/bin/env bash
set -euo pipefail

source hack/init.sh

docker image build \
  --tag oci.local/testruction/backstage:dev \
  --file packages/backend/Dockerfile \
  ./
