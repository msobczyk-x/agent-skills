---
name: pragmatic-review
description: Review the current branch's changes like a senior engineer, judging them against DRY, YAGNI, SOLID, and Pragmatic Programmer principles and emitting a severity-ranked findings report without editing code. For React/React Native diffs it also delegates to the Vercel React skills to catch bugs. Use when asked to review code, do a code review, or critique recent changes.
---

# Pragmatic Review

Review the **current branch's changes** the way a senior engineer would: judge
them against DRY, YAGNI, SOLID, and the Pragmatic Programmer principles, and
report what you find. This is a **reviewer, not a fixer** — produce findings,
do **not** edit code.

## Scope

Review what changed on this branch:

- `git diff` (unstaged) and `git diff --cached` (staged)
- commits on the branch vs `main`: `git diff main...HEAD`

Read each **changed file in full** for context — don't judge a hunk in
isolation.

## Review workflow

Copy this checklist and work through it:

```
Review Progress:
- [ ] 1. Gather the branch diff (commands above)
- [ ] 2. Read each changed file for full context
- [ ] 3. Evaluate against the principles (references/principles.md)
- [ ] 4. If React/React Native: run the companion skills (see below)
- [ ] 5. Rank findings by severity and write the report
```

## Principles

Evaluate every change against these, using the review checklist in
[references/principles.md](references/principles.md):

- **DRY** — no duplicated logic or knowledge.
- **YAGNI** — no speculative generality or dead code.
- **SOLID** — single responsibility, open/closed, Liskov, interface
  segregation, dependency inversion.
- **Pragmatic Programmer** — orthogonality, "easier to change", no broken
  windows, design by contract, fail fast, avoid global state.

## React / React Native delegation

If the diff touches React or React Native (look for `react`, `react-native`, or
`next` in imports or `package.json`), also run the companion Vercel skills to
catch bugs and performance/architecture issues:

- `vercel-react-best-practices` — React/Next.js correctness & performance
- `vercel-react-native-skills` — React Native/Expo (used only for RN diffs)
- `vercel-composition-patterns` — component API & composition architecture

**If any are not installed:** ask the user whether to install them. On approval,
run `scripts/install-react-skills.sh` (installs them globally via `npx skills`),
then continue. If the user declines, note it in the report and fall back to your
own React judgment — do not fail the review.

Fold each companion skill's findings into the report below.

## Severity

- **HIGH** — bugs, correctness, security, data loss, race conditions.
- **MEDIUM** — principle violations that will hurt maintainability.
- **LOW** — readability, naming, style nits.

## Report format

Group findings severity-high-first. For each:

```
[SEVERITY] path/to/file.ts:42 — <principle or category>
Problem: <what's wrong, specifically>
Why it matters: <the concrete consequence>
Suggest: <a concrete fix>
```

End with a short **Overall assessment** (2–3 sentences) and, if React/RN was in
scope, note which companion skills ran (or why they didn't).

## Reviewer guidance

- Focus on material issues; skip nitpicks that don't change outcomes.
- Cite the **specific** principle a finding violates.
- Be concrete and actionable — point to the line and the fix.
- Do not edit code. Reviewer output only.
