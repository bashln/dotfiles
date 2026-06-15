---
name: review
description: Revisa a prontidao imediata de uma mudanca com foco em risco, qualidade e clareza de entrega. Use antes de merge, entrega ou release para checar bugs, regressao, observabilidade, validacao, documentacao operacional e bloqueadores concretos.
---

## Objective

Assess whether a change is ready to proceed now.

## Use for

- Final pass before merge
- Delivery or release readiness
- Risk-oriented code review
- Checking whether validation and operational clarity are sufficient

## Does

- Review correctness and high-impact risks
- Check whether tests and checks are proportionate
- Evaluate docs, error handling, and observability when relevant
- Give a clear recommendation: ready, blocked, or conditional

## Does not

- Implement fixes as its main task
- Perform deep architecture redesign
- Replace bug reproduction work

## Workflow

1. Read the relevant diff or scope
2. Look for the highest-impact risks first
3. Check validation quality and operational clarity
4. Report concrete findings with severity
5. End with a direct merge-readiness recommendation
