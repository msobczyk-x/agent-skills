---
name: security-harden-js
description: Scan and harden a JavaScript/TypeScript (Node) project's supply chain and app security — pinned package manager, frozen lockfile installs, release cooldown, trust policy, blocked exotic deps, install-script allowlist, security overrides, audit/Socket/Semgrep CI gates, real typecheck gates, and Node API / web-app measures. Supports pnpm, npm, yarn, and bun. Use when hardening a JS/TS/Node repo's security, or when security-harden delegates the JS checks.
---

# Security Harden — JavaScript / TypeScript

Language subskill of `security-harden`. It runs in two modes:

- **scan** — report each measure below as present / partial / missing, with the
  file and the concrete change. No edits.
- **apply** — make the changes the user confirmed, nothing else.

When invoked directly (not from `security-harden`), scan first, show the report,
and wait for explicit confirmation before applying.

**Verify before you write.** Every setting below depends on the package-manager
version. Check the installed and latest versions (`pnpm --version`,
`npm view pnpm version`) and the docs for the setting before adding it. If the
repo's version is too old, propose the upgrade as its own batch.

## Detect the package manager

`pnpm-lock.yaml` → pnpm · `yarn.lock` → yarn · `bun.lock`/`bun.lockb` → bun ·
`package-lock.json` → npm. In a monorepo, check every `package.json`.

## Supply chain

| Measure | pnpm | npm | yarn (berry) | bun |
|---------|------|-----|--------------|-----|
| Pin the manager | `"packageManager": "pnpm@x.y.z"` | `"packageManager": "npm@x.y.z"` | `"packageManager": "yarn@x.y.z"` | `"packageManager": "bun@x.y.z"` |
| Locked install (CI, Docker) | `pnpm install --frozen-lockfile` | `npm ci` | `yarn install --immutable` | `bun install --frozen-lockfile` |
| Release cooldown (7 days) | `minimumReleaseAge: 10080` | release-age config if the npm version has it, else flag | `npmMinimalAgeGate` | `minimumReleaseAge` in `bunfig.toml` |
| Reject provenance downgrade | `trustPolicy: no-downgrade` | — | — | — |
| Registry-only transitive deps | `blockExoticSubdeps: true` | — (flag git/tarball deps in lockfile) | — (same) | — (same) |
| Install-script allowlist | `allowBuilds` / `onlyBuiltDependencies` | `ignore-scripts=true` + explicit rebuilds | `enableScripts: false` + `dependenciesMeta` | `trustedDependencies` |
| Security floors | `overrides` | `overrides` | `resolutions` | `overrides` |

pnpm settings go in `pnpm-workspace.yaml` (pnpm 10+); older versions use `.npmrc`
or `package.json#pnpm`. Check which the repo uses.

Rules:

- [ ] `packageManager` pinned and `engines.node` set to a **current LTS** floor
      (check nodejs.org release schedule; flag EOL versions HIGH).
- [ ] Every install in CI workflows and Dockerfiles uses the locked flag.
- [ ] Release cooldown set to 7 days, matching the Dependabot cooldown.
- [ ] `trustPolicyExclude` (if needed) lists **exact versions only**, each with a
      comment explaining why.
- [ ] Install scripts allowlisted — list the packages that genuinely need them
      (esbuild, sharp, prisma, …); nothing else runs `postinstall`.
- [ ] Each override has a comment with the date, the CVE/GHSA, and the drop
      condition ("remove once <parent> ≥ x.y"). Remove overrides whose parents
      already caught up.

## CI gates (every PR + main)

- [ ] **CVE audit** on what ships: `pnpm audit --prod --audit-level=high`
      (`npm audit --omit=dev --audit-level=high`, `yarn npm audit --environment production --severity high`).
      Dev tooling is left to Dependabot.
- [ ] **Socket** (`socket ci`) with a `socket.yml` — catches malware, install
      scripts, obfuscation, typosquats, protestware, new/unstable maintainers.
      Needs a Socket API key secret; tell the user to add it.
- [ ] **Semgrep** with the JS packs relevant to the code:
      `p/default p/typescript p/javascript p/nodejs` plus `p/expressjs`,
      `p/react`, `p/nextjs` as applicable; `--error` + SARIF upload (job shape in
      `security-harden/references/github-actions.md`).
- [ ] **Lint and typecheck are real gates.** Make sure `tsc` actually checks
      files: a solution-style `tsconfig.json` with `"files": []` + `references`
      checks nothing under `tsc --noEmit` — use `tsc -b` or point at each project.

## App-level

For Node APIs and web frontends, check the measures in
[references/app-level.md](references/app-level.md). These change runtime
behaviour — report them, and apply only the ones the user opts into.

## Containers

Node-specific additions to the shared container checklist:

- [ ] Runtime stage based on a slim / distroless Node image, pinned by digest.
- [ ] `npm`, `corepack`, and `yarn` removed from the runtime stage when the app
      doesn't use them at runtime.
- [ ] `ENV NODE_ENV=production` in the image; `USER node` (or another non-root user).
- [ ] Production install only (`pnpm install --frozen-lockfile --prod` or
      `pnpm deploy --prod`) in the runtime stage.

## Verify

Run the locked install, `pnpm audit --prod --audit-level=high`, lint, typecheck,
and tests, and report the real output. If the audit gate fails on existing
issues, list them and propose overrides or upgrades rather than lowering the
threshold.
