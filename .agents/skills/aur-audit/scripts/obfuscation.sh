#!/usr/bin/env bash
# aur-audit: Obfuscation detection
# Usage: ./obfuscation.sh <PKGBUILD_PATH>
set -euo pipefail

PKGBUILD="${1:?Usage: obfuscation.sh <PKGBUILD_PATH>}"

if [[ ! -f "$PKGBUILD" ]]; then
  echo "ERROR: PKGBUILD not found at $PKGBUILD"
  exit 1
fi

echo "=== OBFUSCATION CHECK ==="
echo ""

ISSUES=0

# base64 decode + execute
B64=$(grep -nE 'base64\s+(-d|--decode)|base64\s+-d\s*\|' "$PKGBUILD" || true)
if [[ -n "$B64" ]]; then
  echo "🔴 P0 CRITICAL: base64 decode detected"
  echo "$B64" | sed "s/^/  /"
  echo ""
  ((ISSUES++))
fi

# eval with command substitution
EVAL=$(grep -nE 'eval\s*\$|eval\s*\(|eval\s+"[^"]*\$' "$PKGBUILD" || true)
if [[ -n "$EVAL" ]]; then
  echo "🔴 P0 CRITICAL: eval with variable substitution"
  echo "$EVAL" | sed "s/^/  /"
  echo ""
  ((ISSUES++))
fi

# printf with hex escapes (potential shellcode)
HEX=$(grep -nE 'printf\s+["\x27].*\\\\x[0-9a-fA-F]{2}' "$PKGBUILD" || true)
if [[ -n "$HEX" ]]; then
  echo "🔴 P0 CRITICAL: Hex-encoded string in printf"
  echo "$HEX" | sed "s/^/  /"
  echo ""
  ((ISSUES++))
fi

# xxd reverse (hex dump to binary)
XXD=$(grep -nE 'xxd\s+-r' "$PKGBUILD" || true)
if [[ -n "$XXD" ]]; then
  echo "🟠 P1 HIGH: xxd reverse (hex to binary)"
  echo "$XXD" | sed "s/^/  /"
  echo ""
  ((ISSUES++))
fi

# Compressed payload execution
COMPRESSED=$(grep -nE '(gzip|xz|zstd|bzip2)\s+-d.*\|.*\b(bash|sh|exec)' "$PKGBUILD" || true)
if [[ -n "$COMPRESSED" ]]; then
  echo "🔴 P0 CRITICAL: Compressed payload decompression + execution"
  echo "$COMPRESSED" | sed "s/^/  /"
  echo ""
  ((ISSUES++))
fi

# Indirect variable expansion (hides command)
INDIRECT=$(grep -nF '${!' "$PKGBUILD" 2>/dev/null || true)
if [[ -n "$INDIRECT" ]]; then
  echo "🟠 P1 HIGH: Indirect variable expansion (possible obfuscation)"
  echo "$INDIRECT" | sed "s/^/  /"
  echo ""
  ((ISSUES++))
fi

# Here-string to shell
HEREDOC=$(grep -nE '<<<.*\$(' "$PKGBUILD" 2>/dev/null || true)
if [[ -n "$HEREDOC" ]]; then
  echo "🟠 P1 HIGH: Here-string with command substitution to shell"
  echo "$HEREDOC" | sed "s/^/  /"
  echo ""
  ((ISSUES++))
fi

# Multiple layers of escaping (sign of obfuscation)
MULTI_ESC=$(grep -nE '\\\\{4,}' "$PKGBUILD" || true)
if [[ -n "$MULTI_ESC" ]]; then
  echo "🟡 P2 MEDIUM: Heavy escaping detected (possible obfuscation)"
  echo "$MULTI_ESC" | sed "s/^/  /"
  echo ""
  ((ISSUES++))
fi

# python/perl/ruby one-liner execution
SCRIPT_EXEC=$(grep -nE '(python|perl|ruby|node)\s+-e\s' "$PKGBUILD" 2>/dev/null || true)
if [[ -n "$SCRIPT_EXEC" ]]; then
  echo "🟡 P2 MEDIUM: Script language one-liner execution"
  echo "$SCRIPT_EXEC" | sed "s/^/  /"
  echo ""
  ((ISSUES++))
fi

if [[ $ISSUES -eq 0 ]]; then
  echo "✅ No obfuscation issues found"
fi
