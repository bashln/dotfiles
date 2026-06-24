---
name: audit-and-fix
description: Audita código buscando falhas e aplica correções adequadas.
---

## Objective

Find correctness and security issues, then apply targeted fixes in severity order.

## When to use

- After implementation to catch bugs
- Before merge for security review
- When validating edge cases
- After audit findings are reported

## Scope

Does:
- Find logic bugs and regressions
- Review input validation and security risks
- Check edge cases and concurrency issues
- Apply targeted fixes from audit findings
- Validate each fix

Does not:
- Refactor for style
- Do architecture review
- Search for unrelated new issues
- Add new features outside the findings

## Workflow

1. Read the diff or scope
2. Look for the highest-impact risks first
3. Report severity and exact location
4. State clearly when nothing is found
5. Fix findings in severity order
6. Validate each fix
7. Report resolved and pending items
