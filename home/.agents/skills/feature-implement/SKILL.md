---
name: feature-implement
description: Implementa features e melhorias funcionais.
---

## Objective

Deliver the smallest useful implementation for a clearly defined feature or improvement.

## When to use

- New feature with defined scope
- Functional improvement with low or medium impact
- Targeted bug fix without a formal audit report

## Scope

Does:

- Implement the requested functionality
- Make the smallest complete change
- Validate the result proportionally to risk

Does not:

- Handle audit follow-up findings
- Do deep debugging of an intermittent bug
- Do broad structural mapping

## Workflow

1. Read the request and local patterns
2. Implement the smallest complete slice
3. Avoid parallel refactors outside scope
4. Run objective validation
5. Report what changed, why, and how to test
