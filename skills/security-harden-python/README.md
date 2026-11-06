# security-harden-python

Hardens a Python project's supply chain (locked/hashed installs, release cooldown,
registry-only sources, constraint floors) and adds pip-audit / Socket / Semgrep +
Bandit CI gates. Supports uv, pip, poetry, and pdm.

Language subskill of [`security-harden`](../security-harden/), which delegates
the Python checks here. It also works on its own: it scans first, reports the gaps,
and applies only the changes you confirm.

Portable [Agent Skill](https://agentskills.io) — works in Claude Code, Codex, and
OpenCode. Symlink this directory into each tool's skills path:

```bash
ln -s "$PWD/security-harden-python"  ~/.claude/skills/security-harden-python            # Claude Code (+ OpenCode reads this too)
ln -s "$PWD/security-harden-python"  ~/.codex/skills/security-harden-python             # Codex
ln -s "$PWD/security-harden-python"  ~/.config/opencode/skills/security-harden-python   # OpenCode (optional; already covered by ~/.claude/skills)
```

Then invoke it as `/security-harden-python` (or let the agent auto-load it by description).
