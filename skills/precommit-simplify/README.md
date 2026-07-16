# precommit-simplify

Tidies up staged changes before a commit by running `code-simplify` first, then
`cleanup-comments`, then reports what changed. Does not auto-commit.

Requires the [`code-simplify`](../code-simplify/) and
[`cleanup-comments`](../cleanup-comments/) skills to be installed too.

Portable [Agent Skill](https://agentskills.io) — works in Claude Code, Codex, and
OpenCode. Symlink this directory into each tool's skills path:

```bash
ln -s "$PWD/precommit-simplify"  ~/.claude/skills/precommit-simplify            # Claude Code (+ OpenCode reads this too)
ln -s "$PWD/precommit-simplify"  ~/.codex/skills/precommit-simplify             # Codex
ln -s "$PWD/precommit-simplify"  ~/.config/opencode/skills/precommit-simplify   # OpenCode (optional; already covered by ~/.claude/skills)
```

Then invoke it as `/precommit-simplify` (or let the agent auto-load it by description).
