---
name: precommit-simplify
description: Tidy up staged changes before a commit by running code-simplify then cleanup-comments in sequence. Use as a pre-commit step, or when asked to tidy staged changes before committing.
---

# Precommit Simplify

Orchestrates a two-step tidy-up over the **staged** changes right before a
commit. It does not reimplement the work — it runs the two dedicated skills in
order.

## Instructions

1. **Scope to staged changes.** Work from `git diff --cached`; only touch files
   and hunks that are staged for the commit.
2. **Run `code-simplify`** over that staged scope and let it finish, so the
   structure is settled before comments are touched.
3. **Then run `cleanup-comments`** over the same scope (now reflecting the
   simplified code).
4. **Do not auto-commit.** Leave the changes for the user to review and commit
   unless they explicitly ask you to commit. Re-stage any files you edited so the
   tidy-up is included in the commit.
5. **Report briefly** what changed, per file — noting what came from the simplify
   step vs. the comment-cleanup step.
