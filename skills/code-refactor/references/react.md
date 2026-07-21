# React (web) refactoring rules

Web-specific conventions for the `code-refactor` skill. Apply these on top of
the shared JS/TS rules in `SKILL.md`.

## Contents

- File extensions and naming
- The `index.tsx` directory pattern
- Splitting nested components
- Extracting constants
- Co-locating styles
- Custom hooks

## File extensions and naming

- Components: `.tsx` (or `.jsx` in a JS project). One component per file.
- Name the file after its default export: `UserCard.tsx` exports `UserCard`.
- Non-component modules stay `.ts`: `constants.ts`, `types.ts`, `utils.ts`.

## The `index.tsx` directory pattern

When a component grows its own private helpers, promote it to a directory. The
parent is `index.tsx`; children used only by it live in a per-domain
subdirectory beside it.

```
UserProfile/
├── index.tsx          # parent component
├── constants.ts       # constants used across this component
├── types.ts           # local types (optional)
├── ProfileHeader/     # domain: used only by UserProfile
│   ├── index.tsx
│   └── Avatar.tsx
└── ProfileStats/      # domain: used only by UserProfile
    ├── index.tsx
    └── StatTile.tsx
```

A component reused outside `UserProfile` does **not** belong here — move it to a
shared `components/` location instead.

## Splitting nested components

Any component declared inside another file — or inside another component's body
— moves to its own file and is imported back.

```tsx
// Before: nested inside UserProfile/index.tsx
function UserProfile() {
  const Row = ({ label }) => <div className="row">{label}</div>; // extract this
  return <Row label="name" />;
}

// After: UserProfile/Row.tsx exports Row; index.tsx imports it.
```

## Extracting constants

Move large or shared constant groups into `constants.ts` beside the component
that uses them, and import them back. Keep a lone one-off constant inline.

## Co-locating styles

Keep styles next to the component. Match whatever the project already uses:

- CSS Modules → `UserCard.module.css` beside `UserCard.tsx`.
- styled-components / Emotion → `UserCard.styles.ts` beside the component.

Do not switch styling approaches — follow the existing convention.

## Custom hooks

A hook (`useSomething`) lives in its own file — `useUserData.ts` for a shared
hook, or inside the component's directory when it is used only there.
