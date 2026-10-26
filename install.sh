#!/bin/sh
# Usage: install.sh <dev|figma|godot> <dest>
# dest: a repo root, or a .claude directory (~/.claude) for the global config.
set -eu

[ $# -eq 2 ] || { echo "usage: $0 <dev|figma|godot> <dest>" >&2; exit 1; }
src="$(cd "$(dirname "$0")" && pwd)/$1"
dest="${2%/}"
[ -d "$src/.claude" ] || { echo "unknown template: $1" >&2; exit 1; }

if [ "$(basename "$dest")" = .claude ]; then
  claude="$dest"
else
  claude="$dest/.claude"
fi
mkdir -p "$claude"

rsync -a --exclude .DS_Store "$src/.claude/agents" "$src/.claude/rules" "$src/.claude/skills" "$claude/"
[ "$claude" = "$dest" ] || echo '*' > "$claude/.gitignore"

if [ -f "$claude/settings.json" ]; then
  jq -s '.[0] * .[1]' "$claude/settings.json" "$src/.claude/settings.json" > "$claude/settings.json.tmp"
  mv "$claude/settings.json.tmp" "$claude/settings.json"
else
  cp "$src/.claude/settings.json" "$claude/"
fi

cp "$src/AGENTS.md" "$dest/AGENTS.md"

echo "$1 -> $dest"
