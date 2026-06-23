---
name: issue-management
description: "Ciclo de bugs: QA conversacional, triagem e gestão de issues no GitHub."
---

## QA Workflow


# QA Session

Run an interactive QA session. The user describes problems they're encountering. You clarify, explore the codebase for context, and file GitHub issues that are durable, user-focused, and use the project's domain language.

## For each issue the user raises

### 1. Listen and lightly clarify

Let the user describe the problem in their own words. Ask **at most 2-3 short clarifying questions** focused on:

- What they expected vs what actually happened
- Steps to reproduce (if not obvious)
- Whether it's consistent or intermittent

Do NOT over-interview. If the description is clear enough to file, move on.

### 2. Explore the codebase in the background

While talking to the user, kick off an Agent (subagent_type=Explore) in the background to understand the relevant area. The goal is NOT to find a fix — it's to:

- Learn the domain language used in that area (check UBIQUITOUS_LANGUAGE.md)
- Understand what the feature is supposed to do
- Identify the user-facing behavior boundary

This context helps you write a better issue — but the issue itself should NOT reference specific files, line numbers, or internal implementation details.

### 3. Assess scope: single issue or breakdown?

Before filing, decide whether this is a **single issue** or needs to be **broken down** into multiple issues.

Break down when:

- The fix spans multiple independent areas (e.g. "the form validation is wrong AND the success message is missing AND the redirect is broken")
- There are clearly separable concerns that different people could work on in parallel
- The user describes something that has multiple distinct failure modes or symptoms

Keep as a single issue when:

- It's one behavior that's wrong in one place
- The symptoms are all caused by the same root behavior

### 4. File the GitHub issue(s)

Create issues with `gh issue create`. Do NOT ask the user to review first — just file and share URLs.

Issues must be **durable** — they should still make sense after major refactors. Write from the user's perspective.

#### For a single issue

Use this template:

```
## What happened

[Describe the actual behavior the user experienced, in plain language]

## What I expected

[Describe the expected behavior]

## Steps to reproduce

1. [Concrete, numbered steps a developer can follow]
2. [Use domain terms from the codebase, not internal module names]
3. [Include relevant inputs, flags, or configuration]

## Additional context

[Any extra observations from the user or from codebase exploration that help frame the issue — e.g. "this only happens when using the Docker layer, not the filesystem layer" — use domain language but don't cite files]
```

#### For a breakdown (multiple issues)

Create issues in dependency order (blockers first) so you can reference real issue numbers.

Use this template for each sub-issue:

```
## Parent issue

#<parent-issue-number> (if you created a tracking issue) or "Reported during QA session"

## What's wrong

[Describe this specific behavior problem — just this slice, not the whole report]

## What I expected

[Expected behavior for this specific slice]

## Steps to reproduce

1. [Steps specific to THIS issue]

## Blocked by

- #<issue-number> (if this issue can't be fixed until another is resolved)

Or "None — can start immediately" if no blockers.

## Additional context

[Any extra observations relevant to this slice]
```

When creating a breakdown:

- **Prefer many thin issues over few thick ones** — each should be independently fixable and verifiable
- **Mark blocking relationships honestly** — if issue B genuinely can't be tested until issue A is fixed, say so. If they're independent, mark both as "None — can start immediately"
- **Create issues in dependency order** so you can reference real issue numbers in "Blocked by"
- **Maximize parallelism** — the goal is that multiple people (or agents) can grab different issues simultaneously

#### Rules for all issue bodies

- **No file paths or line numbers** — these go stale
- **Use the project's domain language** (check UBIQUITOUS_LANGUAGE.md if it exists)
- **Describe behaviors, not code** — "the sync service fails to apply the patch" not "applyPatch() throws on line 42"
- **Reproduction steps are mandatory** — if you can't determine them, ask the user
- **Keep it concise** — a developer should be able to read the issue in 30 seconds

