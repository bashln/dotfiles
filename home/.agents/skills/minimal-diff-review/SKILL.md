---
name: minimal-diff-review
description: >
  Reviews git diffs looking exclusively for unnecessary changes that increase
  review cost. Finds formatting churn, unrelated refactors, incidental edits,
  generated noise and changes that should be split into another commit or PR.
  Use when preparing a commit, opening a pull request, reviewing AI-generated
  changes, or whenever the goal is to produce the smallest possible diff.
---

## Step 0 — Deterministic pre-filter (run before reasoning)

Run these commands first. Do not skip this step.

```bash
git diff --stat                 # exact files/lines changed — use these numbers verbatim in the final report
git diff -w                     # whitespace-insensitive diff — this is what you actually review
```

If `git diff -w` shows no changes for a file that appears in `git diff --stat`,
that file is 100% whitespace noise. Tag it `noise:` immediately without
further reasoning — do not spend analysis on it.

## Reviewing the filtered diff

Review the remaining diff from the perspective of a strict open source maintainer.

Assume every changed line must justify its existence.

The default decision is KEEP.

Only flag a change if there is clear evidence it increases review cost without improving the feature.

Your objective is NOT to improve the code.
Your objective is to reduce review cost.

Only flag modifications unrelated to the intended feature or bugfix.

Never suggest behavioral changes.
Never suggest architectural improvements.
Never suggest refactors unless they should be moved into a separate commit.

## Output format

One finding per line, machine-parseable:
<file>:L<line>: <tag> <finding>. <recommended action>.

or, when the finding affects the whole file:
<file>: <tag> <finding>. <recommended action>.

## Tags

- `keep:` — Required change. Leave it.
- `noise:` — No functional value: formatting, rename, reorder, style,
  whitespace, generated comments, quote changes, code motion. No behavioral
  difference, regardless of what caused it.
- `split:` — Legitimate change, but belongs in another commit/PR.
- `question:` — Ambiguous. Might be intentional (e.g. consistency with the
  rest of the codebase). Do not decide — ask.

Do not use finer-grained tags than this. If unsure between `noise` and
`question`, prefer `question` — false positives on "revert this" are worse
than an extra question to the human.

## Things to ignore

Bug fixes required by the feature.
Necessary API adjustments.
Tests required by the implementation.
Minimal assertions or smoke tests.
Required documentation.
License updates required for the change.

## Counting the report (do this with a command, not by re-reading the diff)

After producing the tagged findings above, count them mechanically:

```bash
grep -c '^\S*: noise:' <findings>
grep -c '^\S*: split:' <findings>
grep -c '^\S*: question:' <findings>
```

Use `git diff --stat` from Step 0 for total files/lines — never re-estimate
these numbers from memory of the diff.

## Final report

Review Cost
Files changed: <from git diff --stat>
Required (keep): <count>
Noise: <count>
Should split: <count>
Needs a question: <count>
Recommendation:

Keep as-is
or
Revert/split the listed changes before commit.

Confidence:
High → no ambiguous findings, proceed
Medium → some question: findings, human should skim before commit
Low → many question: findings or unclear feature boundary — do not
auto-commit, human review required

If nothing unnecessary is found, output only:
Minimal diff.
Lean already. Ship.
