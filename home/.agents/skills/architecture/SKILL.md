---
name: architecture
description: Avalia sustentabilidade, projeta módulos profundos, escaneia oportunidades de deepening, aplica a filosofia Write Simple Software, stress-testa planos contra modelo de domínio e formaliza glossário. Use when deciding boundaries, simplicity versus abstraction, coupling, invariants, module depth, domain modeling, or ubiquitous language.
---

# Architecture

Unified skill for architecture decisions, codebase design, domain modeling, and ubiquitous language. Use the mode that fits your task.

## Modes

| Mode | What it does | When to use |
|---|---|---|
| `review` | Evaluate structural sustainability, detect violations, check invariants | Before merging structural changes, after refactors affecting multiple layers |
| `design` | Design deep modules — small interface, lots of behaviour, clean seam | Designing or improving a module's interface, deciding where a seam goes |
| `improve` | Scan codebase for deepening opportunities, present as report | Architectural friction, shallow modules, brittle coupling |
| `domain` | Stress-test plan against domain model, sharpen terminology, update CONTEXT.md/ADRs | Validating a plan against project's language, decisions crystallising |
| `language` | Extract/formalize glossary, flag ambiguities, propose canonical terms | Defining domain terms, building glossary, hardening terminology |

Use the **Write Simple Software** lens in any mode when a proposed change adds concepts, layers, dependencies, configuration, or flexibility. See [SIMPLE-SOFTWARE.md](SIMPLE-SOFTWARE.md).

---

## Mode: review

### Objective

Decide whether a change keeps the system sustainable over time. Detect architectural violations and broken invariants with objective evidence.

### Workflow

1. Read the relevant structure, domain docs, and decisions
2. Identify the structural tension or trade-off
3. Inspect the changed scope for violations
4. Evaluate boundaries, naming, coupling, and invariants
5. Report violations with evidence
6. List preserved and broken invariants
7. Recommend the smallest structural correction or guardrail
8. State why it improves or preserves sustainability

### Constraints

- Do NOT implement code
- Do NOT run merge-readiness review
- Do NOT produce a PRD or backlog as main task
- Do NOT replace debugging or test execution

---

## Mode: design

### Glossary

Use these terms exactly — not component, service, API, or boundary.

**Module** — anything with an interface and an implementation. Deliberately scale-agnostic: a function, class, package, or tier-spanning slice.

**Interface** — everything a caller must know to use the module correctly: type signature, invariants, ordering constraints, error modes, required configuration, performance characteristics.

**Implementation** — what's inside a module, its body of code.

**Depth** — leverage at the interface: amount of behaviour a caller can exercise per unit of interface they must learn. **Deep** = high leverage. **Shallow** = interface nearly as complex as implementation.

**Seam** — a place where you can alter behaviour without editing in that place; where a module's interface lives.

**Adapter** — a concrete thing that satisfies an interface at a seam.

**Leverage** — what callers get from depth: more capability per unit of interface learned.

**Locality** — what maintainers get from depth: change, bugs, knowledge, verification concentrate in one place.

### Deep vs shallow

```
Deep module:  Small Interface → Lots of Implementation
Shallow module: Large Interface → Little Implementation (avoid)
```

### Principles

- **Depth is a property of the interface, not the implementation.** Internal seams are separate from the external seam.
- **The deletion test.** Delete the module. If complexity vanishes → pass-through. If complexity reappears across N callers → earning its keep.
- **The interface is the test surface.** Callers and tests cross the same seam.
- **One adapter = hypothetical seam. Two adapters = real seam.** Don't introduce a seam unless something varies across it.

### Designing for testability

- Accept dependencies, don't create them
- Return results, don't produce side effects
- Small surface area = fewer tests needed

### Reference files

- [DEEPENING.md](DEEPENING.md) — deepening a cluster, seam discipline, replace-don't-layer testing
- [DESIGN-IT-TWICE.md](DESIGN-IT-TWICE.md) — parallel sub-agents for alternative interface designs

---

## Mode: improve

Surface architectural friction and propose **deepening opportunities** — refactors that turn shallow modules into deep ones for testability and AI-navigability.

### Process

#### 1. Explore

Read existing documentation first: CONTEXT.md, ADRs. Then walk the codebase organically and note friction:

- Where does understanding one concept require bouncing between many small modules?
- Where are modules shallow (interface ≈ implementation in complexity)?
- Where have pure functions been extracted for testability, but real bugs hide in how they're called?
- Where do tightly-coupled modules leak across their seams?
- Which parts are untested or hard to test through current interface?

Apply the **deletion test** to anything suspicious.

#### 2. Present candidates

Numbered list. For each candidate: files involved, problem, plain-English solution, benefits (locality + leverage + test improvement), recommendation strength (Strong / Worth exploring / Speculative).

Use CONTEXT.md vocabulary for the domain, and the design glossary for architecture.

**ADR conflicts**: if a candidate contradicts an existing ADR, only surface it when the friction warrants revisiting. Mark clearly.

#### 3. Grilling loop

Once user picks a candidate, walk the design tree — constraints, dependencies, shape of deepened module, seam placement, test survival.

Side effects as decisions crystallize:
- New term → update CONTEXT.md
- Fuzzy term sharpened → update CONTEXT.md
- Rejected candidate with load-bearing reason → offer ADR
- Alternative interfaces wanted → run design-it-twice

### Reference files

- [HTML-REPORT.md](HTML-REPORT.md) — HTML report scaffold for presenting candidates
- [INTERFACE-DESIGN.md](INTERFACE-DESIGN.md) — exploring alternative interfaces

---

## Mode: domain

Interview the user relentlessly about the plan against the project's domain model. Walk down each branch of the design tree, resolving dependencies between decisions one-by-one.

### File structure

Most repos have a single context:
```
/
├── CONTEXT.md
├── docs/adr/
└── src/
```

If CONTEXT-MAP.md exists, the repo has multiple contexts.

### During session

- Conflicting term → call it out immediately
- Vague/overloaded term → propose precise canonical term
- Domain relationships → stress-test with specific scenarios
- User states how something works → check if code agrees
- Term resolved → update CONTEXT.md inline (don't batch)
- Offer ADR only when: hard to reverse, surprising without context, result of real trade-off

### Reference files

- [CONTEXT-FORMAT.md](CONTEXT-FORMAT.md) — format for CONTEXT.md
- [ADR-FORMAT.md](ADR-FORMAT.md) — format for ADRs

---

## Mode: language

Extract and formalize domain terminology into a consistent glossary saved to a local file.

### Process

1. Scan the conversation for domain-relevant nouns, verbs, concepts
2. Identify problems: ambiguity, synonyms, overloaded terms
3. Propose canonical glossary with opinionated term choices
4. Write to UBIQUITOUS_LANGUAGE.md
5. Output summary inline

### Output format

```md
# Ubiquitous Language

## [Group name]

| Term | Definition | Aliases to avoid |
|------|-----------|-----------------|
| **Order** | A customer's request to purchase items | Purchase, transaction |
```

Include relationships table and example dialogue between dev and domain expert.

### Rules

- Be opinionated — pick best term, list aliases to avoid
- Flag conflicts explicitly
- Only terms relevant for domain experts
- One sentence definitions
- Group by subdomain, lifecycle, or actor
- Write an example dialogue

### Reference files

- [CONTEXT-FORMAT.md](CONTEXT-FORMAT.md)
- [ADR-FORMAT.md](ADR-FORMAT.md)