After filing, print all issue URLs (with blocking relationships summarized) and ask: "Next issue, or are we done?"

### 5. Continue the session

Keep going until the user says they're done. Each issue is independent — don't batch them.


## Triage Workflow


# Triage Issue

Investigate a reported problem, find its root cause, and create a GitHub issue with a TDD fix plan. This is a mostly hands-off workflow - minimize questions to the user.

## Process

### 1. Capture the problem

Get a brief description of the issue from the user. If they haven't provided one, ask ONE question: "What's the problem you're seeing?"

Do NOT ask follow-up questions yet. Start investigating immediately.

### 2. Explore and diagnose

Use the Agent tool with subagent_type=Explore to deeply investigate the codebase. Your goal is to find:

- **Where** the bug manifests (entry points, UI, API responses)
- **What** code path is involved (trace the flow)
- **Why** it fails (the root cause, not just the symptom)
- **What** related code exists (similar patterns, tests, adjacent modules)

Look at:
- Related source files and their dependencies
- Existing tests (what's tested, what's missing)
- Recent changes to affected files (`git log` on relevant files)
- Error handling in the code path
- Similar patterns elsewhere in the codebase that work correctly

### 3. Identify the fix approach

Based on your investigation, determine:

- The minimal change needed to fix the root cause
- Which modules/interfaces are affected
- What behaviors need to be verified via tests
- Whether this is a regression, missing feature, or design flaw

### 4. Design TDD fix plan

Create a concrete, ordered list of RED-GREEN cycles. Each cycle is one vertical slice:

- **RED**: Describe a specific test that captures the broken/missing behavior
- **GREEN**: Describe the minimal code change to make that test pass

Rules:
- Tests verify behavior through public interfaces, not implementation details
- One test at a time, vertical slices (NOT all tests first, then all code)
- Each test should survive internal refactors
- Include a final refactor step if needed
- **Durability**: Only suggest fixes that would survive radical codebase changes. Describe behaviors and contracts, not internal structure. Tests assert on observable outcomes (API responses, UI state, user-visible effects), not internal state. A good suggestion reads like a spec; a bad one reads like a diff.

### 5. Create the GitHub issue

Create a GitHub issue using `gh issue create` with the template below. Do NOT ask the user to review before creating - just create it and share the URL.

<issue-template>

## Problem

A clear description of the bug or issue, including:
- What happens (actual behavior)
- What should happen (expected behavior)
- How to reproduce (if applicable)

## Root Cause Analysis

Describe what you found during investigation:
- The code path involved
- Why the current code fails
- Any contributing factors

Do NOT include specific file paths, line numbers, or implementation details that couple to current code layout. Describe modules, behaviors, and contracts instead. The issue should remain useful even after major refactors.

## TDD Fix Plan

A numbered list of RED-GREEN cycles:

1. **RED**: Write a test that [describes expected behavior]
   **GREEN**: [Minimal change to make it pass]

2. **RED**: Write a test that [describes next behavior]
   **GREEN**: [Minimal change to make it pass]

...

**REFACTOR**: [Any cleanup needed after all tests pass]

## Acceptance Criteria

- [ ] Criterion 1
- [ ] Criterion 2
- [ ] All new tests pass
- [ ] Existing tests still pass

</issue-template>

After creating the issue, print the issue URL and a one-line summary of the root cause.


## GitHub Triage Workflow


# GitHub Issue Triage

Triage issues in the current repo using a label-based state machine. Infer the repo from `git remote`. Use `gh` for all GitHub operations.

## AI Disclaimer

Every comment or issue posted to GitHub during triage **must** include the following disclaimer at the top of the comment body, before any other content:

```
> *This was generated by AI during triage.*
```

## Reference docs

- [AGENT-BRIEF.md](AGENT-BRIEF.md) — how to write durable agent briefs
- [OUT-OF-SCOPE.md](OUT-OF-SCOPE.md) — how the `.out-of-scope/` knowledge base works

