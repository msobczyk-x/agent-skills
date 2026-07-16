# cleanup-comments

Trims noisy/redundant comments in the current diff so the code stays
self-explanatory — keeps only genuinely necessary comments, as small as possible.

Portable [Agent Skill](https://agentskills.io) — works in Claude Code, Codex, and
OpenCode. Symlink this directory into each tool's skills path:

```bash
ln -s "$PWD/cleanup-comments"  ~/.claude/skills/cleanup-comments            # Claude Code (+ OpenCode reads this too)
ln -s "$PWD/cleanup-comments"  ~/.codex/skills/cleanup-comments             # Codex
ln -s "$PWD/cleanup-comments"  ~/.config/opencode/skills/cleanup-comments   # OpenCode (optional; already covered by ~/.claude/skills)
```

Then invoke it as `/cleanup-comments` (or let the agent auto-load it by description).
