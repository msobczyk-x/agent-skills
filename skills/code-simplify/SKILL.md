---
name: code-simplify
description: Simplify the code in the current diff without changing behavior — cut duplication and dead code, flatten nesting, reuse existing helpers, and improve readability. Use when asked to simplify, refactor for clarity, or tidy up recent changes.
---

# Code Simplify

Make the **current diff** simpler and clearer without changing what it does.

## Instructions

1. **Scope to the current diff.** Inspect `git diff` (unstaged) and
   `git diff --cached` (staged) and only refactor code that changed.
2. **Simplify, behavior-preserving:**
   - remove duplication and dead/unreachable code
   - flatten deep nesting (early returns, guard clauses)
   - collapse redundant intermediate variables and needless abstraction
   - prefer standard-library and existing project helpers over new code —
     search the codebase for an existing utility before writing one
3. **Do not over-engineer.** Keep the change minimal; do not add layers,
   options, or generality the diff doesn't need.
4. **Preserve behavior and public interfaces.** Same inputs → same outputs,
   same side effects, same exported signatures unless explicitly asked.
5. **Verify** after simplifying: run the project's tests / typecheck / linter
   where available, and report the result.
6. **Report briefly** what you simplified and why.
