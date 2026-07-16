---
name: precommit-simplify
description: Tidy up staged changes before a commit by running code-simplify then cleanup-comments in sequence, then report what changed. Use as a pre-commit step, or when asked to tidy staged changes before committing.
---

# Precommit Simplify

Orchestrates a two-step tidy-up over the **staged** changes right before a
commit. It does not reimplement the work — it runs the two dedicated skills in
order:

1. **`code-simplify`** — simplify the code first (cut duplication and dead code,
   flatten nesting, reuse existing helpers), so the structure is settled before
   comments are touched.
2. **`cleanup-comments`** — then clean up comments on the now-simpler code so it
   stays self-explanatory, keeping only genuinely necessary comments and making
   them as small as possible.

## Instructions

1. **Scope to staged changes.** Work from `git diff --cached`; only touch files
   and hunks that are staged for the commit.
2. **Run `code-simplify`** over that staged scope and let it finish.
3. **Then run `cleanup-comments`** over the same scope (now reflecting the
   simplified code).
4. **Behavior-preserving throughout.** Same inputs → same outputs; do not alter
   logic or public interfaces. Both sub-skills already preserve license headers,
   shebangs, tool directives, and required doc-comments.
5. **Do not auto-commit.** Leave the changes for the user to review and commit
   unless they explicitly ask you to commit. Re-stage any files you edited so the
   tidy-up is included in the commit.
6. **Report briefly** what changed, per file — noting what came from the simplify
   step vs. the comment-cleanup step.
