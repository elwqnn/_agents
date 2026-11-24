#!/bin/sh
# Usage: install.sh [--link] <main|figma|godot> <dest>. main is the base. figma and godot add to it.
# dest: a repo root, or a .claude directory (~/.claude). Install main first. Install the overlay in the same dest as main, or in the repo when main is in ~/.claude. Install the overlay again after each main install in that dest.
# --link: make symlinks to this checkout. Do not use it in a repo that tracks .claude, or for two templates in the same dest. A repo gets a copy of the rules, because Claude Code does not load a project rule that links outside the repo.
set -eu

link=
if [ "${1:-}" = --link ]; then link=1; shift; fi
[ $# -eq 2 ] || { echo "usage: $0 [--link] <main|figma|godot> <dest>" >&2; exit 1; }
src="$(cd "$(dirname "$0")" && pwd)/$1"
dest="${2%/}"
[ -d "$src/.claude" ] || { echo "unknown template: $1" >&2; exit 1; }

if [ "$(basename "$dest")" = .claude ]; then
  claude="$dest"
else
  claude="$dest/.claude"
fi
mkdir -p "$claude"

[ "$claude" = "$dest" ] || [ -n "$(git -C "$dest" ls-files .claude 2>/dev/null)" ] || echo '*' > "$claude/.gitignore"

symlink() {
  [ "$1" -ef "$2" ] && return
  if [ -e "$2" ] && ! diff -r "$1" "$2" >&2; then
    echo "not linked, content differs: $2" >&2
    exit 1
  fi
  rm -rf "$2"
  mkdir -p "$(dirname "$2")"
  ln -s "$1" "$2"
}

exclude=
if [ -n "$link" ]; then
  exclude="--exclude /agents --exclude /skills"
  [ "$claude" != "$dest" ] || exclude="$exclude --exclude /rules"
  for path in "$src"/.claude/agents "$src"/.claude/rules "$src"/.claude/skills/*; do
    [ -e "$path" ] || continue
    [ "$claude" = "$dest" ] || [ "$path" != "$src/.claude/rules" ] || continue
    symlink "$path" "$claude/${path#"$src/.claude/"}"
  done
fi
rsync -a --no-perms --exclude .DS_Store --exclude /settings.json --exclude /.gitignore $exclude "$src/.claude/" "$claude/"

if [ -f "$src/.claude/settings.json" ]; then
  if [ -f "$claude/settings.json" ]; then
    jq -s '.[0] * .[1]' "$claude/settings.json" "$src/.claude/settings.json" > "$claude/settings.json.tmp"
    mv "$claude/settings.json.tmp" "$claude/settings.json"
  else
    cp "$src/.claude/settings.json" "$claude/"
  fi
fi

if [ -f "$src/AGENTS.md" ]; then
  if [ -n "$link" ]; then
    symlink "$src/AGENTS.md" "$dest/AGENTS.md"
  else
    rsync -a --no-perms "$src/AGENTS.md" "$dest/"
  fi
fi

echo "$1 -> $dest"
