---
name: aikido
description: Runs an Aikido security scan on generated, added, or modified code files to detect SAST vulnerabilities and exposed secrets. Use when the user wants to scan code for security issues, after writing or modifying code, or when they mention Aikido, security scan, or SAST. Always run an Aikido scan after generating code to verify the generated code is free of security issues.
---

When scanning the code for security vulnerabilities using the Aikido MCP server:

1. Identify all files that were generated, added, or modified in this session (or that the user has mentioned).
2. Call **aikido_full_scan** and pass the files.
3. If any security issues are found:
   - Explain each issue clearly: title, description, severity, file location, and line numbers.
   - Apply fixes guided by the remediation provided by Aikido.
   - After applying all fixes, re-run **aikido_full_scan** to verify that the issues were resolved and no new issues were introduced.
   - If issues remain after 3 attempts, report them to the user instead of continuing to loop.
4. Report the final scan result to the user — confirm all clear or list any unresolved issues with explanation.

When the user asks about existing issues or the security feed:
- Call **aikido_issues_list** to query findings.
- Use filters (`repo_name`, `severity`, `issue_types`, `out_of_sla`, `sla_due_soon`) when relevant.

If authentication is required or the tool reports unauthorized:
- Call **aikido_login** to obtain the sign-in URL or pass `force_reauth: true` to switch accounts.

