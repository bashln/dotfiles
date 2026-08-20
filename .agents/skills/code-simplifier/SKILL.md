---
name: code-simplifier
description: Refatora e simplifica código mantendo comportamento.
---

## Objective

Reduce complexity while keeping observable behavior unchanged.

## When to use

- A module is overly complex or repetitive
- A refactor is needed without changing behavior
- The goal is readability, maintainability, or smaller surface area

## Scope

Does:

- Remove duplication
- Clarify flow and naming
- Preserve behavior

Does not:

- Change feature behavior
- Fix unrelated bugs
- Expand scope into architecture changes

## Workflow

1. Identify the smallest simplification that matters
2. Keep the behavior stable
3. Validate the affected area
4. Report the before and after shape
