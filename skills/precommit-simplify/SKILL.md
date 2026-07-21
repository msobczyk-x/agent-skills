---
name: precommit-simplify
description: Tidy up changes before a commit by running code-simplify then cleanup-comments in sequence. Works on staged, uncommitted, or all changes. Use as a pre-commit step, or when asked to tidy changes before committing.
---

# Precommit Simplify

Orchestrates a two-step tidy-up over the changes right before a commit. It does
not reimplement the work — it runs the two dedicated skills in order.

## Instructions

1. **Determine the scope.** Check what changes exist:
   - Staged changes: `git diff --cached --name-only`
   - Uncommitted (unstaged) changes: `git diff --name-only`

   Then pick the scope:
   - If **only staged** changes exist, use the staged scope.
   - If **only uncommitted** changes exist, use the uncommitted scope.
   - If **both** are present, ask the user which scope to use — `all`, `staged`,
     or `uncommitted` — and wait for their answer before proceeding.
2. **Run `code-simplify`** over the chosen scope and let it finish, so the
   structure is settled before comments are touched.
3. **Then run `cleanup-comments`** over the same scope (now reflecting the
   simplified code).
4. **Do not auto-commit.** Leave the changes for the user to review and commit
   unless they explicitly ask you to commit. If the original scope included
   staged files, re-stage any staged files you edited so the tidy-up is included
   in the commit.
5. **Report briefly** what changed, per file — noting what came from the simplify
   step vs. the comment-cleanup step.
