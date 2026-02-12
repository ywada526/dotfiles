#!/usr/bin/env bash
set -euo pipefail
export PATH="/opt/homebrew/bin:$PATH"

# List all windows
windows="$(aerospace list-windows --workspace focused --json --format '%{app-bundle-id} %{window-id}')"

# Need at least 3 windows to form 3 columns
(( $(jq 'length' <<< "$windows") < 3 )) && exit 0

# Initialize workspace
aerospace flatten-workspace-tree
aerospace layout v_accordion || true # may fail if already v_accordion

# Pick right (Obsidian) and left (ChatGPT), fallback to any available window
right_window_id="$(jq -r '([.[] | select(.["app-bundle-id"] == "md.obsidian")][0] // .[0]) | .["window-id"]' <<< "$windows")"
left_window_id="$(jq -r '([.[] | select(.["app-bundle-id"] == "com.openai.chat")][0] // .[1]) | .["window-id"]' <<< "$windows")"

# Create 3-column structure
aerospace move right --window-id "$right_window_id"
aerospace move left --window-id "$left_window_id"
aerospace resize smart +500

# Enable borders
borders active_color=0xcc66cc66 inactive_color=0x00494d64 width=7

# Containerize each column
aerospace split --window-id "$right_window_id" vertical
aerospace layout --window-id "$right_window_id" accordion
aerospace split --window-id "$left_window_id" vertical
aerospace layout --window-id "$left_window_id" accordion
