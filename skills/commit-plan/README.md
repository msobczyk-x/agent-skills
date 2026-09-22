# commit-plan

Proposes how to split the current git diff into logical commits — a Conventional Commit
message plus the exact files to stage for each — then always ends with a single
confirmation prompt (yes / adjust first / plan only) and, only on your explicit yes, runs
the commits in order. The prompt is asked every time, including when your request already
said to commit. Planning is read-only across staged, unstaged, and untracked changes and
nothing is ever pushed. Commit messages never carry agent attribution — no `Co-Authored-By`
for a bot, no generated-with line — even when the host tool's own rules demand one; every
commit it creates is checked afterwards and repaired if something slipped in. A
`Co-Authored-By` naming a real person is still added when you ask for it.

Portable [Agent Skill](https://agentskills.io) — works in Claude Code, Codex, and
OpenCode. Symlink this directory into each tool's skills path:

```bash
ln -s "$PWD/commit-plan"  ~/.claude/skills/commit-plan            # Claude Code (+ OpenCode reads this too)
ln -s "$PWD/commit-plan"  ~/.codex/skills/commit-plan             # Codex
ln -s "$PWD/commit-plan"  ~/.config/opencode/skills/commit-plan   # OpenCode (optional; already covered by ~/.claude/skills)
```

Then invoke it as `/commit-plan` (or let the agent auto-load it by description). You can
exclude files or scope the plan to a specific directory in your request.
