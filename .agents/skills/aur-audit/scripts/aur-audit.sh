#!/usr/bin/env bash
# aur-audit: Main runner script
# Usage: ./aur-audit.sh <PKGBUILD_PATH>
#    or: ./aur-audit.sh <package-name> (searches yay/paru cache)
set -euo pipefail

SCRIPTDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PKGBUILD="${1:?Usage: aur-audit.sh <PKGBUILD_PATH|package-name>}"

# Scripts are in the same directory as this script
SCRIPTS_DIR="$SCRIPTDIR"

# If argument is not a file, search for it in cache
if [[ ! -f "$PKGBUILD" ]]; then
  PKGNAME="$PKGBUILD"
  echo "Searching for PKGBUILD for package: $PKGNAME"
  echo ""

  FOUND=""
  for cache in "$HOME/.cache/yay" "$HOME/.cache/paru"; do
    if [[ -f "$cache/$PKGNAME/PKGBUILD" ]]; then
      FOUND="$cache/$PKGNAME/PKGBUILD"
      break
    fi
  done

  if [[ -z "$FOUND" ]]; then
    echo "ERROR: PKGBUILD not found for $PKGNAME"
    echo "Searched:"
    echo "  ~/.cache/yay/$PKGNAME/PKGBUILD"
    echo "  ~/.cache/paru/$PKGNAME/PKGBUILD"
    exit 1
  fi

  PKGBUILD="$FOUND"
  echo "Found: $PKGBUILD"
  echo ""
fi

# Extract package info
PKGNAME=$(grep -E '^pkgname=' "$PKGBUILD" | cut -d= -f2 | tr -d '"' || echo "unknown")
PKGVER=$(grep -E '^pkgver=' "$PKGBUILD" | cut -d= -f2 || echo "unknown")
PKGREL=$(grep -E '^pkgrel=' "$PKGBUILD" | cut -d= -f2 || echo "unknown")

echo "╔══════════════════════════════════════════════════╗"
echo "║           aur-audit: $PKGNAME $PKGVER-$PKGREL"
echo "╚══════════════════════════════════════════════════╝"
echo ""

CRITICAL=0
HIGH=0
MEDIUM=0
LOW=0

# Run all checks
for check in source network filesystem obfuscation hooks maintainer; do
  OUTPUT=$("$SCRIPTS_DIR/$check.sh" "$PKGBUILD" 2>&1) || true
  echo "$OUTPUT"
  echo ""

  # Count issues by severity
  CRITICAL=$((CRITICAL + $(echo "$OUTPUT" | grep -c "P0 CRITICAL" || true)))
  HIGH=$((HIGH + $(echo "$OUTPUT" | grep -c "P1 HIGH" || true)))
  MEDIUM=$((MEDIUM + $(echo "$OUTPUT" | grep -c "P2 MEDIUM" || true)))
  LOW=$((LOW + $(echo "$OUTPUT" | grep -c "P3 LOW" || true)))
done

# Summary
echo "╔══════════════════════════════════════════════════╗"
echo "║                    SUMMARY                       ║"
echo "╠══════════════════════════════════════════════════╣"
echo "║  🔴 P0 Critical: $CRITICAL"
echo "║  🟠 P1 High:     $HIGH"
echo "║  🟡 P2 Medium:   $MEDIUM"
echo "║  🟢 P3 Low:      $LOW"
echo "╠══════════════════════════════════════════════════╣"

if [[ $CRITICAL -gt 0 ]]; then
  echo "║  VERDICT: 🔴 MALICIOUS — DO NOT INSTALL"
elif [[ $HIGH -gt 0 ]]; then
  echo "║  VERDICT: ⚠️  WARN — Review findings before installing"
elif [[ $MEDIUM -gt 0 ]]; then
  echo "║  VERDICT: ⚠️  WARN — Minor concerns, likely safe"
else
  echo "║  VERDICT: ✅ CLEAN — No issues found"
fi

echo "╚══════════════════════════════════════════════════╝"
