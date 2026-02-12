#!/usr/bin/env bash
set -euo pipefail
export PATH="/opt/homebrew/bin:$PATH"

# List all windows
windows="$(aerospace list-windows --workspace focused --json --format '%{app-bundle-id} %{window-id}')"

# Need at least 1 window
(( $(jq 'length' <<< "$windows") < 1 )) && exit 0

# Disable borders
borders width=0

# Flatten into a single column (v_accordion)
aerospace flatten-workspace-tree
aerospace layout v_accordion || true
