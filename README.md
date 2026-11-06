# agent-skills

A small collection of portable coding-agent skills. Each skill is a directory
containing a `SKILL.md` that follows the [Agent Skills](https://agentskills.io)
open standard, so the **same** files work across Claude Code, OpenAI Codex, and
OpenCode with no per-tool duplication.

## Skills

| Skill | What it does |
|-------|--------------|
| [`cleanup-comments`](skills/cleanup-comments/) | Trim noisy/redundant comments in the current diff so the code stays self-explanatory. |
| [`code-simplify`](skills/code-simplify/) | Simplify the code in the current diff without changing behavior. |
| [`code-refactor`](skills/code-refactor/) | Restructure JS/TS React & React Native code to one responsibility per file (split components/constants, `index.tsx` pattern). |
| [`precommit-simplify`](skills/precommit-simplify/) | Runs `code-simplify` then `cleanup-comments` over staged changes before a commit. |
| [`pragmatic-review`](skills/pragmatic-review/) | Senior-engineer code review of the branch diff against DRY/YAGNI/SOLID/Pragmatic Programmer; delegates to Vercel React skills for React/RN. |
| [`commit-plan`](skills/commit-plan/) | Propose logical commits from the current diff — a Conventional Commit message + the files to stage for each — then create them on your confirmation. No pushes, no agent attribution in messages. |
| [`security-harden`](skills/security-harden/) | Scan a repo's security measures (CI/CD, secrets, containers, dependency updates, governance) against a current baseline, report gaps, and apply confirmed fixes; delegates to the language subskills below. |
| [`security-harden-js`](skills/security-harden-js/) | JS/TS supply-chain hardening (pnpm/npm/yarn/bun) plus Node API and web-app security checks. |
| [`security-harden-python`](skills/security-harden-python/) | Python supply-chain hardening (uv/pip/poetry): locked installs, pip-audit, Bandit, Semgrep. |
| [`security-harden-go`](skills/security-harden-go/) | Go supply-chain hardening: `go mod verify`, read-only builds, govulncheck, gosec. |
| [`security-harden-jvm`](skills/security-harden-jvm/) | Java/Kotlin hardening: Gradle locking + verification metadata / Maven enforcer, Dependency-Check. |
| [`security-harden-rust`](skills/security-harden-rust/) | Rust hardening: `--locked` builds, cargo-deny, cargo-audit, clippy. |

## Install

### With `npx skills` (recommended)

[`skills.sh`](https://www.skills.sh) is a package manager for agent skills
([vercel-labs/skills](https://github.com/vercel-labs/skills)). It detects your
installed agents and wires the skills up for you — no manual symlinking.

```bash
# Install every skill in this repo, straight from GitHub
npx skills add msobczyk-x/agent-skills

# Or a single skill
npx skills add msobczyk-x/agent-skills --skill cleanup-comments

# From a local clone
npx skills add ./agent-skills
```

Useful flags: `-a, --agent claude-code,codex,opencode` to target specific agents,
`-g, --global` to install into your user directory instead of the current project,
`--copy` to copy files instead of symlinking. Manage them with `npx skills list`,
`npx skills update`, and `npx skills remove`.

### Manual (symlink)

Each tool reads skills from its own path. Symlink a skill directory into each one
so a single source stays in sync (replace `<skill>` with the directory name):

```bash
ln -s "$PWD/skills/<skill>"  ~/.claude/skills/<skill>            # Claude Code
ln -s "$PWD/skills/<skill>"  ~/.codex/skills/<skill>             # Codex
ln -s "$PWD/skills/<skill>"  ~/.config/opencode/skills/<skill>   # OpenCode
```

OpenCode also reads `~/.claude/skills`, so the first symlink covers both Claude Code
and OpenCode; only Codex needs its own. Project-scoped installs work the same way
under `.claude/skills/`, `.codex/skills/`, and `.opencode/skills/`.

Invoke a skill with `/<skill>` in the tool, or let the agent auto-load it based on
its `description`.

## Skill format

Every `SKILL.md` uses only the two fields all three tools validate:

- `name` — kebab-case, matches the directory name, ≤64 chars.
- `description` — states **what** the skill does and **when** to use it.
