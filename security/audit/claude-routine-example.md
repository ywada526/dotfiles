# Daily supply-chain audit — Claude Code Desktop routine

Paste the fields below into a Claude Code Desktop **Local scheduled
task**. The task runs on this machine, has access to
`~/dotfiles/security/audit/`, and writes its output to `~/audit/`.

Recommended schedule: daily at 09:00 Asia/Tokyo (or whenever fits the
review cadence). The scan itself takes seconds; the LLM summary adds a
few more.

---

## Name

```
Daily supply-chain audit
```

## Description

```
Run trivy + osv-scanner across the local repos listed in
~/dotfiles/security/audit/targets, diff against yesterday's findings,
and write a Markdown report to ~/audit/reports/. Surfaces new
HIGH/CRITICAL CVEs and flags CRITICAL findings prominently.
```

## Prompt

```
You are running the daily supply-chain audit for this machine.

## Steps

1. Ensure output directories exist:
   mkdir -p ~/audit/scans ~/audit/reports

2. Run the scan and save today's result:
   ~/dotfiles/security/audit/scan-all.sh > ~/audit/scans/today.json
   note the exit code — non-zero means at least one target failed

3. Compute the diff against yesterday:
   - if ~/audit/scans/yesterday.json exists:
     - new CVEs   = vulnerabilities present in today but not yesterday
     - resolved   = vulnerabilities present in yesterday but not today
     - persistent = present in both
   - if not, this is the first run — diff section reads "baseline run".

   For both Trivy and OSV results, key on the tuple
   (target, package_name, vulnerability_id). Avoid double-counting
   when Trivy and OSV report the same CVE for the same package.

4. Write the report to ~/audit/reports/$(date -u +%Y-%m-%d).md with
   this structure:

       # Supply chain audit — YYYY-MM-DD

       Targets scanned: N (M failed)
       New: X  Resolved: Y  Persistent: Z

       ## Critical findings (if any)
       Bullet list — each entry: package, version, CVE, target, link
       Prefix the whole report with "🚨 CRITICAL FINDINGS DETECTED"
       if any CRITICAL severity item is present.

       ## New since yesterday
       Table: target | package | version | CVE | severity | link

       ## Resolved since yesterday
       Bullet list — each entry: target, package, CVE, reason
       (upgrade / package removed / CVE retracted)

       ## Failed scans
       Only if any. Show target + the captured stderr.

       ## Patterns
       Optional. Up to 3 bullet points of notable observations:
       e.g. "single repo accounts for 80% of HIGH findings",
       "new repo X introduced N findings on first scan",
       "OSV detected items Trivy missed (or vice versa)".

5. After the report is written, rotate the baseline:
   mv ~/audit/scans/today.json ~/audit/scans/yesterday.json

6. Print to stdout (this becomes the run-history entry):
   - the report file path
   - the summary line (Targets / New / Resolved / Persistent)
   - if CRITICAL: a 1-line alert pointing at the report

## Rules

- Severity is already filtered to HIGH/CRITICAL inside scan-all.sh.
  Do not re-filter — assume every finding is at least HIGH.
- CVE links: prefer https://osv.dev/vulnerability/<id> when the id
  starts with GHSA / RUSTSEC / PYSEC / CVE; fall back to
  https://nvd.nist.gov/vuln/detail/<CVE> for plain CVE-... ids.
- Be terse. The report is read at-a-glance, not as prose.
- If scan-all.sh itself errors (not just a per-target failure but
  the wrapper crashes), bail with the error message and skip the
  baseline rotation — preserves yesterday.json for the next run.
```

---

## Setting up the Desktop scheduled task

In Claude Code Desktop:

1. Open the Routines / Scheduled tasks UI
2. Choose **Local** (not Remote) so the task runs on this machine
3. Set schedule (cron or "daily at HH:MM")
4. Paste the entire fenced block above as the prompt
5. Save

The first run produces a baseline (no diff). The second run onward
shows day-over-day changes.

## Storage layout

```
~/audit/
├── scans/
│   ├── today.json       # current run (transient between steps 2 and 5)
│   └── yesterday.json   # baseline for diff (rotated each successful run)
└── reports/
    ├── 2026-05-09.md
    ├── 2026-05-10.md
    └── ...
```

`scans/` contains raw scanner JSON; `reports/` contains the human-
readable summaries. Neither is gitignored automatically — they live
under `~/audit/` not in the repo.

## Adding notification later

Slack DM / Notion page / email draft are all reachable via MCP
connectors (already wired in claude.ai). To add notification:

- After step 6, add a step that posts the summary line and a link to
  the report file via the desired connector
- Skip the post if New count is 0 (avoids daily noise)

This is intentionally not part of v1 — keeps the routine self-contained
and the failure surface small.
