---
name: debug
description: Reproduz uma falha concreta, encontra a causa raiz, aplica a menor correcao segura e valida o resultado. Use quando houver erro, teste quebrando, regressao, stack trace ou comportamento incorreto observavel.
---

## Objective

Reproduce the failure, isolate the root cause, fix it minimally, and revalidate.

## Use for

- Failing tests or commands
- Runtime errors and stack traces
- Regressions after recent changes
- Incorrect behavior with a concrete symptom

## Does

- Reproduce the symptom
- Narrow the failing surface area
- Form and verify a root-cause hypothesis
- Apply the smallest safe fix
- Re-run the relevant validation

## Does not

- Implement unrelated features
- Expand into broad audits
- Run architecture review

## Workflow

1. Reproduce the issue
2. Isolate the smallest failing path
3. Identify the root cause with evidence
4. Fix only what the root cause requires
5. Revalidate the affected path
