---
name: triage-issue
description: Investigate a reported problem, find root cause, create GitHub issue with TDD fix plan.
---

## Objective

Investigate a reported problem, find its root cause, and create a GitHub issue with a TDD fix plan.

## Workflow

### 1. Capture the problem

Get a brief description from the user. Ask ONE question: "What's the problem you're seeing?"

### 2. Explore and diagnose

Use an Explore subagent to deeply investigate the codebase. Find where the bug manifests, what code path is involved, why it fails (root cause), and what related code exists.

### 3. Identify the fix approach

Determine the minimal change needed, which modules/interfaces are affected, what behaviors need tests, and whether this is a regression, missing feature, or design flaw.

### 4. Design TDD fix plan

Create a concrete list of RED-GREEN cycles. Each cycle is one vertical slice: RED = specific test capturing broken behavior, GREEN = minimal code change to make it pass.

### 5. Create the GitHub issue

Use `gh issue create` with this template:

```
## Problem
[Actual behavior, expected behavior, reproduction]

## Root Cause Analysis
[Code path involved, why it fails, contributing factors]

## TDD Fix Plan
1. RED: [test]
   GREEN: [change]

...

## Acceptance Criteria
- [ ] Criterion 1
```

Do NOT include specific file paths or line numbers. Describe modules, behaviors, and contracts.
