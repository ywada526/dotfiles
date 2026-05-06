# pnpm setup

pnpm is the only Node.js package manager allowed on this machine.
npm / npx / corepack are blocked by shell functions defined in
[`../security/blockers.sh`](../security/blockers.sh) (sourced from
both .zshenv and .bashrc/.bash_profile, plus BASH_ENV for non-interactive
bash subshells).

## Files

| File | Symlink target | Purpose |
|---|---|---|
| `.npmrc` | `~/.npmrc` | npm-format config (registry, save-exact, security flags) |
| `pnpm-workspace.yaml` | (none — copied per project) | Template injected by mise enter hook into projects with `package.json` |

## Backend choice for `npm:` migration

When migrating away from `npm:` in `.mise.toml`, prefer in this order:

1. **`aqua:`** — uses [aqua-registry](https://github.com/aquaproj/aqua-registry).
   Verifies GitHub artifact attestations (sigstore) + checksums. **Honors
   `install_before`/`minimum_release_age`.**
2. **`ubi:`** — direct GitHub releases download. Simple, but **does NOT honor
   `install_before`** (no release-timestamp metadata exposed). Use only when
   `aqua:` is unavailable.
3. **`npm:`** — last resort for tools that don't ship binaries. Routed through
   pnpm via `npm.package_manager = "pnpm"` in `[settings]`, so the npm stubs
   are never hit.

### `minimum_release_age` backend support

| Backend | Honored | Notes |
|---|---|---|
| `aqua` | ✓ | |
| `npm` | ✓ | Cutoff also forwarded to transitive dep resolution |
| `pipx` | ✓ | Same — propagates to transitive deps |
| `cargo` | ✓ | |
| `core` (some) | ✓ | |
| `ubi` | ✗ | |
| `go` | ✗ | |

The setting filters fuzzy version requests (`@latest`, `@20`); explicitly
pinned versions install immediately regardless of age.

## Enter hook (in `.mise.toml`)

Fires on every `cd` (global hook). Generates `pnpm-workspace.yaml` in the
target dir if and only if:
- target is not `$HOME`
- target has `package.json`
- target does not already have `pnpm-workspace.yaml`

Idempotent — re-entering an already-set-up project is a no-op.
