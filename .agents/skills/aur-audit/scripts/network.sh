#!/usr/bin/env bash
# aur-audit: Network call detection
# Usage: ./network.sh <PKGBUILD_PATH>
set -euo pipefail

PKGBUILD="${1:?Usage: network.sh <PKGBUILD_PATH>}"

if [[ ! -f "$PKGBUILD" ]]; then
  echo "ERROR: PKGBUILD not found at $PKGBUILD"
  exit 1
fi

echo "=== NETWORK CHECK ==="
echo ""

ISSUES=0

# Extract functions
extract_func() {
  local func_name="$1"
  awk "/^${func_name}\(\)/,/^}/" "$PKGBUILD" 2>/dev/null || true
}

for FUNC in prepare build package install post_install; do
  BODY=$(extract_func "$FUNC")
  if [[ -z "$BODY" ]]; then
    continue
  fi

  # curl/wget in function
  NET=$(echo "$BODY" | grep -nE 'curl|wget|fetch' || true)
  if [[ -n "$NET" ]]; then
    echo "🟠 P1 HIGH: Network call in $FUNC()"
    echo "$NET" | sed "s/^/  /"
    echo ""
    ((ISSUES++))

    # Check for pipe to shell
    PIPE=$(echo "$BODY" | grep -nE '\|\s*(bash|sh|zsh|fish)' || true)
    if [[ -n "$PIPE" ]]; then
      echo "🔴 P0 CRITICAL: curl/wget piped to shell in $FUNC()"
      echo "$PIPE" | sed "s/^/  /"
      echo ""
      ((ISSUES++))
    fi

    # Check for background download
    BG=$(echo "$BODY" | grep -nE '&>/dev/null|&\s*$|nohup|disown' || true)
    if [[ -n "$BG" ]]; then
      echo "🟠 P1 HIGH: Background network activity in $FUNC()"
      echo "$BG" | sed "s/^/  /"
      echo ""
      ((ISSUES++))
    fi
  fi
done

# Also check global scope (outside functions)
GLOBAL=$(awk '/^[a-zA-Z_][a-zA-Z0-9_]*\(\)/{found=1} found{next} !found' "$PKGBUILD" | grep -E 'curl|wget' || true)
if [[ -n "$GLOBAL" ]]; then
  echo "🟡 P2 MEDIUM: Network call outside functions"
  echo "$GLOBAL" | sed "s/^/  /"
  echo ""
  ((ISSUES++))
fi

# Check .install files for network calls
SCRIPTDIR=$(dirname "$PKGBUILD")
for install_file in "$SCRIPTDIR"/*.install; do
  if [[ -f "$install_file" ]]; then
    INSTALL_NET=$(grep -nE 'curl|wget' "$install_file" || true)
    if [[ -n "$INSTALL_NET" ]]; then
      echo "🟠 P1 HIGH: Network call in install file: $(basename "$install_file")"
      echo "$INSTALL_NET" | sed "s/^/  /"
      echo ""
      ((ISSUES++))
    fi
  fi
done

if [[ $ISSUES -eq 0 ]]; then
  echo "✅ No network issues found"
fi
