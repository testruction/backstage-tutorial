#!/usr/bin/env bash
set -euo pipefail

argocd app create demo -f deploy/argocd/fastapi-demo.yaml
