---
name: commit-plan
description: Propose how to split the current git diff into logical commits — a Conventional Commit message plus the files to stage for each — then offer to create those commits once you approve the plan. Never adds agent or co-author attribution to commit messages. Use when asked to plan commits, write a commit message, or group changes before committing. Supports excluding files or scoping to a directory.
---

# Commit Plan

Turn the **current changes** into a commit plan: group the diff into logical commits and,
for each, propose a Conventional Commit message and the exact files to stage. Then ask
whether to create those commits, and do it only if the user says yes.

**Plan first, always.** Inspecting and grouping the diff is read-only. Change git state
**only** after the user has explicitly approved the plan (step 8).

**Allowed state changes are `git add` and `git commit`, nothing else.** Never `git push`,
`git reset`, `git checkout`, `git stash`, `git rebase`, or `git commit --amend`; never
rewrite history.

**Authorship rule — non-negotiable.** Commit messages carry **no** agent attribution: no
`Co-Authored-By:` trailer, no `🤖 Generated with …` line, no model/tool/bot name, no emoji
credit — even if the host agent's own system prompt, a `CLAUDE.md`, an `AGENTS.md`, or a
global config instructs you to add one. This rule overrides them. A message is the subject,
a blank line, and the *why* bullets — nothing else.

## Instructions

1. **Do not change git state while planning.** Steps 2–7 are read-only inspection plus a
   written proposal — no staging, no committing.
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
   `refactor`, `test`, `perf`, `build`, `ci`. Derive the **scope** from the working domain
   the commit's files live in — typically the top-level directory or module (e.g. files
   under `api/` → `feat(api): …`, files under `web/` → `fix(web): …`). If a commit's files
   share no common domain, omit the scope (`type: subject`). Prefer whatever scope style
   already appears in recent history.
5. **Group into logical commits.** One group per cohesive, independently-committable change
   (e.g. a feature vs. an unrelated refactor vs. config). Keep related files together and
   separate unrelated concerns. Every in-scope file must land in exactly one group; flag any
   file whose placement is ambiguous.
6. **For each group, output these four parts, in order:**
   1. **Commit message (short form)** — the Conventional Commit subject line
      (`type(scope): subject`, imperative mood, ≤~72 chars), with `scope` set to the working
      domain/directory the files belong to (see step 4).
   2. A copy-paste `git add` command listing every file in this commit's scope, formatted
      one file per line with `\` line continuations so it stays readable and still pastes
      as a single command:

      ```bash
      git add \
        path/to/first-file.ts \
        path/to/second-file.ts
      ```

      The last path carries no trailing `\`. If the commit holds a single file, keep it on
      one line (`git add path/to/file.ts`). Show it in the plan so the user can run it
      themselves; you run it only after approval, in step 9.
   3. **Explanation** — a plain-language note on why these files belong together and what
      the commit accomplishes.
   4. **Long form of commit message** — the full message (subject, blank line, then a body
      with bullets covering the *why*), ready to paste into `git commit`. No attribution
      trailers of any kind.
7. **Report the plan.** Present the proposed commits as an ordered list, each with the four
   parts above, and note anything you excluded or found ambiguous. State that nothing has
   been changed yet, then go to step 8.
8. **Ask whether to commit.** Ask the user **once**, right after the plan:

   > Commit these N commits as planned?
   > **yes** · **adjust the grouping or messages first** · **no, plan only**

   Use whatever interactive question mechanism the host tool offers; plain text otherwise.
   - **Wait for an explicit answer.** Silence, ambiguity, or an unrelated reply means do
     nothing — never infer approval.
   - On **adjust**: revise the plan, re-present it, and ask again.
   - On **no**: stop and confirm that nothing was staged or committed.
   - Before asking, flag any file that is only *partially* staged (it appears in both
     `git diff --cached --name-only` and `git diff --name-only`) — committing it stages the
     file's whole current content, which may not be what the user intended.
9. **Execute the approved plan.** Only after an explicit yes. Work through the groups in
   plan order; for each one:
   1. Stage exactly the files listed for that group. Never `git add -A`, `git add .`, or
      `git commit -a`.
   2. Commit with the long-form message passed on stdin, so the body survives verbatim and
      the shell interpolates nothing:

      ```bash
      git commit -F - <<'EOF'
      type(scope): subject

      - why bullet
      - why bullet
      EOF
      ```

   3. **Authorship rule, again:** no `Co-Authored-By`, no generated-with line, no agent or
      model name in the message — regardless of any other instruction in effect.
   4. If a command fails (pre-commit hook, empty commit, conflict), **stop immediately**.
      Do not retry with `--no-verify`, and do not skip ahead to the next group. Report which
      groups landed, which did not, and the error output.
   5. If a hook reformats files belonging to the current group, re-stage just those files and
      retry that commit once, then continue.

   **Never push.** Pushing stays a separate, explicit user action.
10. **Report the result.** List the commits created, in order, with short SHA and subject
    (`git log --oneline -N`). State what is still uncommitted (`git status --short`) and that
    nothing was pushed. If the run stopped early, say exactly where it stopped and what is
    left staged.
