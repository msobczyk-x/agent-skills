---
name: security-harden
description: Scan a repository's security measures — CI/CD workflows, secrets handling, containers, dependency updates, repo governance, and per-language supply chain — against a current hardening baseline, report the gaps, then apply the confirmed improvements. Delegates language-specific checks to security-harden-js, security-harden-python, security-harden-go, security-harden-jvm, and security-harden-rust. Use when asked to audit, harden, or improve a repo's security posture, supply-chain security, or CI/CD security.
---

# Security Harden

Scan the repository's **existing** security measures, compare them to the
baseline below, and introduce what is missing or outdated. Language-agnostic
measures live here; language-specific supply-chain and app-level measures live
in the per-language subskills.

## Workflow

Copy this checklist and work through it:

```
Hardening Progress:
- [ ] 1. Detect the stack
- [ ] 2. Freshness check (live versions, not remembered ones)
- [ ] 3. Scan the language-agnostic baseline
- [ ] 4. Scan each detected language via its subskill
- [ ] 5. Write the gap report
- [ ] 6. Confirmation gate — wait for the user
- [ ] 7. Apply confirmed batches
- [ ] 8. Verify and report
```

### 1. Detect the stack

Run `scripts/detect-stack.sh` from the repo root (pass a path to scan another
directory). It prints JSON: languages and their package managers, lockfiles,
Dockerfiles, compose files, workflows, Dependabot/Renovate config, CODEOWNERS,
SECURITY.md, and `.env` handling. Read every file it lists before judging it.

### 2. Freshness check

Security tooling moves fast, so **never recommend a version, flag, or config key
from memory**. Before proposing one, confirm it against the live source:

- Package manager / tool versions: `npm view pnpm version`, `uv --version`,
  `go version`, `cargo --version`, the tool's `--help`, or its docs/changelog.
- Action SHAs: run `scripts/pin-actions.sh <workflow files…>` — it resolves each
  `uses: owner/repo@ref` to the full commit SHA and latest release tag via `gh api`.
- Base images: resolve the digest (`docker buildx imagetools inspect <image>:<tag>`).

If a measure needs a newer tool version than the repo pins (e.g. a pnpm setting
that only exists in a later release), say so and propose the upgrade as its own
batch. If you can't verify something, mark it **unverified** in the report
rather than guessing.

### 3. Language-agnostic baseline

Check each area against its reference checklist:

| Area | Reference |
|------|-----------|
| GitHub Actions / CI/CD | [references/github-actions.md](references/github-actions.md) |
| Secrets | [references/secrets.md](references/secrets.md) |
| Containers | [references/containers.md](references/containers.md) |
| Dependency updates | [references/dependency-updates.md](references/dependency-updates.md) |
| Repo governance | [references/governance.md](references/governance.md) |

Skip an area that doesn't apply (no Dockerfile → no container checks) and say so.

### 4. Language subskills

For each language detected in step 1, run its subskill in **scan mode** (report
only, no edits yet):

| Detected | Subskill |
|----------|----------|
| `package.json` (Node / TS / JS) | `security-harden-js` |
| `pyproject.toml`, `requirements*.txt`, `uv.lock`, `poetry.lock` | `security-harden-python` |
| `go.mod` | `security-harden-go` |
| `build.gradle(.kts)`, `pom.xml` | `security-harden-jvm` |
| `Cargo.toml` | `security-harden-rust` |

If a subskill isn't installed, read its `SKILL.md` from this skills repo
(`../security-harden-<lang>/SKILL.md`) and follow it directly. For a language
with no subskill, apply the shared rows of the baseline (locked install, release
cooldown, CVE audit, SAST, secret scanning) using that ecosystem's native tools,
and note the gap in the report.

### 5. Gap report

Group findings severity-high-first:

- **HIGH** — exploitable now or a supply-chain entry point: unpinned third-party
  actions, write-all token permissions, secrets in the repo or history, no
  lockfile enforcement, auth that fails open, containers running as root.
- **MEDIUM** — missing defence-in-depth: no release cooldown, no SAST/audit gate,
  no image scan, no CODEOWNERS on sensitive paths.
- **LOW** — hygiene: missing SECURITY.md, ungrouped update PRs, missing timeouts.

For each finding:

```
[SEVERITY] <measure> — present | partial | missing
Where: path/to/file:line (or "absent")
Change: <the concrete edit>
CI risk: <what could start failing, e.g. "audit gate fails on 2 existing highs">
```

End with a list of measures already in place, so the user sees what was checked.

### 6. Confirmation gate

Propose the changes as **small, independent batches** (e.g. "pin actions",
"pnpm supply-chain settings", "Trivy job", "Dockerfile non-root"). Each batch
lists the files it touches.

**Stop and wait for the user's explicit confirmation** — all batches, or a
named subset. Silence, a question, or "looks good" about the report is not
confirmation to edit.

### 7. Apply

Apply only the confirmed batches. For language batches, run the matching
subskill in **apply mode**. Match each file's existing style and indentation.

Never do these yourself — print the exact command or UI steps instead:

- commit, push, or open PRs (unless the user asks separately);
- rotate or revoke secrets, or edit repo/environment secrets;
- change remote settings (branch protection, rulesets, environments, required
  reviewers): give the `gh api` call or the Settings path;
- install third-party skills or global tools without approval.

App-level code changes (auth, headers, rate limits) change runtime behaviour —
report them as findings and apply only when the user opts in to that batch.

### 8. Verify and report

Run what the repo supports and report the real output, including failures:

- the locked install (`pnpm install --frozen-lockfile`, `uv sync --locked`, …);
- lint, typecheck, and tests;
- the newly added scanners locally where installed (`pnpm audit`, `semgrep`,
  `trivy`, `govulncheck`, `cargo deny check`, …);
- `actionlint` on changed workflows if available, otherwise a YAML parse.

Finish with: batches applied, files changed, verification results, and the
manual follow-ups (remote settings, secret rotation) the user still needs to do.
