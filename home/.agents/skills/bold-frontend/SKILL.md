---
name: bold-frontend
description: Designs and implements bold, production-ready frontend interfaces with a clear aesthetic point of view. Use when the request involves UI, visual redesigns, React screens, landing pages, dashboards, component styling, or UX polish that should follow repo-specific UI requirements and existing design systems.
---

# Bold Frontend

## Quick start

1. Read [docs/ui/requirements.md](../../../docs/ui/requirements.md).
2. Inspect the existing UI code, styles, tokens, and reusable components before inventing new patterns.
3. Lock a direction before coding:
   - Purpose: what the screen needs to help the user do
   - Tone: pick one strong aesthetic and keep it consistent
   - Constraints: framework, accessibility, responsiveness, performance, build tooling
   - Differentiation: choose one memorable idea that makes the UI distinctive
4. Implement working production code, not just mockup styling.

## Non-negotiables

- Respect repo requirements and existing design systems before adding new patterns.
- Avoid generic AI-looking UI choices such as purple-on-white defaults, interchangeable cards, and default font stacks.
- Prefer characterful typography, clear color hierarchy, and purposeful motion.
- Keep the interface accessible, responsive, and shippable.
- Match implementation effort to the chosen visual direction.

## Frontend approach

- Typography: pair a distinctive display face with a readable body face; avoid Arial, Inter, Roboto, and plain system defaults unless the repo already mandates them.
- Color: define or extend a deliberate palette with tokens or CSS variables.
- Motion: use a few meaningful transitions or reveals that reinforce the chosen tone.
- Layout: use composition intentionally; asymmetry, density, overlap, or restraint should feel authored.
- Atmosphere: use gradients, texture, borders, transparency, shadow, or decorative detail only when they support the concept.

## Delivery checklist

- The direction is visually memorable and coherent.
- The UI works on desktop and mobile.
- Accessibility basics are covered: contrast, focus states, keyboard reachability, semantics.
- The result fits the codebase's architecture and styling conventions.
- The standout idea survives contact with real content and interaction states.
