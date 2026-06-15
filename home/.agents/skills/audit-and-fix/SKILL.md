---
name: audit-and-fix
description: Audita código buscando falhas e aplica correções adequadas.
---

## Audit Code


## Objective

Find correctness and security issues with a focus on real impact.

## When to use

- After implementation to catch bugs
- Before merge for security review
- When validating edge cases

## Scope

Does:

- Find logic bugs and regressions
- Review input validation and security risks
- Check edge cases and concurrency issues

Does not:

- Refactor for style
- Do architecture review

## Workflow

1. Read the diff or scope
2. Look for the highest-impact risks
3. Report severity and exact location
4. State clearly when nothing is found


## Apply Fixes


## Objective

Fix only the findings reported by audit, in severity order.

## When to use

- After `40-audit-code`
- Before another audit pass
- When the scope is a concrete list of findings

## Scope

Does:

- Apply targeted fixes
- Validate each fix

Does not:

- Search for unrelated new issues
- Redesign architecture
- Add new features outside the findings

## Workflow

1. Order findings by severity
2. Fix with the minimum patch
3. Validate each fix
4. Report resolved and pending items
