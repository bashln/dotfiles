---
name: aur-audit
description: >
  Security audit of AUR PKGBUILD files — detects malware indicators from the
  2026 atomic-lockfile attack pattern: suspicious sources, hidden downloads,
  filesystem access to sensitive dirs, obfuscation, post-install hooks, and
  maintainer anomalies. Use when user says "audit PKGBUILD", "check AUR package",
  "is this AUR package safe", "aur-audit", or "/aur-audit".
---

## Objective

Analyze Arch User Repository (AUR) PKGBUILD files for malware indicators.
Detect the attack patterns from the 2026 atomic-lockfile campaign:
- Fake maintainer accounts taking over abandoned packages
- Hidden curl/wget downloads of infostealers
- Access to ~/.ssh, browser cookies, keychains, tokens
- Obfuscated code (base64, eval, hex encoding)
- Post-install hooks that execute malicious payloads

References:
- AUR atomic-lockfile attack (June 2026)
- Arch Linux security guidelines
- PKGBUILD manual page

## When to use

- Before installing any AUR package with `yay`, `paru`, or `makepkg`
- After a suspicious PKGBUILD behavior is reported
- Periodic audit of locally cached AUR packages
- When reviewing a PKGBUILD for the first time

## Scope

### Required checks (6 categories)

1. **Source validation** — URL domain trustworthiness, IP addresses instead of
   hostnames, shortened URLs, non-standard download paths, sources not from
   official project repositories

2. **Network calls** — curl/wget in prepare(), build(), package(), install()
   functions; downloads to unexpected locations; background network activity;
   pipes to shell (curl | bash)

3. **Filesystem access** — Access to ~/.ssh, ~/.config, ~/.local/share,
   browser profile directories, keychain files, cookie databases, token files,
   HashiCorp Vault paths, credential stores

4. **Obfuscation** — base64 encoded commands, eval, eval $(...), variable
   indirection to hide commands, hex encoding, XOR patterns, compressed/encoded
   payloads

5. **Hooks & persistence** — install() functions with post-install logic,
   systemd service/timer creation, crontab entries, nohup/disown background
   processes, LD_PRELOAD manipulation, PATH modification

6. **Maintainer signals** — Package age vs last update delta, maintainer account
   age, maintainer name changes, packages with no recent activity suddenly
   updated

### Does not cover

- Binary analysis (only PKGBUILD shell script)
- Source tarball contents (only PKGBUILD + .install files)
- AUR comments or voting

## Workflow

### Phase 1 — Locate targets

Find PKGBUILD files to audit:
- `~/.cache/yay/*/PKGBUILD` — yay cache
- `~/.cache/paru/*/PKGBUILD` — paru cache
- `/tmp/makepkg-*/*/PKGBUILD` — build dirs
- User-specified path

If no PKGBUILD found, ask user for the package name or path.

### Phase 2 — Static analysis

For each PKGBUILD, run these grep-based checks:

#### Source check
```bash
grep -nE 'source=\(|^source=' PKGBUILD
# Look for:
# - IP addresses: [0-9]+\.[0-9]+\.[0-9]+\.[0-9]+
# - Shortened URLs: bit\.ly|tinyurl|t\.co|goo\.gl
# - Non-https sources
# - Sources not matching known hosting (github.com, gitlab.com, codeberg.org, etc.)
```

#### Network check
```bash
grep -nE 'curl|wget|fetch' PKGBUILD
# Look for:
# - curl/wget in prepare/build/package functions
# - Piped to shell: | bash, | sh, | zsh
# - Downloading to hidden paths
# - Background: &>/dev/null, nohup, disown
```

#### Filesystem check
```bash
grep -nE '\.ssh|\.config|\.local/share|\.mozilla|\.config/chromium|\.config/google-chrome|cookies|keychain|\.gnupg|hashicorp|vault|\.aws|\.azure|\.gcloud' PKGBUILD
# Also check for:
# - cat/read of sensitive files
# - cp/mv of sensitive files
# - Sending file contents externally
```

#### Obfuscation check
```bash
grep -nE 'base64|eval\s|eval\(|\$\(|xxd|printf.*\\\\x|echo.*\\\\x' PKGBUILD
# Also check for:
# - Variable indirection: ${!var}, ${var:-...} used to hide commands
# - Compressed payloads: gzip -d, xz -d, zstd -d followed by execution
```

#### Hook check
```bash
grep -nE 'install\(\)|post_install|systemctl|crontab|nohup|disown|LD_PRELOAD|/etc/profile|/etc/environment' PKGBUILD
# Check .install files too:
# find . -name "*.install" -exec cat {} \;
```

#### Maintainer check
```bash
grep -nE 'Maintainer:|Contributor:' PKGBUILD
# Cross-reference with AUR web page for account age
```

### Phase 3 — Severity classification

| Severity | Description | Examples |
|----------|-------------|----------|
| 🔴 P0 CRITICAL | Active malware indicator | curl \| bash, ~/.ssh access, base64 decode + exec |
| 🟠 P1 HIGH | Suspicious pattern | Background downloads, filesystem enumeration, obfuscation |
| 🟡 P2 MEDIUM | Weak signal | Unusual source URL, network calls in build |
| 🟢 P3 LOW | Hardening | Missing checksums, weak maintainer practices |

### Phase 4 — Output format

```markdown
# aur-audit: [package-name] [version]

## Source
✅/❌ [source analysis]

## Network Calls
✅/❌ [network analysis]

## Filesystem Access
✅/❌ [filesystem analysis]

## Obfuscation
✅/❌ [obfuscation analysis]

## Hooks & Persistence
✅/❌ [hook analysis]

## Maintainer
✅/❌ [maintainer analysis]

## Findings

### P0 — Critical
[findings with evidence]

### P1 — High
[findings with evidence]

### P2 — Medium
[findings with evidence]

### P3 — Low
[findings with evidence]

## Verdict: ✅ CLEAN | ⚠️ WARN | 🔴 MALICIOUS

## Recommendations
[actionable next steps]
```

### Phase 5 — Fix (if malware found)

If P0/P1 findings exist:
1. Show exact lines with malware indicators
2. Explain what the malware would do
3. Recommend: do NOT install, report to AUR maintainers
4. If already installed: check `~/.ssh`, browser cookies, tokens for compromise

## Example

User: "audita o PKGBUILD do pacote foo no yay"

Agent:
1. Finds `~/.cache/yay/foo/PKGBUILD`
2. Runs all 6 checks
3. Reports findings with severity
4. Gives verdict and recommendations

## Boundaries

- Read-only analysis, never modifies PKGBUILDs
- Reports findings with evidence (line numbers, exact code)
- Does not execute any PKGBUILD commands
- Does not access network for maintainer lookups unless explicitly asked
