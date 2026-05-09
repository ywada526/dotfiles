# pkg/

Per-package-manager config files. Flat layout — one file per tool.
Generic filenames (`config.toml`, `env`) are prefixed with the tool
name in this directory; the symlink target keeps the canonical name.

| Source | Symlink target | Tool |
|---|---|---|
| `.npmrc` | `~/.npmrc` | npm/pnpm (npm-format config) |
| `.bunfig.toml` | `~/.bunfig.toml` | bun |
| `.gemrc` | `~/.gemrc` | RubyGems |
| `uv.toml` | `~/.config/uv/uv.toml` | uv (Python) |
| `pip.conf` | `~/.config/pip/pip.conf` | pip (Python) |
| `cargo-config.toml` | `~/.cargo/config.toml` | cargo (Rust) |
| `go-env` | `~/.config/go/env` | go (`go env -w` reads/writes this) |

Common theme across these files: supply-chain hardening defaults
(release-age cooldown, install-script blocking, registry pinning,
checksum verification). See each file's inline comments for the
specifics.

## Supply chain coverage by package manager

Status as actually configured in this repo. npm is excluded because
shell functions in [`../security/hooks.sh`](../security/hooks.sh)
block the binary entirely; pnpm replaces it.

Legend:
**✓** native + configured (or not applicable) · **△** partial · **✗** no support

| PM | Lifecycle script disable | Cooldown (release age) | Version pin | Lockfile injection | Package takeover |
|---|---|---|---|---|---|
| **pnpm** | ✓ pnpm v10+ blocks by default; `onlyBuiltDependencies: []` enforces empty allowlist | ✓ `minimumReleaseAge: 14d` set | ✓ `savePrefix: ""` + `pnpm-lock.yaml` + `--frozen-lockfile` | ✓ structurally resistant — won't install anything not in `package.json` | ✓ `trustPolicy: no-downgrade` set; cross-checks provenance / OIDC / registry signature |
| **bun** | ✓ `ignoreScripts = true` set | ✓ `minimumReleaseAge = 14d` set | ✓ `exact = true` + `bun.lock` + `--frozen-lockfile` | △ less ecosystem analysis than npm/pnpm | ✗ no equivalent feature |
| **uv** | ✓ PEP 517 isolated builds (arbitrary code possible but contained) | ✓ `exclude-newer = "14d"` set | ✓ `uv.lock` carries hashes | ✓ hash-pinned lock is hard to inject | △ PEP 740 attestations exist on PyPI side; uv client-side auto-verify still rolling out |
| **pip** | ✓ `only-binary = :all:` set — skips sdist build hooks | ✗ `--uploaded-prior-to` is v26+ and absolute-date only; not configured globally | ✓ enforced per-project via `==` + `--require-hashes` in requirements files | ✓ `--require-hashes` strongly resistant when used | △ PEP 740 attestations exist; pip client-side auto-verify still rolling out |
| **cargo** | ✗ `build.rs` has no opt-out; mitigate via `cargo-audit` / `cargo-deny` (installed via mise) | ✗ no native (third-party `cargo-cooldown` only) | ✓ `Cargo.lock` + `--locked` | ✓ `Cargo.lock` carries checksums | ✗ no native signing; RustSec advisories + Trusted Publishing (limited rollout) |
| **go** | ✓ no install-time script mechanism exists in Go | ✗ no native (would require proxy like Athens) | ✓ `go.mod` (MVS) + `go.sum` | ✓ `sum.golang.org` transparency log auto-verifies on `go get` | ✓ `GOSUMDB=sum.golang.org` + `GOTOOLCHAIN=local` set in `go-env` |
| **gem (RubyGems)** | ✗ `extconf.rb` / pre/post install hooks have no opt-out; mitigate via `bundler-audit` (per-project) | ✗ no native | ✓ enforced per-project via `Gemfile.lock` + `bundle install --frozen` | △ injection reported (similar mechanic to npm) | ✗ gem signing exists but is not used in practice |

Remaining gaps in this configuration:

- **bun lockfile injection**: bun's lockfile-lint ecosystem is thin.
  Audit lockfile diffs in PRs as a process control instead.
- **bun takeover, cargo takeover**: no native consumer-side trust
  policy. Closest available defense is `aqua:` for installs and
  cooldown for new releases.
- **pip cooldown**: native flag is absolute-date only and a v26+
  feature. Could be wrapped in a shell function that computes
  `date -v-14d` per call, but the OS-specific date syntax and
  pip-subcommand filtering make it brittle. `uv` is primary; pip
  is fallback, so left ungated.
- **cargo lifecycle, gem lifecycle**: ecosystem-level — `build.rs`
  and `extconf.rb` have no opt-out at the package-manager level.
  Caught at audit time (`cargo-audit`, `bundler-audit`) instead.
- **cargo cooldown, go cooldown, gem cooldown**: no native support.
  Org-level proxies (Athens, Nexus Firewall) would address this
  but are out of scope for a developer machine config.

The pattern: ecosystems built around binary distribution (Go) or
consumer-policy-first tooling (pnpm) close more holes natively;
script-on-install ecosystems (gem, cargo's `build.rs`) leave the
ceiling at "scan after install". pip lands awkwardly because most
of its security features require per-command flags that don't fit
in `pip.conf`.

## Related

- [`../mise/`](../mise/) — toolchain version management. Sets
  `minimum_release_age = "14d"` globally for mise's own backends,
  mirroring what's set per-tool in this directory. Also holds
  `pnpm-workspace-template.yaml` (copied into projects by the enter
  hook) — see [`../mise/README.md`](../mise/README.md).
- [`../security/hooks.sh`](../security/hooks.sh) — shell wrappers
  that block `npm`/`yarn`/`corepack` and route `pnpm`/`bun`/`pip`/
  `uv`/`cargo` through `sfw`.
