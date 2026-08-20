---
name: goal
description: Instructions for working with durable task goals, checkpoints, and progress tracking.
---

# Goal Skill

This skill teaches the agent how to work with the /goal system.

## Goal State File Format

Goals are stored in `.ai/goal.md` with YAML frontmatter:

```yaml
---
id: "<unique-id>"
objective: "<what needs to be done>"
stopping_condition: "<verifiable condition that means done>"
status: "active"  # active | paused | completed | blocked | archived
created: "<ISO timestamp>"
updated: "<ISO timestamp>"
checkpoints_total: <number>
checkpoints_done: <number>
checkpoints_blocked: <number>
---
```

## Progress Log Format

After the frontmatter, a markdown table:

```
## Progress Log

| # | Checkpoint | Status | Notes |
|---|-----------|--------|-------|
| 1 | Checkpoint name | done/pending/blocked | Details |
```

Valid statuses: `done`, `pending`, `blocked`.

## Goal Protocol

When asked to work on a goal:

1. **Read** `.ai/goal.md` to understand the objective and stopping condition.
2. **Plan** checkpoints if none are defined (update `checkpoints_total` in frontmatter).
3. **Execute** one checkpoint at a time. After each:
   - Update the progress log table
   - Update frontmatter counters (`checkpoints_done`)
   - Evaluate the stopping condition
   - If met, set `status: completed` and stop
4. **If blocked**, set `checkpoints_blocked++`, add notes to the log, set `status: blocked`.
5. **If paused**, stop immediately and preserve state.

## Rules

- Work in **discrete checkpoints**. One checkpoint per invocation.
- Each checkpoint must have a **verifiable outcome**.
- The stopping condition is the **single source of truth** for completion.
- Never modify files outside the goal scope.
- Keep the progress log updated after every checkpoint.
- If the goal references a PLAN.md or spec, read it first.

## Good Checkpoint Verification Examples

| Checkpoint | Verification |
|-----------|-------------|
| Audit current JWT usage | `rg "jwt|JWT" --type ts` produces list |
| Implement OAuth2 exchange | `npm test tests/auth/oauth2.test.ts` passes |
| Migrate auth middleware | All existing auth tests pass |
| Verify rollback path | Rollback script executes without error |

## Stopping Condition Patterns

- "All existing tests pass" -> run test suite
- "Build succeeds" -> run build command
- "Migration completes" -> comparison script returns zero diff
- "Score reaches 90%+" -> run eval, check score
