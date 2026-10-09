---
description: Independent architectural plan from Gemini (Antigravity). Read-only second opinion.
---

Get an independent plan from Antigravity's Gemini.

1. Load the `agy-second-opinion` skill.
2. Compose a prompt with the goal, constraints, and relevant repo paths. Write it to `/tmp/agy-prompt.txt`.
3. Run:
   `agy --mode plan --add-dir . --model gemini-3.1-pro-high --dangerously-skip-permissions -p "$(cat /tmp/agy-prompt.txt)" --output-format json`
4. Extract the `response` field, present it as "Gemini (via Antigravity) plan", then compare it with your own plan and flag disagreements.

If `agy` is unavailable or unauthenticated, say so and fall back to your own plan.

ARGUMENTS: "$ARGUMENTS"
