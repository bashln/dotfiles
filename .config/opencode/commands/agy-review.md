---
description: Adversarial code review from Claude (Antigravity). Different model family, read-only.
---

Get an adversarial review from Antigravity's Claude (a family different from the author).

1. Load the `agy-second-opinion` skill.
2. Capture the scope into `/tmp/agy-prompt.txt` with a short instruction to find bugs, risks, and over-engineering: the `git diff` for the current changes, or the paths given in the arguments.
3. Run:
   `agy --mode plan --add-dir . --model claude-sonnet-5-5-high --dangerously-skip-permissions -p "$(cat /tmp/agy-prompt.txt)" --output-format json`
4. Present the `response` as "Claude (via Antigravity) review", ordered by severity. Do not apply fixes unless the user asks.

If `agy` is unavailable or unauthenticated, say so and fall back to your own review.

ARGUMENTS: "$ARGUMENTS"
