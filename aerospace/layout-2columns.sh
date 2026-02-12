#!/usr/bin/env bash
set -euo pipefail
export PATH="/opt/homebrew/bin:$PATH"

# List all windows
windows="$(aerospace list-windows --workspace focused --json --format '%{app-bundle-id} %{window-id}')"

# Need at least 2 windows to form 2 columns
(( $(jq 'length' <<< "$windows") < 2 )) && exit 0

# Initialize workspace
aerospace flatten-workspace-tree
aerospace layout v_accordion || true # may fail if already v_accordion

# Pick left (ChatGPT), fallback to first window
left_window_id="$(jq -r '([.[] | select(.["app-bundle-id"] == "com.openai.chat")][0] // .[0]) | .["window-id"]' <<< "$windows")"

# Create 2-column structure
aerospace move left --window-id "$left_window_id"

# Enable borders
borders active_color=0xcc66cc66 inactive_color=0x00494d64 width=7

# Containerize each column
aerospace split --window-id "$left_window_id" vertical
aerospace layout --window-id "$left_window_id" accordion
