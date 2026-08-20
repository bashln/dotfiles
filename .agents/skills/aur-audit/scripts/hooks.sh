#!/usr/bin/env bash
# aur-audit: Post-install hooks and persistence detection
# Usage: ./hooks.sh <PKGBUILD_PATH>
set -euo pipefail

PKGBUILD="${1:?Usage: hooks.sh <PKGBUILD_PATH>}"

if [[ ! -f "$PKGBUILD" ]]; then
  echo "ERROR: PKGBUILD not found at $PKGBUILD"
  exit 1
fi

echo "=== HOOKS & PERSISTENCE CHECK ==="
echo ""

ISSUES=0
SCRIPTDIR=$(dirname "$PKGBUILD")

# Check install() function content
INSTALL_FUNC=$(awk '/^install\(\)/,/^}/' "$PKGBUILD" 2>/dev/null || true)

if [[ -n "$INSTALL_FUNC" ]]; then
  # install() should only contain file copying, not execution
  EXEC_PATTERNS=(
    'chmod\s+[0-7]*x'
    'chown'
    'systemctl\s+(enable|start|daemon-reload)'
    'update-rc\.d'
    'chkconfig'
    'udevadm'
    'nohup'
    'disown'
    '&\s*$'
  )

  for pat in "${EXEC_PATTERNS[@]}"; do
    HITS=$(echo "$INSTALL_FUNC" | grep -nE "$pat" || true)
    if [[ -n "$HITS" ]]; then
      echo "🟠 P1 HIGH: Suspicious command in install()"
      echo "  Pattern: $pat"
      echo "$HITS" | sed "s/^/  /"
      echo ""
      ((ISSUES++))
    fi
  done
fi

# Check for systemd services/timers
SYSTEMD=$(grep -nE 'systemctl\s+(enable|start|daemon-reload)' "$PKGBUILD" || true)
if [[ -n "$SYSTEMD" ]]; then
  echo "🟠 P1 HIGH: systemd service enablement in PKGBUILD"
  echo "$SYSTEMD" | sed "s/^/  /"
  echo ""
  ((ISSUES++))
fi

# Check for .install file hooks
for install_file in "$SCRIPTDIR"/*.install; do
  if [[ -f "$install_file" ]]; then
    INSTALL_NAME=$(basename "$install_file")

    # post_install hook content
    POST_INSTALL=$(awk '/^post_install\(\)/,/^}/' "$install_file" 2>/dev/null || true)
    if [[ -n "$POST_INSTALL" ]]; then
      # Network in post_install
      POST_NET=$(echo "$POST_INSTALL" | grep -E 'curl|wget' || true)
      if [[ -n "$POST_NET" ]]; then
        echo "🔴 P0 CRITICAL: Network call in post_install hook"
        echo "  File: $INSTALL_NAME"
        echo "$POST_NET" | sed "s/^/  /"
        echo ""
        ((ISSUES++))
      fi

      # systemctl in post_install
      POST_SYS=$(echo "$POST_INSTALL" | grep -E 'systemctl' || true)
      if [[ -n "$POST_SYS" ]]; then
        echo "🟡 P2 MEDIUM: systemctl in post_install hook"
        echo "  File: $INSTALL_NAME"
        echo "$POST_SYS" | sed "s/^/  /"
        echo ""
        ((ISSUES++))
      fi

      # Background processes
      POST_BG=$(echo "$POST_INSTALL" | grep -E 'nohup|disown|&\s*$' || true)
      if [[ -n "$POST_BG" ]]; then
        echo "🟠 P1 HIGH: Background process in post_install hook"
        echo "  File: $INSTALL_NAME"
        echo "$POST_BG" | sed "s/^/  /"
        echo ""
        ((ISSUES++))
      fi
    fi
  fi
done

# Check for LD_PRELOAD manipulation
LD_PRELOAD=$(grep -nE 'LD_PRELOAD|/etc/ld\.so\.conf|ldconfig' "$PKGBUILD" || true)
if [[ -n "$LD_PRELOAD" ]]; then
  echo "🔴 P0 CRITICAL: LD_PRELOAD / dynamic linker manipulation"
  echo "$LD_PRELOAD" | sed "s/^/  /"
  echo ""
  ((ISSUES++))
fi

# Check for PATH manipulation
PATH_MOD=$(grep -nE '(export\s+PATH=|PATH=.*\$PATH|/etc/profile\.d/)' "$PKGBUILD" || true)
if [[ -n "$PATH_MOD" ]]; then
  echo "🟡 P2 MEDIUM: PATH manipulation"
  echo "$PATH_MOD" | sed "s/^/  /"
  echo ""
  ((ISSUES++))
fi

# Check for crontab
CRONTAB=$(grep -nE 'crontab\s+-|/etc/cron' "$PKGBUILD" || true)
if [[ -n "$CRONTAB" ]]; then
  echo "🟠 P1 HIGH: crontab modification"
  echo "$CRONTAB" | sed "s/^/  /"
  echo ""
  ((ISSUES++))
fi

# Check for udev rules
UDEV=$(grep -nE '/etc/udev/rules\.d/' "$PKGBUILD" || true)
if [[ -n "$UDEV" ]]; then
  echo "🟡 P2 MEDIUM: udev rule installation"
  echo "$UDEV" | sed "s/^/  /"
  echo ""
  ((ISSUES++))
fi

# Check for kernel modules
KMOD=$(grep -nE 'insmod|modprobe|/etc/modules-load\.d/' "$PKGBUILD" || true)
if [[ -n "$KMOD" ]]; then
  echo "🔴 P0 CRITICAL: Kernel module loading"
  echo "$KMOD" | sed "s/^/  /"
  echo ""
  ((ISSUES++))
fi

if [[ $ISSUES -eq 0 ]]; then
  echo "✅ No hook/persistence issues found"
fi
