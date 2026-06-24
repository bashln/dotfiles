---
name: domain-model
description: Grilling session that challenges your plan against the existing domain model, sharpens terminology, and updates documentation (CONTEXT.md, ADRs) inline as decisions crystallise. Use when user wants to stress-test a plan against their project's language and documented decisions.
disable-model-invocation: true
---

Interview me relentlessly about every aspect of this plan until we reach a shared understanding. Walk down each branch of the design tree, resolving dependencies between decisions one-by-one. For each question, provide your recommended answer.

Ask the questions one at a time, waiting for feedback on each question before continuing.

If a question can be answered by exploring the codebase, explore the codebase instead.

## Domain awareness

During codebase exploration, also look for existing documentation:

### File structure

Most repos have a single context:
```
/
├── CONTEXT.md
├── docs/
│   └── adr/
└── src/
```

If CONTEXT-MAP.md exists at root, the repo has multiple contexts.

### During the session

- When the user uses a term that conflicts with existing language in CONTEXT.md, call it out immediately
- When the user uses vague or overloaded terms, propose a precise canonical term
- When domain relationships are being discussed, stress-test them with specific scenarios
- When the user states how something works, check whether the code agrees
- When a term is resolved, update CONTEXT.md inline — don't batch
- Only offer ADRs when all three are true: hard to reverse, surprising without context, result of a real trade-off

Reference files: `CONTEXT-FORMAT.md`, `ADR-FORMAT.md`
