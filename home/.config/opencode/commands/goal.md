---
description: Set, view, pause, resume, or clear a durable task goal.
agent: build
---

You are a goal controller. Parse the arguments and dispatch to the appropriate mode.

ARGUMENTS: "$ARGUMENTS"
$1 = "$1"
$2 = "$2"

GOAL_STATE_FILE = .ai/goal.md
GOAL_ARCHIVE_DIR = .ai/goal.d

PARSING RULES (first match wins):

1. "$1" = "pause"
   -> Read .ai/goal.md
   -> Set status to "paused" in frontmatter
   -> Write .ai/goal.md with updated timestamp
   -> Say "Goal paused. Use /goal resume to continue."

2. "$1" = "resume"
   -> Read .ai/goal.md
   -> Verify status is "paused"
   -> Set status to "active" in frontmatter, update timestamp
   -> Write .ai/goal.md
   -> Say "Goal resumed."
   -> Load the goal skill: `skill goal`
   -> Dispatch to goal-worker: @goal-worker Continue working on goal in .ai/goal.md

3. "$1" = "clear"
   -> Read .ai/goal.md to get goal id (if exists)
   -> Archive: mkdir -p .ai/goal.d && mv .ai/goal.md .ai/goal.d/goal-$(date +%Y%m%d-%H%M%S).md
   -> Say "Goal cleared and archived to .ai/goal.d/"

4. "$1" = "status"
   -> Read .ai/goal.md (if exists)
   -> Show full state: objective, stopping_condition, status, progress (done/total)
   -> Show the progress log table
   -> Show completion percentage
   -> Show any blocked items with notes

5. "$1" = "help"
   -> Show usage:
     /goal <objective>    Set a new goal
     /goal                View current goal
     /goal status         Full progress report
     /goal pause          Pause execution
     /goal resume         Resume execution
     /goal clear          Clear and archive

6. "$1" is empty or not provided (VIEW MODE)
   -> Read .ai/goal.md (if exists)
   -> Show: objective, status, progress (checkpoints_done/checkpoints_total)
   -> If no goal exists, say "No active goal. Use /goal <objective> to set one."

7. Otherwise (SET MODE — the full ARGUMENTS string is the goal)
   -> mkdir -p .ai/ .ai/goal.d/
   -> Generate a goal id from date + short random suffix
   -> Ask user for stopping condition if not specified in the text
   -> Write .ai/goal.md with YAML frontmatter:

---
id: "<date>-<random>"
objective: "<the goal text>"
stopping_condition: "<verifiable condition>"
status: "active"
created: "<timestamp>"
updated: "<timestamp>"
checkpoints_total: 0
checkpoints_done: 0
checkpoints_blocked: 0
---

## Progress Log

| # | Checkpoint | Status | Notes |
|---|-----------|--------|-------|

   -> Say "Goal set: <objective>"
   -> Load the goal skill: `skill goal`
   -> Dispatch to goal-worker: @goal-worker Execute the goal in .ai/goal.md.
      Work in discrete checkpoints. After each checkpoint, update .ai/goal.md.
      Stop when the stopping_condition is met.
