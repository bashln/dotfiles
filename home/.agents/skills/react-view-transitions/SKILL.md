---
name: vercel-react-view-transitions
description: Guide for implementing smooth, native-feeling animations using React's View Transition API. Use when the user wants page transitions, route animations, shared element animations, enter/exit animations, or Next.js view transitions.
---

# React View Transitions

Animate between UI states using the browser's native `document.startViewTransition`. Declare *what* with `<ViewTransition>`, trigger *when* with `startTransition` / `useDeferredValue` / `Suspense`, control *how* with CSS classes.

## When to Animate

Every transition should communicate a spatial relationship or continuity. Implement all applicable patterns in this order:

| Priority | Pattern | What it communicates |
|----------|---------|---------------------|
| 1 | Shared element (`name`) | "Same thing — going deeper" |
| 2 | Suspense reveal | "Data loaded" |
| 3 | List identity (per-item `key`) | "Same items, new arrangement" |
| 4 | State change (`enter`/`exit`) | "Something appeared/disappeared" |
| 5 | Route change (layout-level) | "Going to a new place" |

## Implementation Workflow

Follow `references/implementation.md` step by step. Start with the audit. Copy CSS from `references/css-recipes.md`.

## Reference Files

- `references/implementation.md` — Step-by-step workflow
- `references/patterns.md` — Real-world patterns, events, troubleshooting
- `references/css-recipes.md` — Ready-to-use CSS animation recipes
- `references/nextjs.md` — Next.js App Router patterns

## Full Compiled Document

For the complete guide: `AGENTS.md`
