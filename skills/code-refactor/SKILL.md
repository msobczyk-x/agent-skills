---
name: code-refactor
description: Restructure JavaScript/TypeScript React and React Native code so each file has one responsibility — split nested components and large constant groups into their own files and apply the index.tsx parent-directory pattern. Use when asked to refactor, reorganize, split components/files, or extract constants.
---

# Code Refactor

Reorganize JS/TS React and React Native code so every file has **one clear
responsibility**, then apply light `code-simplify`-style cleanup. Public
behavior stays the same — same inputs, same outputs, same exported API; only
the file layout and imports change.

## Scope

- If the user names a target (a file, component, or directory), refactor that.
- Otherwise refactor what changed in the current diff (`git diff` +
  `git diff --cached`).

## Shared JS/TS rules

Apply to every `.ts`/`.tsx`/`.js`/`.jsx` file in scope:

1. **One responsibility per file.** A file exports one component, hook, or
   cohesive unit — not several unrelated ones.
2. **Extract nested/inline components.** A component defined inside another
   file (or inside another component's body) moves to its own file.
3. **Extract large constant groups.** When a file carries many constants,
   move them to a dedicated `constants.ts` beside the code that uses them.
4. **Use the `index.tsx` parent pattern.** Promote a growing component to a
   directory: the parent lives in `index.tsx`, and components used **only** by
   that parent live in per-domain subdirectories beside it. Components shared
   more widely move up to a shared location instead.
5. **Update every import/export** after moving code so nothing breaks.

## Platform rules

Detect the platform, then read the matching reference for its conventions
(styles, platform-specific files, directory shape):

- **React (web)** — `react-dom` in imports / `package.json` →
  [references/react.md](references/react.md)
- **React Native** — `react-native` in imports / `package.json` →
  [references/react-native.md](references/react-native.md)

## Light cleanup

After the structure settles, run the **`code-simplify`** skill over the touched
files (flatten nesting, cut duplication, reuse existing helpers). Do not
reimplement that work here — invoke the skill.

## Verify and report

- Run the project's tests / typecheck / linter where available, and report the
  result.
- **Report briefly**, per file: what moved where, and what the cleanup pass
  changed.
