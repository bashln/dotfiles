#!/usr/bin/env bash
# aur-audit: Maintainer analysis
# Usage: ./maintainer.sh <PKGBUILD_PATH>
set -euo pipefail

PKGBUILD="${1:?Usage: maintainer.sh <PKGBUILD_PATH>}"

if [[ ! -f "$PKGBUILD" ]]; then
  echo "ERROR: PKGBUILD not found at $PKGBUILD"
  exit 1
fi

echo "=== MAINTAINER CHECK ==="
echo ""

# Extract maintainer info
MAINTAINER=$(grep -E '^# Maintainer:' "$PKGBUILD" | head -1 || true)
CONTRIBUTORS=$(grep -E '^# Contributor:' "$PKGBUILD" || true)

if [[ -n "$MAINTAINER" ]]; then
  echo "Maintainer: $MAINTAINER"
else
  echo "⚠️  No Maintainer line found"
fi

if [[ -n "$CONTRIBUTORS" ]]; then
  echo "Contributors:"
  echo "$CONTRIBUTORS" | sed "s/^/  /"
fi

echo ""

# Extract package version
PKGVER=$(grep -E '^pkgver=' "$PKGBUILD" | cut -d= -f2 || true)
PKGREL=$(grep -E '^pkgrel=' "$PKGBUILD" | cut -d= -f2 || true)
echo "Version: ${PKGVER:-unknown}-${PKGREL:-unknown}"

# Check for version in source URL (detect version bumping)
if [[ -n "$PKGVER" ]]; then
  VER_IN_SOURCE=$(grep -E "pkgver|${PKGVER}" "$PKGBUILD" | grep -E 'source=' | wc -l || true)
  if [[ "$VER_IN_SOURCE" -gt 0 ]]; then
    echo "ℹ️  Version variable used in source URLs (standard practice)"
  fi
fi

echo ""

# Red flags for maintainer patterns
echo "Maintainer red flags:"

# Check for common AUR package naming (potential typosquatting)
PKGNAME=$(grep -E '^pkgname=' "$PKGBUILD" | cut -d= -f2 | tr -d '"' || true)
if [[ -n "$PKGNAME" ]]; then
  # Check for extra hyphens or characters
  if echo "$PKGNAME" | grep -qE -- '--$|^--|[^a-z0-9+.-]'; then
    echo "🟡 P2 MEDIUM: Package name contains unusual characters: $PKGNAME"
  fi

  # Check for common legitimate packages that might be impersonated
  case "$PKGNAME" in
    vim|emacs|git|node|npm|yarn|python|rust|go|docker|kubectl|terraform)
      echo "🟡 P2 MEDIUM: Package name matches well-known software: $PKGNAME"
      echo "  Verify this is the correct AUR package, not a typosquat"
      ;;
  esac
fi

# Check if source uses pkgver (standard) vs hardcoded version
HARDCODED=$(grep -E 'source=' "$PKGBUILD" | grep -v 'pkgver' | grep -E '[0-9]+\.[0-9]+\.[0-9]+' | wc -l || true)
if [[ "$HARDCODED" -gt 0 ]]; then
  echo "🟡 P2 MEDIUM: Hardcoded version in source URL (may indicate version bumping)"
fi

# Check for multiple source arrays (unusual)
SOURCE_COUNT=$(grep -cE '^source=' "$PKGBUILD" || true)
if [[ "$SOURCE_COUNT" -gt 1 ]]; then
  echo "🟡 P2 MEDIUM: Multiple source arrays defined"
fi

echo ""
echo "Note: For full maintainer verification, check the AUR web page:"
echo "  https://aur.archlinux.org/packages/$PKGNAME"
