# AGENTS.md

Guidance for AI coding agents (Claude Code, Codex, OpenCode, Cursor, Copilot, …)
working in this repository. If you're adding or editing a skill, read this first.

## Repository overview

A small collection of **portable** coding-agent skills. Each skill is a directory
under `skills/` containing a `SKILL.md` that follows the
[Agent Skills](https://agentskills.io) open standard, so the **same** files work
across Claude Code, Codex, and OpenCode with no per-tool duplication. Keep that
portability constraint in mind for every change.

## Directory structure

```
skills/
  {skill-name}/          # kebab-case; must match SKILL.md `name`
    SKILL.md             # required: frontmatter + instructions
    README.md            # required: human-facing install docs
    references/          # optional: docs loaded on demand (see code-refactor/, pragmatic-review/)
    scripts/             # optional: executable scripts (see pragmatic-review/scripts/)
```

## SKILL.md format

Frontmatter uses **only** the two fields all three tools validate — do not add
others, or the file stops being portable:

- `name` — kebab-case, identical to the directory name, ≤64 chars.
- `description` — states **what** the skill does and **when** to use it, including
  the trigger phrases an agent should match on (e.g. "Use when asked to clean up
  comments … before committing or reviewing a diff").

```yaml
---
name: cleanup-comments
description: Remove noise comments from the files in the current diff … Use when asked to clean up comments in the current changes, or before committing or reviewing a diff.
---
```

The body is plain instruction Markdown — there is **no** fixed template of required
headings. Write the sections the skill actually needs. Use existing skills as
models: `skills/cleanup-comments/SKILL.md` (instruction-only) and
`skills/pragmatic-review/SKILL.md` (instructions + `references/` + a `scripts/`
helper).

## README.md convention

Every skill ships a short `README.md` for humans: a one-line summary, a note that
it's a portable Agent Skill, the symlink-install block for each tool, and how to
invoke it (`/skill-name` or auto-load by description). Mirror the shape of
`skills/cleanup-comments/README.md` and `skills/pragmatic-review/README.md`.

## Naming conventions

- **Skill directory** and frontmatter `name`: `kebab-case`, and identical to each
  other (e.g. `code-refactor`).
- **`SKILL.md`** and **`README.md`**: exact filenames, always uppercase `SKILL.md`.
- **Scripts**: `kebab-case.sh` or `kebab-case.mjs`.

## Context-efficiency best practices

Skills load on demand — only `name` + `description` load up front; the full
`SKILL.md` loads when relevant. To keep context lean:

- Keep `SKILL.md` focused; move detailed reference material into `references/` files
  linked from `SKILL.md` (one level deep).
- Write specific descriptions so agents auto-load the skill at the right time.
- Prefer scripts over inline code — script execution doesn't consume context.

## Script requirements

For skills that ship scripts (`scripts/`):

- Bash: `#!/usr/bin/env bash` (or `#!/bin/bash`) and `set -euo pipefail`.
- Node: `#!/usr/bin/env node` and a `.mjs` extension.
- Write status/progress to stderr; write machine-readable output (JSON) to stdout.
- Reference scripts by relative path from `SKILL.md`.

**Third-party dependencies are opt-in.** Never install external/third-party skills
silently — ask for approval first, and ship a script that installs them globally
via `npx skills add … --global`. See
`skills/pragmatic-review/scripts/install-react-skills.sh` for the pattern.

## Installation

End-user install instructions live in the root [`README.md`](README.md) — the
`npx skills add msobczyk-x/agent-skills` flow and the manual symlink paths for
Claude Code (`~/.claude/skills`), Codex (`~/.codex/skills`), and OpenCode
(`~/.config/opencode/skills`). Update that section when install steps change, and
add every new skill to the Skills table there.
