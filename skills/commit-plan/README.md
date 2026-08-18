# commit-plan

Proposes how to split the current git diff into logical commits — a Conventional Commit
message plus the exact files to stage for each — then asks whether to create those commits
and, only on your explicit yes, runs them in order. Planning is read-only across staged,
unstaged, and untracked changes; nothing is ever pushed, and commit messages never carry
agent or co-author attribution.

Portable [Agent Skill](https://agentskills.io) — works in Claude Code, Codex, and
OpenCode. Symlink this directory into each tool's skills path:

```bash
ln -s "$PWD/commit-plan"  ~/.claude/skills/commit-plan            # Claude Code (+ OpenCode reads this too)
ln -s "$PWD/commit-plan"  ~/.codex/skills/commit-plan             # Codex
ln -s "$PWD/commit-plan"  ~/.config/opencode/skills/commit-plan   # OpenCode (optional; already covered by ~/.claude/skills)
```

Then invoke it as `/commit-plan` (or let the agent auto-load it by description). You can
exclude files or scope the plan to a specific directory in your request.
