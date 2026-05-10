# security/audit/

Composable supply-chain audit scripts. Each script is a one-shot
command that reads input, emits JSON to stdout, and exits — no
state, no scheduling, no notification. Compose them with whatever
runs on top: a cron job, a shell pipeline, a CI step, a scheduled
agent.

## Files

| File | Purpose |
|---|---|
| `scan.sh` | Run trivy + osv-scanner against one directory, emit combined JSON (HIGH/CRITICAL only) |
| `scan-all.sh` | Iterate over `targets`, call `scan.sh` per entry, emit a JSON array |
| `targets.example` | Template for the gitignored `targets` file |
| `targets` | (gitignored) Per-machine list of paths/globs |
| `claude-routine-example.md` | Name / Description / Prompt template for a Claude Code Desktop Local scheduled task that runs the audit daily, diffs vs. yesterday, and writes a Markdown report under `~/audit/` |

## Usage

```bash
# Single path
./scan.sh ~/some-repo > today.json

# All paths listed in `targets`
cp targets.example targets   # then edit
./scan-all.sh > today.json

# Pipe straight into something else
./scan-all.sh | jq '[.[] | select(.trivy.Results // [] | length > 0)]'
```

`trivy` and `osv-scanner` are managed via
[`../../mise/.mise.toml`](../../mise/.mise.toml).

## Severity filtering

- `trivy fs --severity HIGH,CRITICAL` filters at scan time
- `osv-scanner` has no equivalent CLI flag; `scan.sh` post-filters by
  `database_specific.severity` via jq. Vulnerabilities without a
  severity string are dropped — accepted tradeoff for noise reduction

To raise/lower the threshold, edit `scan.sh` directly. There's no env
knob on purpose — drift between Trivy's severity flag and the OSV jq
filter is easier to spot when both are in one file.

## Output shape

`scan.sh` emits one JSON object per invocation:

```json
{
  "target": "/abs/path",
  "scanned_at": "2026-05-09T03:21:00Z",
  "trivy": { /* trivy fs JSON, severity-filtered */ },
  "osv":   { /* osv-scanner JSON, severity-filtered */ }
}
```

`scan-all.sh` wraps the per-target objects into a JSON array. On
individual failures, an error object is inserted instead of the
success shape — distinguish on field presence (`trivy`/`osv` vs
`error`):

```json
[
  { "target": "/abs/path/a", "scanned_at": "...", "trivy": {...}, "osv": {...} },
  { "target": "/abs/path/b", "scanned_at": "...", "error": "scan.sh stderr ..." },
  { "target": "/abs/path/c", "scanned_at": "...", "trivy": {...}, "osv": {...} }
]
```

## Failure behavior

- `scan.sh` exits non-zero if either tool fails (network error,
  parse error, etc.). It does **not** treat findings as failure —
  a scan with vulnerabilities still exits 0 as long as the tools
  ran cleanly. (osv-scanner's exit-1-on-findings and exit-128-on-
  no-package-sources are normalized to 0 inside `scan.sh`.)
- `scan-all.sh` continues past individual `scan.sh` failures and
  embeds each as `{target, scanned_at, error}` in-band. It exits
  with code 1 if any scan failed, 0 otherwise. The JSON array on
  stdout always reflects every target attempted.
