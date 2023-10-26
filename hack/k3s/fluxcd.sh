#!/usr/bin/env bash
set -eEuo pipefail

source hack/init.sh

flux install --namespace='flux-system'
