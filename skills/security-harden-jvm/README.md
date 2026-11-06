# security-harden-jvm

Hardens a Java / Kotlin project's supply chain (Gradle locking + verification
metadata or Maven enforcer, restricted repositories, wrapper validation) and adds
OWASP Dependency-Check / Socket / Semgrep CI gates.

Language subskill of [`security-harden`](../security-harden/), which delegates
the Java / Kotlin checks here. It also works on its own: it scans first, reports the gaps,
and applies only the changes you confirm.

Portable [Agent Skill](https://agentskills.io) — works in Claude Code, Codex, and
OpenCode. Symlink this directory into each tool's skills path:

```bash
ln -s "$PWD/security-harden-jvm"  ~/.claude/skills/security-harden-jvm            # Claude Code (+ OpenCode reads this too)
ln -s "$PWD/security-harden-jvm"  ~/.codex/skills/security-harden-jvm             # Codex
ln -s "$PWD/security-harden-jvm"  ~/.config/opencode/skills/security-harden-jvm   # OpenCode (optional; already covered by ~/.claude/skills)
```

Then invoke it as `/security-harden-jvm` (or let the agent auto-load it by description).
