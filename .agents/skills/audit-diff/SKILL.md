---
name: audit-diff
description: >
  Review only the current diff for bugs, security issues, and edge cases.
  No diff, no review. Does not review unchanged code.
  Do not use for project-wide auditing or conceptual questions.
---

## Objective

Review the current diff and report actionable findings.
Reviews only what changed.

## Workflow

1. Run `git diff` (or `git diff HEAD` if staged changes exist).
2. If no diff, report "No diff to review" and stop.
3. For each modified file:
   - Examine added/changed lines only
   - Check for:
     - Logic bugs (wrong condition, off-by-one, null dereference)
     - Security issues (injection, path traversal, secret exposure)
     - Edge cases (empty input, missing validation, race condition)
     - Performance regressions (unnecessary loops, duplicate queries)
4. Report findings:

   `path:line 🔴 <problem>. <fix>.`

   Severity: 🔴 bug / 🟡 risk / 🔵 nit.
   Include the problem and the fix on the same line.
5. If no issues found, report "No issues found."

## Rules

- Do not edit files.
- Do not review unchanged code.
- Do not suggest refactors outside the diff scope.
- Do not comment on style or naming unless it hides a defect.
- One line per finding. Group by file. Ascending line numbers.
