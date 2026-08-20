#!/usr/bin/env bash
# aur-audit: Filesystem access to sensitive directories
# Usage: ./filesystem.sh <PKGBUILD_PATH>
set -euo pipefail

PKGBUILD="${1:?Usage: filesystem.sh <PKGBUILD_PATH>}"

if [[ ! -f "$PKGBUILD" ]]; then
  echo "ERROR: PKGBUILD not found at $PKGBUILD"
  exit 1
fi

echo "=== FILESYSTEM CHECK ==="
echo ""

ISSUES=0

# Sensitive directory patterns (atomic-lockfile targets)
PATTERNS=(
  '\.ssh'
  '\.gnupg'
  '\.config/chromium'
  '\.config/google-chrome'
  '\.config/google-chrome-beta'
  '\.config/google-chrome-unstable'
  '\.mozilla/firefox'
  '\.config/BraveSoftware'
  '\.config/vivaldi'
  '\.config/opera'
  'cookies'
  'keychain'
  '\.aws/credentials'
  '\.azure/accessTokens'
  '\.azure/azureProfile'
  '\.config/gcloud'
  '\.kube/config'
  'hashicorp'
  'vault'
  '\.docker/config.json'
  '\.npmrc'
  '\.netrc'
  '\.pypirc'
  '\.gem/credentials'
  '\.ssh/id_'
  '\.ssh/authorized_keys'
  '\.ssh/known_hosts'
  'Slack'
  'Discord'
  'Telegram'
  'Teams'
)

# Build grep pattern
GREP_PATTERN=$(IFS='|'; echo "${PATTERNS[*]}")

# Search in PKGBUILD
HITS=$(grep -nE "$GREP_PATTERN" "$PKGBUILD" 2>/dev/null || true)
if [[ -n "$HITS" ]]; then
  echo "🔴 P0 CRITICAL: Access to sensitive filesystem paths"
  echo "$HITS" | sed "s/^/  /"
  echo ""
  ((ISSUES++))
fi

# Search in .install files
SCRIPTDIR=$(dirname "$PKGBUILD")
for install_file in "$SCRIPTDIR"/*.install; do
  if [[ -f "$install_file" ]]; then
    INSTALL_HITS=$(grep -nE "$GREP_PATTERN" "$install_file" 2>/dev/null || true)
    if [[ -n "$INSTALL_HITS" ]]; then
      echo "🔴 P0 CRITICAL: Access to sensitive paths in $(basename "$install_file")"
      echo "$INSTALL_HITS" | sed "s/^/  /"
      echo ""
      ((ISSUES++))
    fi
  fi
done

# Check for reading sensitive files
READ_PATTERNS=(
  'cat.*\.ssh'
  'cat.*cookies'
  'cat.*credentials'
  'cat.*token'
  'cat.*\.netrc'
  'cat.*\.npmrc'
  'cat.*keychain'
  'cat.*vault'
  'cp.*\.ssh'
  'cp.*cookies'
  'mv.*\.ssh'
  'mv.*cookies'
)

for pat in "${READ_PATTERNS[@]}"; do
  READ_HITS=$(grep -nE "$pat" "$PKGBUILD" "$SCRIPTDIR"/*.install 2>/dev/null || true)
  if [[ -n "$READ_HITS" ]]; then
    echo "🔴 P0 CRITICAL: Sensitive file read/copy detected"
    echo "$READ_HITS" | sed "s/^/  /"
    echo ""
    ((ISSUES++))
  fi
done

# Check for data exfiltration patterns
EXFIL_PATTERNS=(
  'curl.*-d.*@'
  'wget.*--post-file'
  'curl.*--data-binary'
  'nc\s+-'
  'ncat'
  'socat'
  'python.*socket'
  'perl.*socket'
)

for pat in "${EXFIL_PATTERNS[@]}"; do
  EXFIL_HITS=$(grep -nE "$pat" "$PKGBUILD" || true)
  if [[ -n "$EXFIL_HITS" ]]; then
    echo "🔴 P0 CRITICAL: Possible data exfiltration"
    echo "$EXFIL_HITS" | sed "s/^/  /"
    echo ""
    ((ISSUES++))
  fi
done

if [[ $ISSUES -eq 0 ]]; then
  echo "✅ No filesystem issues found"
fi
