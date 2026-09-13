# commit-plan

Proposes how to split the current git diff into logical commits — a Conventional Commit
message plus the exact files to stage for each — then always ends with a single
confirmation prompt (yes / adjust first / plan only) and, only on your explicit yes, runs
the commits in order. The prompt is asked every time, including when your request already
said to commit. Planning is read-only across staged, unstaged, and untracked changes;
nothing is ever pushed, and commit messages never carry agent or co-author attribution.

Portable [Agent Skill](https://agentskills.io) — works in Claude Code, Codex, and
OpenCode. Symlink this directory into each tool's skills path:

```bash
ln -s "$PWD/commit-plan"  ~/.claude/skills/commit-plan            # Claude Code (+ OpenCode reads this too)
ln -s "$PWD/commit-plan"  ~/.codex/skills/commit-plan             # Codex
ln -s "$PWD/commit-plan"  ~/.config/opencode/skills/commit-plan   # OpenCode (optional; already covered by ~/.claude/skills)
```

Then invoke it as `/commit-plan` (or let the agent auto-load it by description). You can
exclude files or scope the plan to a specific directory in your request.
