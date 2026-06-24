---
name: qa-session
description: Run interactive QA session, clarify issues, explore codebase, file GitHub issues from user reports.
---

## Objective

Run an interactive QA session. The user describes problems they're encountering. You clarify, explore the codebase for context, and file GitHub issues that are durable, user-focused, and use the project's domain language.

## Workflow

### 1. Listen and lightly clarify

Let the user describe the problem in their own words. Ask at most 2-3 short clarifying questions focused on what they expected vs what actually happened, steps to reproduce, and whether it's consistent or intermittent.

### 2. Explore the codebase in the background

While talking to the user, kick off an Explore subagent to understand the relevant area. Learn the domain language, understand what the feature is supposed to do, and identify the user-facing behavior boundary.

### 3. Assess scope: single issue or breakdown?

Decide whether this is a single issue or needs to be broken down into multiple issues. Break down when the fix spans multiple independent areas.

### 4. File the GitHub issue(s)

Create issues with `gh issue create`. Issues must be durable — use the project's domain language, describe behaviors not code.

**Template:**
```
## What happened
[Describe the actual behavior]

## What I expected
[Describe the expected behavior]

## Steps to reproduce
1. [Concrete, numbered steps]

## Additional context
[Any extra observations]
```

**For breakdowns:** Create issues in dependency order (blockers first). Each should be independently fixable and verifiable.

### 5. Continue the session

Keep going until the user says they're done. Print all issue URLs after filing.
