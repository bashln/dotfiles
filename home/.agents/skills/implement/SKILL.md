---
name: implement
description: Implementa a menor mudanca correta para entregar uma feature, melhoria ou refatoracao local. Use quando o escopo ja estiver claro e o objetivo principal for mudar o codigo sem abrir investigacoes paralelas nem expandir o trabalho.
---

## Objective

Deliver the smallest correct change for a defined scope.

## Use for

- New features with clear acceptance criteria
- Targeted improvements
- Small refactors that preserve behavior
- Applying concrete follow-up changes from prior analysis or review

## Does

- Implement the requested change
- Keep scope tight
- Preserve existing patterns unless there is a concrete reason not to
- Run proportionate validation

## Does not

- Investigate a vague or intermittent failure from scratch
- Perform broad repo analysis
- Act as final quality gate
- Lead architecture review

## Workflow

1. Confirm the scope and local patterns
2. Identify the smallest complete slice
3. Implement without parallel cleanup unless it directly helps
4. Validate the affected behavior
5. Report what changed, why, and how to verify it
