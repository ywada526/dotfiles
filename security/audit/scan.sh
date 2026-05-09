#!/usr/bin/env bash
# Run trivy + osv-scanner against $1 (a directory) and emit a single
# combined JSON document to stdout. Severity is filtered to HIGH and
# CRITICAL. One-shot, no state — compose with scheduling / diff /
# notification on top.
#
# Usage: scan.sh <path>
set -euo pipefail

TARGET="${1:?usage: scan.sh <path>}"
TARGET="${TARGET/#\~/$HOME}"

if [[ ! -d "$TARGET" ]]; then
  printf 'scan.sh: not a directory: %s\n' "$TARGET" >&2
  exit 1
fi

# Stage outputs as files instead of shell variables. Large monorepos
# can produce JSON that exceeds argv length limits when passed via
# --argjson; --slurpfile reads from a path and avoids that ceiling.
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

# Trivy: filter HIGH/CRITICAL at scan time. All scanners enabled
# (vuln + secret + misconfig + license) — start broad, narrow later.
# Skip vendored/build dirs because lockfiles already cover their
# package contents and secret/misconfig would noise on test
# fixtures. trivy fs exits 0 even with findings (no --exit-code),
# so bare invocation is safe under set -e.
trivy fs \
  --quiet \
  --format json \
  --severity HIGH,CRITICAL \
  --scanners vuln,secret,misconfig,license \
  --skip-dirs node_modules,.venv,target,vendor,.git \
  --output "$tmpdir/trivy.json" \
  "$TARGET"

# OSV-Scanner: capture to file, then post-filter.
# Exit codes (empirical; not formally documented):
#   0   - scan completed, no findings
#   1   - scan completed, findings present
#   128 - no package sources found in target (e.g. config-only repo)
#   *   - real error (treat as failure)
set +e
osv-scanner --recursive --format json "$TARGET" > "$tmpdir/osv-raw.json"
osv_exit=$?
set -e
case $osv_exit in
  0|1) ;;
  128) printf '{"results":[]}' > "$tmpdir/osv-raw.json" ;;
  *)
    printf 'scan.sh: osv-scanner failed (exit %d)\n' "$osv_exit" >&2
    exit "$osv_exit"
    ;;
esac

# Filter OSV by database_specific.severity (CVSS vector parsing is
# gnarly; the severity string is what GHSA / RUSTSEC / PYSEC actually
# publish). Vulns without a severity string are dropped — accepted
# tradeoff for "critical-only" reports.
jq '
  if .results then
    .results |= map(
      .packages |= map(
        .vulnerabilities |= map(
          select(
            (.database_specific.severity // "" | ascii_upcase) as $s |
            $s == "CRITICAL" or $s == "HIGH"
          )
        ) | select((.vulnerabilities | length) > 0)
      ) | select((.packages | length) > 0)
    )
  else . end
' "$tmpdir/osv-raw.json" > "$tmpdir/osv.json"

jq -n \
  --slurpfile trivy "$tmpdir/trivy.json" \
  --slurpfile osv "$tmpdir/osv.json" \
  --arg target "$TARGET" \
  '{
    target: $target,
    scanned_at: (now | todate),
    trivy: $trivy[0],
    osv: $osv[0]
  }'
