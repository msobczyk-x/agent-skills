# code-refactor

Restructures JS/TS React and React Native code so each file has one
responsibility — splits nested components and large constant groups into their
own files, applies the `index.tsx` parent-directory pattern, then runs a light
`code-simplify` cleanup. Public behavior is preserved.

Portable [Agent Skill](https://agentskills.io) — works in Claude Code, Codex, and
OpenCode. Symlink this directory into each tool's skills path:

```bash
ln -s "$PWD/code-refactor"  ~/.claude/skills/code-refactor            # Claude Code (+ OpenCode reads this too)
ln -s "$PWD/code-refactor"  ~/.codex/skills/code-refactor             # Codex
ln -s "$PWD/code-refactor"  ~/.config/opencode/skills/code-refactor   # OpenCode (optional; already covered by ~/.claude/skills)
```

Then invoke it as `/code-refactor` (or let the agent auto-load it by description).
