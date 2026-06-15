---
name: architecture-guard
description: Detecta violações de arquitetura e invariantes de código.
---

## Objective

Detect architectural violations and broken invariants with objective evidence.

## When to use

- Before merging structural changes
- After refactors that affect multiple layers
- When dependency or boundary violations are suspected

## Scope

Does:

- Review architecture and invariants
- Point to violations with location and severity

Does not:

- Fix code
- Do broad functional auditing

## Workflow

1. Read the relevant architecture rules
2. Inspect the changed scope
3. Report violations with evidence
4. List preserved and broken invariants
