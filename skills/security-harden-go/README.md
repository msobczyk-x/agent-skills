# security-harden-go

Hardens a Go module's supply chain (verified read-only resolution, checksum
database, minimal GOPRIVATE) and adds govulncheck / Socket / Semgrep + gosec CI
gates, with static binaries on distroless.

Language subskill of [`security-harden`](../security-harden/), which delegates
the Go checks here. It also works on its own: it scans first, reports the gaps,
and applies only the changes you confirm.

Portable [Agent Skill](https://agentskills.io) — works in Claude Code, Codex, and
OpenCode. Symlink this directory into each tool's skills path:

```bash
ln -s "$PWD/security-harden-go"  ~/.claude/skills/security-harden-go            # Claude Code (+ OpenCode reads this too)
ln -s "$PWD/security-harden-go"  ~/.codex/skills/security-harden-go             # Codex
ln -s "$PWD/security-harden-go"  ~/.config/opencode/skills/security-harden-go   # OpenCode (optional; already covered by ~/.claude/skills)
```

Then invoke it as `/security-harden-go` (or let the agent auto-load it by description).