## Labels

| Label             | Type     | Description                              |
| ----------------- | -------- | ---------------------------------------- |
| `bug`             | Category | Something is broken                      |
| `enhancement`     | Category | New feature or improvement               |
| `needs-triage`    | State    | Maintainer needs to evaluate this issue  |
| `needs-info`      | State    | Waiting on reporter for more information |
| `ready-for-agent` | State    | Fully specified, ready for AFK agent     |
| `ready-for-human` | State    | Requires human implementation            |
| `wontfix`         | State    | Will not be actioned                     |

Every issue should have exactly **one** state label and **one** category label. If an issue has conflicting state labels (e.g. both `needs-triage` and `ready-for-agent`), flag the conflict and ask the maintainer which state is correct before doing anything else. Provide a recommendation.

## State Machine

| Current State  | Can transition to | Who triggers it        | What happens                                                                                                         |
| -------------- | ----------------- | ---------------------- | -------------------------------------------------------------------------------------------------------------------- |
| `unlabeled`    | `needs-triage`    | Skill (on first look)  | Issue needs maintainer evaluation. Skill applies label after presenting recommendation.                              |
| `unlabeled`    | `ready-for-agent` | Maintainer (via skill) | Issue is already well-specified and agent-suitable. Skill writes agent brief comment, applies label.                 |
| `unlabeled`    | `ready-for-human` | Maintainer (via skill) | Issue requires human implementation. Skill writes a brief comment summarizing the task, applies label.               |
| `unlabeled`    | `wontfix`         | Maintainer (via skill) | Issue is spam, duplicate, or out of scope. Skill closes with comment (and writes `.out-of-scope/` for enhancements). |
| `needs-triage` | `needs-info`      | Maintainer (via skill) | Issue is underspecified. Skill posts triage notes capturing progress so far + questions for reporter.                |
| `needs-triage` | `ready-for-agent` | Maintainer (via skill) | Grilling session complete, agent-suitable. Skill writes agent brief comment, applies label.                          |
| `needs-triage` | `ready-for-human` | Maintainer (via skill) | Grilling session complete, needs human. Skill writes a brief comment summarizing the task, applies label.            |
| `needs-triage` | `wontfix`         | Maintainer (via skill) | Maintainer decides not to action. Skill closes with comment (and writes `.out-of-scope/` for enhancements).          |
| `needs-info`   | `needs-triage`    | Skill (detects reply)  | Reporter has replied. Skill surfaces to maintainer for re-evaluation.                                                |

An issue can only move along these transitions. The maintainer can override any state directly (see Quick State Override below), but the skill should flag if the transition is unusual.

## Invocation

The maintainer invokes `/github-triage` then describes what they want in natural language. The skill interprets the request and takes the appropriate action.

Example requests:

- "Show me anything that needs my attention"
- "Let's look at #42"
- "Move #42 to ready-for-agent"
- "What's ready for agents to pick up?"
- "Are there any unlabeled issues?"

## Workflow: Show What Needs Attention

When the maintainer asks for an overview, query GitHub and present a summary grouped into three buckets:

1. **Unlabeled issues** — new, no labels at all. These have never been triaged.
2. **`needs-triage` issues** — maintainer needs to evaluate or continue evaluating.
3. **`needs-info` issues with new activity** — the reporter has commented since the last triage notes comment. Check comment timestamps to determine this.

Display counts per group. Within each group, show issues oldest first (longest-waiting gets attention first). For each issue, show: number, title, age, and a one-line summary of the issue body.

Let the maintainer pick which issue to dive into.

## Workflow: Triage a Specific Issue

### Step 1: Gather context

Before presenting anything to the maintainer:

