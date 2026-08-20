# agents.md — AI Agent Best Practices

A living document of rules and conventions for AI agents working on complex, long-running tasks.

---

## 🧠 Reasoning & Planning

**Think before acting**
Before starting any complex task, briefly outline your plan. List the steps, dependencies, and potential risks. Don't start executing before you know where you're going.

**Break it down**
Never try to solve everything in one shot. Decompose big tasks into small, verifiable subtasks. Complete and validate each one before moving to the next.

**Verify assumptions**
If something is unclear, state your assumption explicitly before proceeding rather than guessing silently. A wrong assumption at step 1 compounds into a broken result at step 10.

**Re-read the goal**
Before finalizing any task, re-read the original request and confirm what you produced actually answers it. It's easy to drift.

---

## 🔁 Loops & Progress

**Don't fight errors**
Whenever you encounter the same error twice, research the web and find 3–5 possible ways to fix it. Then choose the most efficient solution and implement it. Never retry an identical approach expecting a different result.

**Detect when you're stuck**
If you've taken more than 3 attempts on the same step without progress, stop. Summarize the situation, describe what has been tried, and ask for direction before continuing.

**Avoid infinite loops**
Always track what you've already tried. If a solution didn't work, log it and move on. Going in circles wastes time and context.

---

## 🗃️ Persistent Error Log (`errors.json`)

Maintain a local `errors.json` file throughout the task. This is your **external memory** — it survives context compaction and lets the developer audit what happened at any point.

### Structure

```json
{
  "errors": [
    {
      "id": "err_001",
      "timestamp": "2026-05-12T10:23:00Z",
      "error": "ModuleNotFoundError: No module named 'xyz'",
      "context": "Running install step in Docker container",
      "status": "resolved",
      "solution": "Package name is 'xyz-python', not 'xyz'. Fixed in requirements.txt.",
      "attempts": 2,
      "failed_approaches": [
        "pip install xyz"
      ]
    }
  ]
}
```

### Status values

| Status | Meaning |
|---|---|
| `triage` | Error logged, fix not yet attempted |
| `in_progress` | Fix is being attempted |
| `resolved` | Fix confirmed working |
| `failed_approaches` | Attempted fixes that did not work |
| `escalated` | Could not resolve; flagged for human review |

### Rules

1. **Before attempting any fix** — search `errors.json` for a matching error. If `status: resolved`, apply the known solution directly. Don't retry from scratch.
2. **On first occurrence** — log the error with `status: triage` and your planned approach.
3. **After resolution** — update the entry with `status: resolved` and a clear `solution` description that a future agent (or developer) can follow without extra context.
4. **On repeated failure** — increment `attempts`, update `status: failed_approaches`, and log what didn't work to avoid cycles.

> **Why this matters:** Context compaction erases short-term memory. This file is the source of truth for what has already been tried and solved — both for the agent and for the developer reviewing progress.

---

## 📋 Persistent Progress Log (`progress.json`)

Alongside `errors.json`, maintain a `progress.json` that tracks the overall state of the task. This allows resuming from any interruption without relying on the model's memory.

### Structure

```json
{
  "task": "Setup deployment pipeline",
  "status": "in_progress",
  "started_at": "2026-05-12T09:00:00Z",
  "last_updated": "2026-05-12T10:45:00Z",
  "completed_steps": [
    "install dependencies",
    "configure docker"
  ],
  "pending_steps": [
    "setup CI",
    "deploy to staging"
  ],
  "notes": "Docker build succeeded on second attempt. See errors.json err_001."
}
```

### Rules

1. Update `progress.json` after every completed step, not just at the end.
2. Always include a `notes` field summarizing any non-obvious decisions made along the way.
3. If the task is interrupted, the next session must start by reading `progress.json` before doing anything else.

---

## 🔧 Execution & Tools

**Prefer reversible actions**
When possible, choose actions that can be undone — move instead of delete, branch instead of pushing directly to main, backup before overwriting. If something goes wrong, you want a way back.

**Validate before proceeding**
After each meaningful step, verify the output is correct before moving to the next one. A broken step silently carried forward is harder to debug than a broken step caught immediately.

**Minimal footprint**
Request only the permissions you need. Touch only the files relevant to the task. Leave no side effects that weren't part of the plan.

---

## 📢 Communication

**Surface blockers early**
If you realize you're missing information or access to complete a task, say so immediately — not after 10 failed attempts. The sooner a blocker is surfaced, the cheaper it is to resolve.

**Distinguish certainty levels**
Be explicit when you're confident vs. guessing. Use phrases like *"I'm not sure, but..."* rather than stating everything with equal confidence. The developer needs to know when to double-check your work.

**Summarize long contexts**
In long tasks, periodically write a brief summary of what's been done, what's pending, and any open questions. This keeps the task on track and makes `progress.json` useful.

---

## 🔄 Session Startup Checklist

At the start of every session (especially after interruption or context compaction):

- [ ] Read `progress.json` — where did we stop?
- [ ] Read `errors.json` — what errors have already been seen and solved?
- [ ] Re-read the original task description
- [ ] Confirm the next step before executing it
Teste de escrita
