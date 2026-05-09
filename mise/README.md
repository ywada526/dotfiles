# mise/

Toolchain version management. `mise` (formerly rtx) installs and pins
language runtimes, CLIs, and developer tools per the spec in
[`.mise.toml`](.mise.toml).

## Files

| File | Purpose |
|---|---|
| `.mise.toml` | Tool versions + global settings + `enter` hook |
| `pnpm-workspace-template.yaml` | Copied into per-project `pnpm-workspace.yaml` by the enter hook |

## Backend choice

When picking a backend in `.mise.toml`, prefer in this order:

1. **`aqua:`** — uses [aqua-registry](https://github.com/aquaproj/aqua-registry).
   Verifies GitHub artifact attestations (sigstore) + checksums and
   honors `install_before` / `minimum_release_age`. Strongest
   cryptographic guarantee.
2. **`npm:`** — for tools published to the npm registry. Routed
   through pnpm via `npm.package_manager = "pnpm"` in `[settings]`,
   so the `npm` shell stub is never hit. Has no attestation
   verification but **honors `minimum_release_age`** — the cooldown
   buys time for the community to detect and yank malicious
   publishes (Shai-Hulud / Axios-class attacks are typically caught
   within hours-to-days). Combined with pnpm v10+'s default block on
   lifecycle scripts (`onlyBuiltDependencies` allowlist) the
   transitive-dep attack surface is reasonably narrowed.
3. **`ubi:`** — direct GitHub Releases download. **No attestation
   verification, no `install_before` support, no cooldown.** A
   compromised release tag (cf. the March 2026 Trivy incident) is
   fetched without any defense layer firing. Only acceptable when
   the upstream is trusted and the tool isn't available via
   `aqua:` / `npm:` / `cargo:`.

### Why `npm:` beats `ubi:` despite the larger nominal surface

The cooldown matters more than the absence of transitive deps.
GitHub Releases compromises (tag force-push, CI credential theft)
have a slower detection cadence than npm registry compromises —
fewer eyes, no automatic anomaly tooling like Socket / npq watching
GitHub Releases the way they watch npm publishes. `ubi:` walks
straight into that gap because nothing in the install path verifies
or delays. `npm:` at least has the 14-day window to inherit
community-side detection.

### `minimum_release_age` backend support

This is feature support per backend, not the safety ranking.

| Backend | Honored | Notes |
|---|---|---|
| `aqua` | ✓ | |
| `npm` | ✓ | Cutoff also forwarded to transitive dep resolution |
| `pipx` | ✓ | Same — propagates to transitive deps |
| `cargo` | ✓ | |
| `core` (some) | ✓ | |
| `ubi` | ✗ | No release-timestamp metadata exposed |
| `go` | ✗ | |

The setting filters fuzzy version requests (`@latest`, `@20`);
explicitly pinned versions install immediately regardless of age.

## Enter hook

Fires on every `cd` (global hook). Copies
`pnpm-workspace-template.yaml` into the target dir as
`pnpm-workspace.yaml` if and only if:

- target is not `$HOME`
- target has `package.json`
- target does not already have `pnpm-workspace.yaml`

Idempotent — re-entering an already-set-up project is a no-op.
