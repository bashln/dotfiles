#!/bin/sh
# bulk-add-guard: refuse a commit that looks like an accidental bulk add.
# Reads staged paths (one per line) on stdin. Exits 1 with a report.
# Env: DOTFILES_MAX_STAGED (default 300), DOTFILES_ALLOW_BULK=1 to ignore the count.
set -eu
max=${DOTFILES_MAX_STAGED:-300}
junk='(^|/)(node_modules|\.cache|Cache|Code Cache|GPUCache|DawnGraphiteCache|DawnWebGPUCache|workspaceStorage|globalStorage|Crashpad|Local Storage|Session Storage|Service Worker|IndexedDB|blob_storage)/|\.(sqlite|sqlite-shm|sqlite-wal|db|db-wal|db-shm|log)$|^\.config/1Password/|^\.anydesk/|^\.local/(share|state|lib)/|^\.mozilla/|^\.config/Code/User/(globalStorage|workspaceStorage|History|Cache)/'

input=$(cat || true)
count=$(printf '%s\n' "$input" | grep -c . || true)
bad=$(printf '%s\n' "$input" | grep -E "$junk" || true)
status=0

if [ -n "$bad" ]; then
  echo "bulk-add-guard: caminhos que nunca deveriam estar no repo:" >&2
  printf '%s\n' "$bad" | head -20 >&2
  extra=$(printf '%s\n' "$bad" | grep -c . || true)
  [ "$extra" -gt 20 ] && echo "  ... e mais $((extra - 20))" >&2
  echo "Remova-os com: git restore --staged <caminho>" >&2
  status=1
fi

if [ "$count" -gt "$max" ] && [ "${DOTFILES_ALLOW_BULK:-0}" != "1" ]; then
  echo "bulk-add-guard: $count arquivos staged (limite $max). Provavelmente um 'git add -A'." >&2
  echo "Stage por caminho explicito. Se for intencional: DOTFILES_ALLOW_BULK=1 git commit ..." >&2
  status=1
fi

exit $status
