#!/usr/bin/env bash
set -euo pipefail
export PATH="/opt/homebrew/bin:$PATH"

# List only tiling windows (exclude floating, hidden, minimized, fullscreen, etc.)
windows="$(aerospace list-windows --workspace focused --json --format '%{app-bundle-id} %{window-id} %{window-layout}' | jq '[.[] | select(.["window-layout"] | test("^(h_|v_)?(tiles|accordion)$"))]')"

# Need at least 1 window
(( $(jq 'length' <<< "$windows") < 1 )) && exit 0

# Flatten into a single column (v_accordion)
aerospace flatten-workspace-tree
aerospace layout v_accordion || true
