---
name: minimal-diff-review
description: >
  Reviews git diffs looking exclusively for unnecessary changes that increase
  review cost. Finds formatting churn, unrelated refactors, incidental edits,
  generated noise, and changes that should be split into another commit or PR.
  Use before commits, pull requests, or after AI-generated changes.
---

## Goal

Review the diff from the perspective of a strict maintainer.

Your objective is **NOT** to improve the code.

Your objective is to **reduce review cost**.

Assume the default decision is `keep`.

Only flag changes when there is clear evidence they are unrelated, noisy,
incidental, or should be split into another commit or PR.

Review the **diff**, not the implementation.

Do **not** audit:

- correctness
- code quality
- architecture
- security
- performance

Only determine whether each change deserves to exist in this diff.

---

## Step 0 — Deterministic pre-filter

If Git is available, run:

```bash
git diff -w    # this is the diff you review below — whitespace noise already stripped
git diff --stat
git diff --name-status
git diff -w --stat
```

Use these numbers verbatim in the final report.

If a file appears in `git diff --stat` but disappears from
`git diff -w --stat`, classify it immediately as:

```
noise: whitespace-only change
```

Do not inspect that file further.

If Git is unavailable, review the provided diff using the same principles.

---

## Hard stop rules

Never inspect repeated internal structures entry by entry.

Examples:

- highlight definitions
- syntax mappings
- color tables
- generated theme entries
- snapshots
- fixture data
- lockfiles
- generated assets
- compiled files

For files dominated by homogeneous generated content, classify the **entire file once**.

Only ask:

- Does this file belong to the requested feature?
- Is it obviously generated junk?
- Should it belong to another commit?

If the answer is obvious, stop there.

Do **not** verify every generated entry.

---

## Reviewing everything else

Flag only:

- unrelated files
- formatting churn
- whitespace-only edits
- incidental refactors
- unnecessary renames
- unnecessary reordering
- generated comments
- code motion without behavioral changes
- changes that increase merge conflict risk
- changes that belong in another commit or PR

Never suggest:

- behavioral changes
- architectural improvements
- code simplifications
- performance optimizations

Those belong to other review passes.

---

## Circuit breaker

Stop immediately if:

- you exceed 8 tool calls, **or**
- you are no longer discovering new findings.

Do **not** continue reviewing merely to increase confidence.

If stopped early, report:

```
Confidence: Low — stopped early.
```

---

## Tags

- `noise:` no functional value
- `split:` legitimate change that belongs elsewhere
- `question:` intent is unclear; ask the human
- `keep:` only when necessary to explain an exception

Silence is the default for correct changes.

Do **not** emit `keep:` findings unless they add value.

---

## Output format

One finding per relevant file or range.

```
<file>: <tag> <finding>. <recommended action>.
```

or

```
<file>:L<line>: <tag> <finding>. <recommended action>.
```

---

## Final report

```text
Review Cost

Files changed:      <git diff --stat>
Required:           <count or "all remaining">
Noise:              <count>
Should split:       <count>
Needs a question:   <count>

Recommendation:

Keep as-is

or

Revert/split the listed changes before commit.

Confidence:

High
→ Safe to commit.

Medium
→ Human should skim the flagged findings.

Low
→ Human review required before commit.
```

---

If no unnecessary changes are found, output only:

```text
Minimal diff.

Lean already. Ship.
```
