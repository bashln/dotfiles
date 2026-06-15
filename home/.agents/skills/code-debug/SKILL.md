---
name: code-debug
description: Isola causa raiz de bugs, corrige e valida.
---

## Objective

Reproduce a concrete bug, isolate root cause, apply the smallest safe fix, and validate it.

## When to use

- A test or command is failing
- There is a runtime error or stack trace
- A regression appeared after a recent change
- A multi-file bug does not have an obvious cause

## Scope

Does:

- Reproduce the symptom
- Identify root cause with evidence
- Apply a minimal fix
- Revalidate the affected command or test

Does not:

- Add a new feature
- Simplify code without a concrete failure
- Do broad auditing
- Do architecture review

## Workflow

1. Reproduce the symptom
2. Isolate the smallest failing area
3. Form a root-cause hypothesis with evidence
4. Apply the minimal fix
5. Revalidate
