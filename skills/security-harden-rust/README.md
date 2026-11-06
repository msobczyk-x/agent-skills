# security-harden-rust

Hardens a Rust project's supply chain (`--locked` builds, pinned toolchain,
cargo-deny sources/advisories/bans/licenses) and adds cargo-deny / Socket /
Semgrep + clippy CI gates.

Language subskill of [`security-harden`](../security-harden/), which delegates
the Rust checks here. It also works on its own: it scans first, reports the gaps,
and applies only the changes you confirm.

Portable [Agent Skill](https://agentskills.io) — works in Claude Code, Codex, and
OpenCode. Symlink this directory into each tool's skills path:

```bash
ln -s "$PWD/security-harden-rust"  ~/.claude/skills/security-harden-rust            # Claude Code (+ OpenCode reads this too)
ln -s "$PWD/security-harden-rust"  ~/.codex/skills/security-harden-rust             # Codex
ln -s "$PWD/security-harden-rust"  ~/.config/opencode/skills/security-harden-rust   # OpenCode (optional; already covered by ~/.claude/skills)
```

Then invoke it as `/security-harden-rust` (or let the agent auto-load it by description).
