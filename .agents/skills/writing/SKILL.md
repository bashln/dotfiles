---
name: writing
description: Edita e melhora artigos, minera fragmentos brutos, constrói artigo batida-por-batida, molda material em artigo final, escreve skills previsíveis. Use when editing prose, exploring writing material, structuring articles, or authoring skills.
---

# Writing

Unified skill for editing, exploring, and structuring prose, and authoring skills. Use the mode that fits your task.

## Modes

| Mode | What it does | When to use |
|---|---|---|
| `edit` | Restructure sections, improve clarity, tighten prose | Editing, revising, or improving an article draft |
| `fragments` | Mine raw fragments from conversation, no structure yet | Exploring writing material, early ideation phase |
| `beats` | Assemble raw material into a journey of beats | Exploit phase — raw material exists, commit to a path |
| `shape` | Shape raw material into an article paragraph by paragraph | Exploit phase — fixed pile, build structured article |
| `skill-author` | Reference for writing and editing skills well | Writing or editing skill files |

---

## Mode: edit

1. Divide article into sections based on headings. Think about main points per section.
2. Information is a DAG — respect dependency order between sections.
3. Confirm sections with user.
4. For each section: rewrite for clarity, coherence, flow. Max 240 characters per paragraph.

---

## Mode: fragments

Pure **explore**: widen the space of what could be written without committing to structure.

### What is a fragment

Any piece of text that might survive into the final article. Must be readable by the author but need not be self-contained:
- A sharp sentence for later deployment
- A claim with one-line justification
- A vignette, code snippet, scenario, analogy
- A half-thought, quote, overheard line
- A **leading word** — compact metaphor the whole piece can hang on

The leading word is the most valuable fragment: name the right one during explore and it shapes structure, transitions, and title later.

### File format

```
# Working title

First fragment.

---

Second fragment.

---

> Quote.

Reaction.

---

- Cluster of related observations
- That hang together
```

Fragments separated by `\n---\n`. No headings inside body. No tags. No order beyond addition order.

### Writing rhythm

- Append silently — don't ask permission per fragment
- Re-read file from disk before every write
- User can say "cut the last one", "rewrite that one sharper", "merge those two"

---

## Mode: beats

**Exploit**: fixed pile, commit to a path. Assemble raw material into a beat-by-beat journey.

### Grounding

Every **concept** must be **grounded** before a beat can lean on it: either prerequisite (reader brings it) or introduced (a beat establishes it). Keep a running list.

A candidate beat is only reachable if everything it requires is already grounded. Picking a beat that grounds concept X unlocks every beat waiting on X.

### Process

1. Establish prerequisites: settle what the audience already knows
2. Write 2-3 candidate **starting beats** from raw material. User picks one.
3. Write that beat to the article file. Stop.
4. Re-read article file. Offer 2-3 candidate **next beats**.
5. Loop steps 3-5 until natural end.

Each beat does one move: sets a scene, lands a point, asks a question, drops an aside, twists the angle. Sized by what it needs — one sentence to several paragraphs.

### Writing rhythm

- Append one beat at a time. Never write ahead.
- Re-read article file from disk before every write. Preserve user edits.
- User can say "rewrite that beat" — edit in place, leave rest alone.

---

## Mode: shape

**Exploit**: fixed pile, build structured article. Read the pile, then run a shaping session.

### Process

1. Read the pile in full.
2. Establish prerequisites — what reader knows walking in.
3. Draft 2-3 candidate openings — each implying different thesis/angle. User picks.
4. Grow paragraph by paragraph: given this opening, what does reader need next?
5. Append to article file immediately. Don't batch.
6. Loop until article is done.

### Format arguments

- **Prose vs list**: prose carries argument, lists carry parallel items
- **Inline vs callout**: tips/warnings go in callouts only if they'd derail main argument
- **Table vs repeated structure**: same shape 3+ times → table
- **Quote vs paraphrase**: quote when original wording is the point
- **Code block vs inline**: multi-line/runnable → block; single token → inline

### Grounding

Same grounding discipline as beats mode: prerequisites vs introduced concepts. Keep running list.

---

## Mode: skill-author

Reference for writing and editing skills well. See [GLOSSARY.md](GLOSSARY.md) for bold terms.

### Invocation

- **Model-invoked** skill: keeps description so agent can fire autonomously. Pay context load.
- **User-invoked** skill: set `disable-model-invocation: true`. Zero context load, but you must remember it.

### Information hierarchy

1. In-skill step — ordered action in SKILL.md, each step ends on completion criterion
2. In-skill reference — definition, rule, fact, consulted on demand
3. External reference — pushed out of SKILL.md into separate file, loaded via context pointer

### Writing principles

- **Leading word**: compact concept from model's pretraining that anchors behaviour (e.g. *tight*, *red*)
- **Deletion test**: if removing doesn't change behaviour, it's a no-op
- **Single source of truth**: one authoritative place per meaning
- **Progressive disclosure**: push reference behind pointers so the top stays legible

### Failure modes

- **Premature completion**: ending step before done. Fix: sharpen completion criterion.
- **Duplication**: same meaning in multiple places. Fix: deduplicate.
- **Sediment**: stale layers from adding without pruning. Fix: regular pruning.
- **Sprawl**: too long even when every line is live. Fix: ladder disclosure.
- **No-op**: line model already obeys. Fix: delete it.

### Reference files

- [GLOSSARY.md](GLOSSARY.md) — full definitions of bold terms
