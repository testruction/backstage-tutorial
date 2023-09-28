#!/usr/bin/env bash
set -euo pipefail

argocd app create demo --upsert -f deploy/argocd/applications/fastapi-demo.yaml
