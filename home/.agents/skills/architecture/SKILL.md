---
name: architecture
description: Avalia se uma mudanca preserva ou melhora a sustentabilidade do sistema. Use quando a decisao envolver boundaries, naming estrutural, acoplamento, modularidade, seams, invariantes, profundidade de modulos ou evolucao futura da arquitetura.
---

## Objective

Decide whether a change keeps the system sustainable over time. Detect architectural violations and broken invariants with objective evidence.

## Use for

- Boundary and dependency questions
- Structural naming and module shape
- Coupling, seams, invariants, and layering
- Trade-offs that affect future evolution
- Before merging structural changes
- After refactors that affect multiple layers

## Does

- Review sustainability of the proposed or changed design
- Identify shallow modules, leaking seams, and brittle coupling
- Recommend smaller, clearer structural moves
- Use domain language and documented decisions when available
- Point to violations with location and severity

## Does not

- Implement code
- Run merge-readiness review
- Produce a PRD or backlog as its main task
- Replace debugging or test execution

## Workflow

1. Read the relevant structure, domain docs, and decisions
2. Identify the structural tension or trade-off
3. Inspect the changed scope for violations
4. Evaluate boundaries, naming, coupling, and invariants
5. Report violations with evidence
6. List preserved and broken invariants
7. Recommend the smallest structural correction or guardrail
8. State why it improves or preserves sustainability
