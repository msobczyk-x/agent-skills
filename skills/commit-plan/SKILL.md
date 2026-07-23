---
name: commit-plan
description: Propose how to split the current git diff into logical commits — a Conventional Commit message plus the files to stage for each. Analysis only; takes no action by default. Use when asked to plan commits, write a commit message, or group changes before committing. Supports excluding files or scoping to a directory.
---

# Commit Plan

Turn the **current changes** into a commit plan: group the diff into logical commits and,
for each, propose a Conventional Commit message and the exact files to stage.

**This is a planner, not a committer.** Do **not** run `git add`, `git commit`, `git reset`,
or any state-changing git command. Produce the proposal and stop. Only stage or commit if
the user explicitly asks in a follow-up.

## Instructions

1. **Never change git state.** By default take **no** action — no staging, no committing.
   Everything below is read-only inspection plus a written proposal.
2. **Determine the scope.** By default include all pending changes:
   - Staged: `git diff --cached --name-only`
   - Unstaged: `git diff --name-only`
   - Untracked: `git ls-files --others --exclude-standard`

   Then adjust per the user's request:
   - **Directory scope** — if the user named a directory, restrict every listing to that
     path: `git diff --name-only -- <dir>`, `git diff --cached --name-only -- <dir>`,
     `git ls-files --others --exclude-standard -- <dir>`.
   - **Exclusions** — if the user asked to exclude files, drop them from the set (support
     globs). List anything you excluded so the choice is visible.
   - If there are no changes in scope, say so and stop.
3. **Read the actual changes, not just the names.** Inspect `git diff` and
   `git diff --cached`, and read untracked files directly, so grouping and messages reflect
   real intent rather than filenames.
4. **Detect the repo's commit convention.** Sample recent history
   (`git log --oneline -20`) and follow whatever style it uses. Default to Conventional
   Commits (`type(scope): subject`) — the common types are `feat`, `fix`, `chore`, `docs`,
   `refactor`, `test`, `perf`, `build`, `ci`.
5. **Group into logical commits.** One group per cohesive, independently-committable change
   (e.g. a feature vs. an unrelated refactor vs. config). Keep related files together and
   separate unrelated concerns. Every in-scope file must land in exactly one group; flag any
   file whose placement is ambiguous.
6. **For each group, output these four parts, in order:**
   1. **Commit message (short form)** — the Conventional Commit subject line
      (`type(scope): subject`, imperative mood, ≤~72 chars).
   2. A copy-paste `git add <files>` command listing every file in this commit's scope.
      Present it as a command for the user to run themselves; do not execute it.
   3. **Explanation** — a plain-language note on why these files belong together and what
      the commit accomplishes.
   4. **Long form of commit message** — the full message (subject, blank line, then a body
      with bullets covering the *why*), ready to paste into `git commit`.
7. **Report.** Present the proposed commits as an ordered list, each with the four parts
   above. Close by stating explicitly that no changes were made, and invite the user to
   adjust the groupings, exclude more files, or ask you to proceed with staging/committing.
