---
description: Implementação + auditoria pós-impl
---
Implement and audit in two phases.

Phase 1 — Implement: use `executor` subagent to implement $ARGUMENTS.

Phase 2 — Audit: use `auditor` subagent. Verify:
- Implementation matches the original request
- No obvious bugs, regressions, or edge cases missed
- All modified files are consistent

If audit finds issues, fix them. Report what was done.
