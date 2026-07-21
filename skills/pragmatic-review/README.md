# pragmatic-review

Reviews the current branch's changes like a senior engineer — judging them
against DRY, YAGNI, SOLID, and Pragmatic Programmer principles — and emits a
severity-ranked findings report. It reports only; it does not edit code.

Portable [Agent Skill](https://agentskills.io) — works in Claude Code, Codex, and
OpenCode. Symlink this directory into each tool's skills path:

```bash
ln -s "$PWD/pragmatic-review"  ~/.claude/skills/pragmatic-review            # Claude Code (+ OpenCode reads this too)
ln -s "$PWD/pragmatic-review"  ~/.codex/skills/pragmatic-review             # Codex
ln -s "$PWD/pragmatic-review"  ~/.config/opencode/skills/pragmatic-review   # OpenCode (optional; already covered by ~/.claude/skills)
```

Then invoke it as `/pragmatic-review` (or let the agent auto-load it by description).

## For React / React Native reviews

When the diff touches React/React Native, the review also delegates to three
companion skills from [vercel-labs/agent-skills](https://github.com/vercel-labs/agent-skills)
to catch bugs and performance/architecture issues:

- [`react-best-practices`](https://github.com/vercel-labs/agent-skills/tree/main/skills/react-best-practices)
- [`react-native-skills`](https://github.com/vercel-labs/agent-skills/tree/main/skills/react-native-skills)
- [`composition-patterns`](https://github.com/vercel-labs/agent-skills/tree/main/skills/composition-patterns)

If they aren't installed, the review asks for approval and can install them
globally via `scripts/install-react-skills.sh` (`npx skills add ... --global`).
You can also install them yourself ahead of time:

```bash
bash scripts/install-react-skills.sh
```
