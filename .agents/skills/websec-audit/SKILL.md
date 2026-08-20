---
name: websec-audit
description: Auditoria defensiva de segurança WebSec em projetos frontend/backend — identifica riscos reais com base em OWASP Top 10, PortSwigger e WSTG, sem exploração destrutiva.
---

## Objective

Run a defensive web security audit on a frontend/backend professional project. Find real exploitable risks in code, config, and application flows — prevention, correction, hardening. No attacks against external systems. No destructive exploitation. Work only on local code, configs, tests, and project docs.

References:
- OWASP Top 10
- OWASP Web Security Testing Guide
- PortSwigger Web Security Academy

## When to use

- Security review before release or merge
- When onboarding to a new project and assessing risk posture
- After adding auth, payments, PII handling, or third-party integrations
- When responding to a reported vulnerability
- Periodic hardening / security debt reduction

## Scope

### Required categories (10 areas)

1. **Authentication** — login, logout, password reset, refresh token, session expiration; frontend token storage; JWT (validation, expiry, weak secret, trusted claims); user enumeration; brute force without rate limiting

2. **Authorization & access control** — Broken Access Control, IDOR/BOLA, endpoints trusting only the frontend, client-side role checks, cross-user/tenant access, exposed admin routes

3. **Input validation & injection** — SQL/NoSQL injection, command injection, template injection, path traversal, unsafe deserialization, dangerous eval/Function/innerHTML/dangerouslySetInnerHTML usage

4. **XSS & frontend security** — Reflected/stored/DOM XSS, untrusted HTML rendering, absent/incorrect sanitization, missing/weak CSP, secrets in client bundle, insecure localStorage/sessionStorage for sensitive data

5. **CSRF, CORS & cookies** — Cookies without HttpOnly/Secure/SameSite, overly permissive CORS, state-changing endpoints without CSRF protection, credentials accepted from wrong origins

6. **Uploads, files & media** — Weak type/size validation, improper public storage, path traversal, insecure file serving, missing antivirus/sandbox when needed

7. **SSRF & external calls** — fetch/axios/backend with user-controlled URLs, missing allowlist, access to metadata/internal network, unsafe redirects

8. **Secrets, config & supply chain** — Committed secrets, exposed .env, keys in frontend bundle, vulnerable dependencies, suspicious post-install scripts, insecure Docker/configs, missing security headers

9. **Logs, errors & observability** — Exposed stack traces, logs containing tokens/passwords/PII, error messages revealing internal structure, missing audit logging for critical security events

10. **Business logic** — Payment/subscription/permission bypass, price/plan/role/ownerId/userId/tenantId tampering, trusting client-sent fields, state changes without server-side validation

### Does not cover

- Style, formatting, or refactors without security impact
- Speculative findings without code evidence
- Infrastructure-level network scanning

## Workflow

### Phase 1 — Architecture mapping

Before reviewing code, map:

- Frontend stack + backend stack
- Public vs private routes
- All endpoints (auth, CRUD, admin, webhooks)
- Auth/session mechanism (JWT, sessions, OAuth, cookies)
- User/permission model
- Data storage (SQL, NoSQL, files, S3)
- External integrations (APIs, webhooks, OAuth providers, payment gateways)

### Phase 2 — Risk-based code review

Review by **risk flow**, not file-by-file:

1. Authentication flow
2. Authorization enforcement
3. Input processing endpoints
4. Data output / rendering
5. File handling
6. External communication
7. Config / secrets exposure
8. Error handling / logging

### Phase 3 — Finding criteria

Each finding must contain:

- **Severity**: P0 (Critical), P1 (High), P2 (Medium), P3 (Low/Hardening)
- **Confidence**: High / Medium / Low
- **Exploitability**: Immediate / Requires auth / Requires privileged user / Requires user interaction / Theoretical
- **Category**: OWASP category or PortSwigger class
- **Location**: file, function, route, or component
- **Evidence**: code snippet or observed behavior
- **Impact**: what a malicious user could do
- **Fix**: objective and actionable remediation
- **Validation**: how to confirm it's fixed

Rules:
- Every finding must include evidence. If evidence is insufficient, classify it as **Needs confirmation**.
- If a P0/P1 critical finding is discovered, **highlight it immediately and continue** the full audit — highlight and continue unless unsafe.

### Phase 4 — Output format

```
# WebSec Audit — [Project name]

## Executive Summary

- Risk level:
- Top findings:
- Weakest areas:

## Application Map

- Frontend:
- Backend:
- Auth/session:
- DB/storage:
- Integrations:
- Public surfaces:

## Findings

### P0 — Critical

[findings]

### P1 — High

[findings]

### P2 — Medium

[findings]

### P3 — Low / Hardening

[findings]

## False Positives / Dismissed Items

List items that looked like risks but aren't. Explain why.

## Recommended Tests

Manual or automated tests to validate findings.

## Remediation Plan

Order by impact + effort:

1. Fix now
2. Fix this sprint
3. Future hardening

## Open Questions

Only questions that block confirming a real risk.
```

### Phase 5 — Fix (optional)

If the user asks for fixes after the report:

1. Fix in severity order (P0 → P1 → P2 → P3)
2. One fix per finding, validated
3. Report resolved/pending items
