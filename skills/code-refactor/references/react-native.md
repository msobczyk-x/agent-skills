# React Native refactoring rules

React Native-specific conventions for the `code-refactor` skill. Apply these on
top of the shared JS/TS rules in `SKILL.md`.

## Contents

- File extensions and naming
- The `index.tsx` directory pattern
- Splitting nested components
- Extracting constants
- Extracting styles (`StyleSheet`)
- Platform-specific files
- Screens vs. components

## File extensions and naming

- Components and screens: `.tsx`. One component per file.
- Name the file after its default export: `ProfileScreen.tsx` exports
  `ProfileScreen`.
- Non-component modules stay `.ts`: `constants.ts`, `types.ts`, `styles.ts`.

## The `index.tsx` directory pattern

When a screen or component grows private helpers, promote it to a directory.
The parent is `index.tsx`; children used only by it live in a per-domain
subdirectory beside it.

```
ProfileScreen/
├── index.tsx          # parent screen
├── styles.ts          # StyleSheet for the screen
├── constants.ts       # constants used across this screen
├── ProfileHeader/     # domain: used only by ProfileScreen
│   ├── index.tsx
│   └── styles.ts
└── ProfileStats/      # domain: used only by ProfileScreen
    ├── index.tsx
    └── styles.ts
```

A component reused across screens does **not** belong here — move it to a shared
`components/` location instead.

## Splitting nested components

Any component declared inside another file — or inside another component's body
— moves to its own file and is imported back. Inline render callbacks that grow
into real components (e.g. a `renderItem` for a `FlatList`) become their own
component file.

## Extracting constants

Move large or shared constant groups into `constants.ts` beside the component
that uses them, and import them back. Keep a lone one-off constant inline.

## Extracting styles (`StyleSheet`)

Move `StyleSheet.create({...})` blocks out of the component file into a
co-located `styles.ts`, and import the styles back.

```tsx
// styles.ts
import { StyleSheet } from "react-native";
export const styles = StyleSheet.create({ container: { flex: 1 } });

// index.tsx
import { styles } from "./styles";
```

## Platform-specific files

When a component needs different iOS and Android implementations, split by
platform suffix instead of branching on `Platform.OS` throughout one file:

```
Button.ios.tsx
Button.android.tsx
Button.tsx        # shared fallback / types (optional)
```

The Metro bundler picks the right file per platform automatically.

## Screens vs. components

- **Screens** (navigator targets) live under `screens/`, each as its own
  `index.tsx` directory when it has private children.
- **Reusable components** shared across screens live under `components/`.
