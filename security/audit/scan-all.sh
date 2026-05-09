#!/usr/bin/env bash
# Read target paths/globs from `targets` (one per line) and run scan.sh
# against each, emitting a JSON array on stdout. Each element is
# either a success object or an error object — distinguish on field
# presence ("trivy"/"osv" vs "error"):
#
#   [
#     { target, scanned_at, trivy, osv },
#     { target, scanned_at, error },
#     ...
#   ]
#
# Lines starting with `#` and blank lines are ignored. Tilde and globs
# are expanded by the shell, so entries like `~/ghq/github.com/org/*`
# work directly.
#
# Exit code is 1 if any individual scan.sh failed, 0 otherwise. The
# JSON array always reflects every target attempted regardless.
#
# Usage: scan-all.sh [targets-file]
set -euo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
TARGETS_FILE="${1:-${TARGETS_FILE:-$HERE/targets}}"

if [[ ! -f "$TARGETS_FILE" ]]; then
  printf 'scan-all.sh: targets file not found: %s\n' "$TARGETS_FILE" >&2
  printf 'create one based on %s/targets.example\n' "$HERE" >&2
  exit 1
fi

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
stderr_file="$tmpdir/stderr"

results=()
any_failed=0
while IFS= read -r line || [[ -n "$line" ]]; do
  # strip leading whitespace, drop comments and blanks
  line="${line#"${line%%[![:space:]]*}"}"
  [[ -z "$line" || "$line" == \#* ]] && continue

  # Expand ~ and glob in one go. Unquoted on purpose.
  # shellcheck disable=SC2206
  expanded=( ${line/#\~/$HOME} )
  for path in "${expanded[@]}"; do
    [[ -d "$path" ]] || continue
    # Capture per-scan stderr so a failure can be embedded in the
    # output JSON. scan.sh's stdout (the success JSON) is separate.
    if result=$("$HERE/scan.sh" "$path" 2>"$stderr_file"); then
      results+=("$result")
    else
      exit_code=$?
      err_msg=$(<"$stderr_file")
      err_msg="${err_msg:-(no stderr captured)}"
      err_obj=$(jq -n \
        --arg target "$path" \
        --arg err "$err_msg" \
        '{target: $target, scanned_at: (now | todate), error: $err}')
      results+=("$err_obj")
      printf 'scan-all: %s failed (exit %d)\n' "$path" "$exit_code" >&2
      cat "$stderr_file" >&2
      any_failed=1
    fi
  done
done <"$TARGETS_FILE"

if (( ${#results[@]} == 0 )); then
  printf '[]\n'
else
  printf '%s\n' "${results[@]}" | jq -s '.'
fi

exit "$any_failed"
