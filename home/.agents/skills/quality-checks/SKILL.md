---
name: quality-checks
description: Verifica linting e valida tipagem TypeScript.
---

## Linting


## Objective

Run the repository lint command and report errors and warnings with reproducible commands.

## When to use

- Before commit or merge
- When validating larger changes
- When diagnosing lint-related CI failures

## Scope

Does:

- Detect the repository lint command
- Run the most specific command possible
- Separate errors from warnings

Does not:

- Create features or refactors
- Hunt bugs or security issues

## Workflow

1. Detect the lint command
2. Run it
3. Classify the result
4. Report affected files and how to reproduce


## TypeScript Validation


## Objective

Run type checking and report type coverage gaps that increase runtime risk.

## When to use

- Before merge or release in a TypeScript repo
- After JS to TS migrations
- When `any` or `unknown` is used without guards

## Scope

Does:

- Detect the repository typecheck command
- Run the verification
- Prioritize type errors by impact

Does not:

- Implement large corrective changes
- Do broad functional audits

## Workflow

1. Detect the typecheck command
2. Run it
3. Prioritize errors
4. Report how to reproduce and fix
