# commit-plan

Proposes how to split the current git diff into logical commits — a Conventional Commit
message plus the exact files to stage for each. Advisory only: it inspects staged,
unstaged, and untracked changes and makes **no** git changes of its own.

Portable [Agent Skill](https://agentskills.io) — works in Claude Code, Codex, and
OpenCode. Symlink this directory into each tool's skills path:

```bash
ln -s "$PWD/commit-plan"  ~/.claude/skills/commit-plan            # Claude Code (+ OpenCode reads this too)
ln -s "$PWD/commit-plan"  ~/.codex/skills/commit-plan             # Codex
ln -s "$PWD/commit-plan"  ~/.config/opencode/skills/commit-plan   # OpenCode (optional; already covered by ~/.claude/skills)
```

Then invoke it as `/commit-plan` (or let the agent auto-load it by description). You can
exclude files or scope the plan to a specific directory in your request.
