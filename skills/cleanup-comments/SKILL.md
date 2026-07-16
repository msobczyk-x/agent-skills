---
name: cleanup-comments
description: Remove noise comments from the files in the current diff so the code stays self-explanatory. Use when asked to clean up comments in the current changes, or before committing or reviewing a diff.
---

# Cleanup Comments

Clean up comments in the **current diff only**, so the code speaks for itself.
The default is *fewer, smaller* comments.

## Instructions

1. **Scope to the current diff.** Inspect `git diff` (unstaged) and
   `git diff --cached` (staged) and operate only on the files and hunks that
   changed.
2. **Remove comments that are pure noise:**
   - restatements of what the code plainly does (e.g. `// increment i by 1`)
   - commented-out / dead code
   - decorative banners, dividers, and section-art
   - redundant boilerplate docstrings that just echo the signature
3. **Keep only what is genuinely needed** — a non-obvious *why*: a workaround,
   an invariant, a gotcha, a security/perf caveat, or a TODO that references a
   ticket. When you keep one, make it **as small as possible**: prefer a single
   terse line and redact any verbosity. Done only when every changed hunk's
   comments are accounted for — each one either removed as noise or kept for a
   stated *why*.
4. **Comments only — never change behavior.** Do not edit logic, names, or
   control flow.
5. **Preserve** the things that look like comments but aren't disposable:
   license/copyright headers, shebangs, tool directives (`eslint-disable`,
   `# type: ignore`, `# noqa`, `#pragma`, `//go:` directives), and doc-comments
   required by a public API or by doc tooling.
6. **Report briefly** which files were trimmed and roughly what was removed.
