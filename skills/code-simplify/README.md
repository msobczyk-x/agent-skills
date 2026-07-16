# code-simplify

Simplifies the code in the current diff without changing behavior — cuts
duplication and dead code, flattens nesting, and reuses existing helpers.

Portable [Agent Skill](https://agentskills.io) — works in Claude Code, Codex, and
OpenCode. Symlink this directory into each tool's skills path:

```bash
ln -s "$PWD/code-simplify"  ~/.claude/skills/code-simplify            # Claude Code (+ OpenCode reads this too)
ln -s "$PWD/code-simplify"  ~/.codex/skills/code-simplify             # Codex
ln -s "$PWD/code-simplify"  ~/.config/opencode/skills/code-simplify   # OpenCode (optional; already covered by ~/.claude/skills)
```

Then invoke it as `/code-simplify` (or let the agent auto-load it by description).
