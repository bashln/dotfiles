---
name: quality-checks
description: Verifica linting e valida tipagem TypeScript.
---

## Objective

Run linting and type checking, report errors/warnings with reproducible commands.

## Use for

- Before commit or merge
- When validating larger changes
- When diagnosing lint-related or type-related CI failures
- After JS to TS migrations
- When `any` or `unknown` is used without guards

## Does

- Detect the repository lint and typecheck commands
- Run the most specific command possible
- Separate errors from warnings
- Prioritize type errors by impact

## Does not

- Create features or refactors
- Hunt bugs or security issues
- Implement large corrective changes

## Workflow

1. Detect the lint and typecheck commands
2. Run lint first, then typecheck
3. Classify results (errors vs warnings, type errors by impact)
4. Report affected files and how to reproduce/fix
