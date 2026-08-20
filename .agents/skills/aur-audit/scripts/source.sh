#!/usr/bin/env bash
# aur-audit: Source URL validation
# Usage: ./source.sh <PKGBUILD_PATH>
set -euo pipefail

PKGBUILD="${1:?Usage: source.sh <PKGBUILD_PATH>}"

if [[ ! -f "$PKGBUILD" ]]; then
  echo "ERROR: PKGBUILD not found at $PKGBUILD"
  exit 1
fi

echo "=== SOURCE CHECK ==="
echo ""

# Extract source lines (handle multi-line arrays)
SOURCES=$(awk '/^source=\(/,/^\)/' "$PKGBUILD" | grep -E 'https?://' || true)

if [[ -z "$SOURCES" ]]; then
  echo "⚠️  No source URLs found"
  exit 0
fi

ISSUES=0

# Check for IP addresses
IPS=$(echo "$SOURCES" | grep -nE 'https?://[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+' || true)
if [[ -n "$IPS" ]]; then
  echo "🔴 P0 CRITICAL: IP address in source URL"
  echo "$IPS" | sed "s/^/  /"
  echo ""
  ((ISSUES++))
fi

# Check for shortened URLs
SHORT=$(echo "$SOURCES" | grep -nE 'bit\.ly|tinyurl|t\.co|goo\.gl|is\.gd|v\.gd' || true)
if [[ -n "$SHORT" ]]; then
  echo "🔴 P0 CRITICAL: Shortened URL in source"
  echo "$SHORT" | sed "s/^/  /"
  echo ""
  ((ISSUES++))
fi

# Check for non-HTTPS
HTTP=$(echo "$SOURCES" | grep -nE 'http://' || true)
if [[ -n "$HTTP" ]]; then
  echo "🟠 P1 HIGH: HTTP (not HTTPS) source"
  echo "$HTTP" | sed "s/^/  /"
  echo ""
  ((ISSUES++))
fi

# Check for sources outside known hosting
echo "$SOURCES" | grep -v -E '(github\.com|gitlab\.com|codeberg\.org|sourceforge\.net|pypi\.org|crates\.io|npmjs\.org|npmjs\.com|rubygems\.org|pkg\.go\.dev|mirrors\.)' | while read -r line; do
  if [[ -n "$line" ]]; then
    echo "🟡 P2 MEDIUM: Source not from known hosting"
    echo "  $line"
    echo ""
  fi
done || true

# Check for sources in prepare() that differ from source array
PREPARE_SOURCES=$(awk '/^prepare\(\)/,/^}/' "$PKGBUILD" | grep -E 'curl|wget' || true)
if [[ -n "$PREPARE_SOURCES" ]]; then
  echo "🟠 P1 HIGH: Downloads in prepare() outside source array"
  echo "$PREPARE_SOURCES" | sed "s/^/  /"
  echo ""
  ((ISSUES++))
fi

if [[ $ISSUES -eq 0 ]]; then
  echo "✅ No source issues found"
fi

echo ""
echo "Source URLs found:"
echo "$SOURCES" | sed "s/^/  /"
