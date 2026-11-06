# security-harden-js

Hardens a Node / TypeScript project's supply chain (pinned package manager, frozen
lockfile, release cooldown, trust policy, install-script allowlist, overrides),
adds audit / Socket / Semgrep CI gates, and checks Node API and web-app security
measures. Supports pnpm, npm, yarn, and bun.

Language subskill of [`security-harden`](../security-harden/), which delegates
the JavaScript / TypeScript checks here. It also works on its own: it scans first, reports the gaps,
and applies only the changes you confirm.

Portable [Agent Skill](https://agentskills.io) — works in Claude Code, Codex, and
OpenCode. Symlink this directory into each tool's skills path:

```bash
ln -s "$PWD/security-harden-js"  ~/.claude/skills/security-harden-js            # Claude Code (+ OpenCode reads this too)
ln -s "$PWD/security-harden-js"  ~/.codex/skills/security-harden-js             # Codex
ln -s "$PWD/security-harden-js"  ~/.config/opencode/skills/security-harden-js   # OpenCode (optional; already covered by ~/.claude/skills)
```

Then invoke it as `/security-harden-js` (or let the agent auto-load it by description).
