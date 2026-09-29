---
name: analyze
description: Analisa o repositório, o contexto atual e define o próximo passo mais seguro. Use quando faltar contexto, o pedido estiver vago, houver múltiplas direções possíveis, ou for preciso mapear escopo, riscos, plano, backlog, critérios de aceite, ou descobrir arquivos, dependências e fluxos antes de mudar código.
---

## Objective

Understand the current state and decide the next sensible step.

## Use for

- Unknown repositories or unclear requests
- Scoping a feature, bug, or refactor before execution
- Mapping constraints, risks, invariants, and affected areas
- Producing a plan, backlog proposal, or acceptance criteria

## Does

- Read only the relevant repo context
- Summarize the current shape of the system
- Identify gaps, risks, and likely next steps
- Optionally persist outputs such as a PRD or backlog

## Does not

- Implement code
- Debug a reproduced failure end-to-end
- Give final merge approval
- Do architecture sustainability review as its main task

## Workflow

1. Read the request and current context
2. Map only the relevant code and docs
3. Name the problem, constraints, and unknowns
4. Propose the next step with a small, explicit scope
5. Emit the lightest useful output: scan, plan, backlog, or acceptance criteria

## Repository discovery (pre-change mapping)

Before changing code, map the relevant area: locate files and report structure without implementing anything.

1. Parse the task to identify what to find.
2. If changes exist, run `git diff` for context.
3. Search for candidates:
   - `rg` for symbols, patterns, imports
   - `glob` for filenames
   - `git log -S` for history (when relevant)
4. Read only the top candidates found by search.
   If more context is needed, explain why before expanding.
5. Report:
   - Files and their roles
   - Dependencies between them
   - Potential risks

### Output format

```
Path:line — symbol — role (≤8 words)
Path:line — symbol — role (≤8 words)
```

Group by directory. One group header per directory.

### Discovery rules

- Do not edit files.
- Do not propose implementation code.
- Do not run write commands.
- Read only candidates found by search, not entire directories.
- If nothing relevant is found, report "No relevant code found."
