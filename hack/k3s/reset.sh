#!/usr/bin/env bash
set -euo pipefail

/usr/local/bin/k3s-uninstall.sh \
&& curl -sfL https://get.k3s.io | sh - 