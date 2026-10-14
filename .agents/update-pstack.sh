#!/bin/sh
# Update pstack skills in ~/.agents/skills from the pinned clone.
# Usage: sh ~/.agents/update-pstack.sh
set -eu
clone="$HOME/.agents/pstack-claude"
dest="$HOME/.agents/skills"
[ -d "$clone/.git" ] || { echo "clone missing: $clone" >&2; exit 1; }
git -C "$clone" pull --ff-only
cp -a "$clone/plugins/pstack/skills/." "$dest/"
echo "pstack synced: $(cat "$clone/VERSION")"
