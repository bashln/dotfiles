---
name: agy-second-opinion
description: Use when you need an independent second opinion, an architectural plan, or an adversarial code review from a different model family (Google Gemini or Claude via the Antigravity CLI `agy`). Triggered by /agy-plan, /agy-review, "second opinion", "ask gemini", "ask claude", or before a high-stakes design decision.
---

# Antigravity second opinion

Call the local Antigravity CLI (`agy`) headless for an opinion from a model family OpenCode lacks: Gemini 3.x and Claude 5.x. Advisory only — the main agent still drives.

## Preconditions

- `agy` on PATH (`~/.local/bin/agy`), authenticated to the Antigravity plan.
- Verify once with: `agy models`.

## Invocation

Plan / design (read-only, Gemini):

```bash
agy --mode plan --add-dir . --model gemini-3.1-pro-high \
  --dangerously-skip-permissions \
  -p "$(cat /tmp/agy-prompt.txt)" --output-format json
```

Adversarial review (read-only, Claude, family different from the author):

```bash
agy --mode plan --add-dir . --model claude-sonnet-5-5-high \
  --dangerously-skip-permissions \
  -p "$(cat /tmp/agy-prompt.txt)" --output-format json
```

Short prompt: pass it inline with `-p "..."` instead of a file.

## Rules

- Put large prompts (diffs, specs) in `/tmp/agy-prompt.txt`; reference with `"$(cat ...)"`.
- Keep `--mode plan`; never grant write. `--sandbox` is optional.
- Parse the JSON `response` field; ignore the rest except `usage`.
- Treat the output as advice, not authority. Cross-check against the code and the request.
- Models: plan `gemini-3.1-pro-high`; review `claude-sonnet-5-5-high`; cheap pass `gemini-3.8-flash-high`. List with `agy models`.
- If `agy` fails or is unauthenticated, say so and continue without it. Never block on it.

## When not to use

- Routine edits or small fixes the main loop handles fine.
- Anything needing tool-calling, streaming, or edits through OpenCode's permission model.
