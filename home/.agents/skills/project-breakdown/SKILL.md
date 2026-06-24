---
name: project-breakdown
description: Transforma contexto atual em PRD e quebra em issues menores.
---

## To PRD

Synthesize current conversation context into a PRD GitHub issue. Do NOT interview the user.

### Process

1. Explore repo to understand current state
2. Sketch major modules, look for deep module extraction opportunities
3. Write PRD using template below and submit as GitHub issue

**Template:**
```
## Problem Statement

## Solution

## User Stories
As an <actor>, I want <feature>, so that <benefit>

## Implementation Decisions
Modules, interfaces, architectural decisions, API contracts, schema changes. Do NOT include file paths or code snippets.

## Testing Decisions
What makes a good test, which modules tested, prior art.

## Out of Scope

## Further Notes
```

## To Issues

Break a plan into independently-grabbable GitHub issues using vertical slices.

### Process

1. **Gather context** from conversation or `gh issue view <number>`
2. **Explore codebase** if not already done
3. **Draft vertical slices** — each is a thin end-to-end slice through all integration layers. Prefer AFK over HITL where possible.
   - Each slice delivers a complete path (schema, API, UI, tests)
   - Completed slice is demoable on its own
   - Prefer many thin slices over few thick ones
4. **Quiz the user** — present numbered list with title, type (HITL/AFK), blocked by, user stories. Iterate on granularity and dependencies.
5. **Create GitHub issues** using `gh issue create` in dependency order.

**Issue template:**
```
## Parent
#<parent-number>

## What to build
Concise description of this vertical slice (end-to-end behavior).

## Acceptance criteria
- [ ] Criterion 1

## Blocked by
- #<number> or "None - can start immediately"
```
