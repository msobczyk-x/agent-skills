# security-harden

Scans a repository's security measures — CI/CD workflows, secrets handling,
containers, dependency updates, repo governance, and per-language supply chain —
against a current hardening baseline, reports the gaps by severity, and applies
the improvements you confirm. Language-specific checks are delegated to the
subskills:

| Subskill | Covers |
|----------|--------|
| [`security-harden-js`](../security-harden-js/) | Node / TypeScript (pnpm, npm, yarn, bun) + Node API / web-app measures |
| [`security-harden-python`](../security-harden-python/) | Python (uv, pip, poetry) |
| [`security-harden-go`](../security-harden-go/) | Go modules |
| [`security-harden-jvm`](../security-harden-jvm/) | Java / Kotlin (Gradle, Maven) |
| [`security-harden-rust`](../security-harden-rust/) | Rust (Cargo) |

It never commits, pushes, rotates secrets, or changes remote settings such as
branch protection — it prints those steps for you instead.

Portable [Agent Skill](https://agentskills.io) — works in Claude Code, Codex, and
OpenCode. Symlink this directory (and the subskills you need) into each tool's
skills path:

```bash
ln -s "$PWD/security-harden"  ~/.claude/skills/security-harden            # Claude Code (+ OpenCode reads this too)
ln -s "$PWD/security-harden"  ~/.codex/skills/security-harden             # Codex
ln -s "$PWD/security-harden"  ~/.config/opencode/skills/security-harden   # OpenCode (optional; already covered by ~/.claude/skills)
```

Then invoke it as `/security-harden` (or let the agent auto-load it by description).

## Scripts

- `scripts/detect-stack.sh [path]` — JSON summary of languages, package managers,
  lockfiles, containers, CI, update bots, governance files, and `.env` handling.
- `scripts/pin-actions.sh [workflow.yml …]` — resolves each `uses:` reference to a
  full commit SHA plus the latest stable release (`owner/repo@<sha> # vX.Y.Z`).
  Needs an authenticated `gh` and `jq`.