- Read the full issue: body, all comments, all labels, who reported it, when
- If there are prior triage notes comments (from previous sessions), parse them to understand what has already been established
- Explore the codebase to build context — understand the domain, relevant interfaces, and existing behavior related to the issue
- Read `.out-of-scope/*.md` files and check if this issue matches or is similar to a previously rejected concept

### Step 2: Present a recommendation

Tell the maintainer:

- **Category recommendation:** bug or enhancement, with reasoning
- **State recommendation:** where this issue should go, with reasoning
- If it matches a prior out-of-scope rejection, surface that: "This is similar to `.out-of-scope/concept-name.md` — we rejected this before because X. Do you still feel the same way?"
- A brief summary of what you found in the codebase that's relevant

Then wait for the maintainer's direction. They may:

- Agree and ask you to apply labels → do it
- Want to flesh it out → start a /domain-model session
- Override with a different state → apply their choice
- Want to discuss → have a conversation

### Step 3: Bug reproduction (bugs only)

If the issue is categorized as a bug, attempt to reproduce it before starting a /domain-model session. This will vary by codebase, but do your best:

- Read the reporter's reproduction steps (if provided)
- Explore the codebase to understand the relevant code paths
- Try to reproduce the bug: run tests, execute commands, or trace the logic to confirm the reported behavior
- If reproduction succeeds, report what you found to the maintainer — include the specific behavior you observed and where in the code it originates
- If reproduction fails, report that too — the bug may be environment-specific, already fixed, or the report may be inaccurate
- If the report lacks enough detail to attempt reproduction, note that — this is a strong signal the issue should move to `needs-info`

The reproduction attempt informs the /domain-model session and the agent brief. A confirmed reproduction with a known code path makes for a much stronger brief.

### Step 4: /domain-model session (if needed)

If the issue needs to be fleshed out before it's ready for an agent, interview the maintainer to build a complete specification. Use the /domain-model skill.

### Step 5: Apply the outcome

Depending on the outcome:

- **ready-for-agent** — post an agent brief comment (see [AGENT-BRIEF.md](AGENT-BRIEF.md))
- **ready-for-human** — post a comment summarizing the task, what was established during triage, and why it needs human implementation. Use the same structure as an agent brief but note the reason it can't be delegated to an agent (e.g. requires judgment calls, external system access, design decisions, or manual testing).
- **needs-info** — post triage notes with progress so far and questions for the reporter (see Needs Info Output below)
- **wontfix (bug)** — post a polite comment explaining why, then close the issue
- **wontfix (enhancement)** — write to `.out-of-scope/`, post a comment linking to it, then close the issue (see [OUT-OF-SCOPE.md](OUT-OF-SCOPE.md))
- **needs-triage** — apply the label. Optionally leave a comment if there's partial progress to capture.

## Workflow: Quick State Override

When the maintainer explicitly tells you to move an issue to a specific state (e.g. "move #42 to ready-for-agent"), trust their judgment and apply the label directly.

Still show a confirmation of what you're about to do: which labels will be added/removed, and whether you'll post a comment or close the issue. But skip the /domain-model session entirely.

If moving to `ready-for-agent` without a /domain-model session, ask the maintainer if they want to write a brief agent brief comment or skip it.

## Needs Info Output

When moving an issue to `needs-info`, post a comment that captures the interview progress and tells the reporter what's needed:

```markdown
## Triage Notes

**What we've established so far:**

- point 1
- point 2

**What we still need from you (@reporter):**

- question 1
- question 2
```

Include everything resolved during the /domain-model session in "established so far" — this work should not be lost. The questions for the reporter should be specific and actionable, not vague ("please provide more info").

## Resuming Previous Sessions

When triaging an issue that already has triage notes from a previous session:

1. Read all comments to find prior triage notes
2. Parse what was already established
3. Check if the reporter has answered any outstanding questions
4. Present the maintainer with an updated picture: "Here's where we left off, and here's what the reporter has said since"
5. Continue the /domain-model session from where it stopped — do not re-ask resolved questions
