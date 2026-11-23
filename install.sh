#!/bin/sh
# Usage: install.sh <main|figma|godot> <dest>. main is the base. figma and godot add to it.
# dest: a repo root, or a .claude directory (~/.claude). Install main first. Install the overlay in the same dest as main, or in the repo when main is in ~/.claude. Install the overlay again after each main install in that dest.
set -eu

[ $# -eq 2 ] || { echo "usage: $0 <main|figma|godot> <dest>" >&2; exit 1; }
src="$(cd "$(dirname "$0")" && pwd)/$1"
dest="${2%/}"
[ -d "$src/.claude" ] || { echo "unknown template: $1" >&2; exit 1; }

if [ "$(basename "$dest")" = .claude ]; then
  claude="$dest"
else
  claude="$dest/.claude"
fi
mkdir -p "$claude"

[ "$claude" = "$dest" ] || echo '*' > "$claude/.gitignore"
rsync -a --no-perms --exclude .DS_Store --exclude /settings.json --exclude /.gitignore "$src/.claude/" "$claude/"

if [ -f "$src/.claude/settings.json" ]; then
  if [ -f "$claude/settings.json" ]; then
    jq -s '.[0] * .[1]' "$claude/settings.json" "$src/.claude/settings.json" > "$claude/settings.json.tmp"
    mv "$claude/settings.json.tmp" "$claude/settings.json"
  else
    cp "$src/.claude/settings.json" "$claude/"
  fi
fi

if [ -f "$src/AGENTS.md" ]; then
  cp "$src/AGENTS.md" "$dest/AGENTS.md"
fi

echo "$1 -> $dest"
