#!/usr/bin/env bash
set -eEuo pipefail

source hack/init.sh

flux bootstrap github \
  --owner=testruction \
  --repository=backstage-tutorial \
  --branch=main \
  --path=/deploy/flux2 \
  --personal
