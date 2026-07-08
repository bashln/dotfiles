---
name: frontend
description: Projeta e implementa interfaces frontend arrojadas, otimiza performance React/Next.js, implementa animações com View Transition API, audita conformidade com diretrizes web. Use when working on UI, React/Next.js performance, view transitions, accessibility, or web design compliance.
---

# Frontend

Unified skill for frontend design, React/Next.js performance optimization, view transitions, and web design guidelines. Use the mode that fits your task.

## Modes

| Mode | What it does | When to use |
|---|---|---|
| `design` | Build bold, production-ready UI with clear aesthetic point of view | Visual redesigns, React screens, landing pages, dashboards, UX polish |
| `performance` | Optimize React/Next.js code (69 rules across 8 priority categories) | Writing React components, implementing data fetching, reviewing for performance |
| `animations` | Implement smooth View Transition API animations | Page transitions, route animations, shared element animations, enter/exit animations |
| `guidelines` | Review UI code against Web Interface Guidelines | Accessibility audit, design review, UX compliance check |

---

## Mode: design

### Quick start

1. Read existing UI requirements and design tokens before inventing
2. Inspect existing UI code, styles, tokens, reusable components
3. Lock a direction before coding: purpose, tone, constraints, differentiation
4. Implement working production code, not mockup styling

### Non-negotiables

- Respect repo requirements and existing design systems
- Avoid generic AI-looking UI (purple-on-white defaults, interchangeable cards, default fonts)
- Prefer characterful typography, clear color hierarchy, purposeful motion
- Keep interface accessible, responsive, shippable

### Frontend approach

- **Typography**: pair distinctive display face with readable body face; avoid Arial, Inter, Roboto, system defaults unless mandated
- **Color**: define/extend deliberate palette with tokens or CSS variables
- **Motion**: few meaningful transitions that reinforce the tone
- **Layout**: intentional composition — asymmetry, density, overlap, restraint
- **Atmosphere**: gradients, texture, borders, transparency, shadow only when supporting concept

### Delivery checklist

- Visually memorable and coherent
- Works on desktop and mobile
- Accessibility basics: contrast, focus states, keyboard reachability, semantics
- Fits codebase architecture and styling conventions
- Standout idea survives contact with real content

---

## Mode: performance

React and Next.js performance optimization. 69 rules across 8 priority categories.

### Priority Categories

| Priority | Category | Impact |
|---|---|---|
| 1 | Eliminating Waterfalls | CRITICAL |
| 2 | Bundle Size Optimization | CRITICAL |
| 3 | Server-Side Performance | HIGH |
| 4 | Client-Side Data Fetching | MEDIUM-HIGH |
| 5 | Re-render Optimization | MEDIUM |
| 6 | Rendering Performance | MEDIUM |
| 7 | JavaScript Performance | LOW-MEDIUM |
| 8 | Advanced Patterns | LOW |

### How to use

Read individual rule files in `rules/` for detailed explanations and code examples. Each rule file contains explanation, incorrect example, correct example, and context.

See [AGENTS.md](AGENTS.md) for the complete compiled guide with all rules expanded.

---

## Mode: animations

Animate between UI states using the browser's native `document.startViewTransition`. Declare *what* with `<ViewTransition>`, trigger *when* with `startTransition` / `useDeferredValue` / `Suspense`, control *how* with CSS classes.

### When to animate

| Priority | Pattern | What it communicates |
|---|---|---|
| 1 | Shared element (`name`) | "Same thing — going deeper" |
| 2 | Suspense reveal | "Data loaded" |
| 3 | List identity (per-item `key`) | "Same items, new arrangement" |
| 4 | State change (`enter`/`exit`) | "Something appeared/disappeared" |
| 5 | Route change (layout-level) | "Going to a new place" |

### Implementation

Follow `references/implementation.md` step by step, starting with audit. Copy CSS from `references/css-recipes.md`.

### Reference files

- `references/implementation.md` — step-by-step workflow
- `references/patterns.md` — real-world patterns, events, troubleshooting
- `references/css-recipes.md` — ready-to-use CSS animation recipes
- `references/nextjs.md` — Next.js App Router patterns

---

## Mode: guidelines

Review files for compliance with Web Interface Guidelines.

### How it works

1. Fetch latest guidelines from: https://raw.githubusercontent.com/vercel-labs/web-interface-guidelines/main/command.md
2. Read specified files (or prompt user for files/pattern)
3. Check against all rules in fetched guidelines
4. Output findings in `file:line` format
