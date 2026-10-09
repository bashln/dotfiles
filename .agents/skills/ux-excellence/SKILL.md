---
name: ux-excellence
description: Use when building, changing, or reviewing any user-facing surface — app, web UI, CLI, TUI, API, library, or docs — and when finishing any implementation, to raise usability, clarity, accessibility, and polish. Also for "make it feel great", "improve the UX", or "why is this clunky".
---

# UX Excellence

Core principle: pecar pela excelência. Target: a non-technical person uses the result with no tutorial and calls it beautiful. Improve UX on every implementation without waiting to be asked.

## First-run test

Simulate someone seeing it cold:

- Can they complete the main task with zero instructions?
- What does the first screen, the `--help`, and the empty state show?
- Where do they get stuck, and what message do they get?

If you cannot answer, the UX is not done.

## Universal checklist (every surface)

- **States:** empty, loading, partial, error, success. Design all five.
- **Defaults:** sensible, safe, least-surprising.
- **Feedback:** every action is acknowledged; anything over ~1s shows progress.
- **Errors:** what happened + why + how to fix. Never a bare stack trace or exit code.
- **Reversibility:** undo or confirm before destructive; prefer reversible.
- **Consistency:** naming, terminology, placement, shortcuts.
- **Accessibility:** contrast, focus, keyboard, labels, never color-only meaning.
- **Performance:** perceived speed — skeletons, optimistic UI, streaming.
- **Copy:** plain language, verbs; no jargon or error codes as the only text.

## CLI / TUI

- `--help` clear with examples; per-subcommand help.
- Consistent flags (short + long); `--dry-run` and confirmation before destructive actions.
- Machine-readable output (`--json`) alongside human output.
- Color with `NO_COLOR` / non-TTY fallback; aligned, scannable output.
- TUI: discoverable keybinds (`?`), visible state, resize-safe, mouse optional.
- Meaningful exit codes; spinner for long operations.

## Web / GUI

- Visual hierarchy, spacing scale, type scale, restrained palette.
- One clear primary action per screen; secondary de-emphasized.
- Responsive, keyboard-navigable, real focus rings.
- Microcopy next to the control it describes; validate inline.

## Finishing pass

Before "done": re-read as a first-time user, fix what hurt, and record what changed and why. Never trade correctness, security, data, or accessibility for looks.

REQUIRED BACKGROUND: `principle-experience-first`.
