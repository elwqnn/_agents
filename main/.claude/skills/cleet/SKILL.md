---
name: cleet
description: Clean up after `/fleet` and `/scout`. Archive the merged fleet and scout sessions, which removes their worktrees, and delete their merged branches. Manual only.
disable-model-invocation: true
---
Clean up the fleet and scout sessions of this repo. Keep `<main checkout>/.agents/fleet/`: the next fleet uses `SETUP.md` again.
Never lose work that is not merged. If a check or a command fails, keep the item and tell the user why.
Keep each session, worktree or branch whose path or name does not match `^[A-Za-z0-9._/-]+$`, and report it.

## 1. Sessions

If `list_sessions` is not available, go to step 2.
Call `list_sessions` with `limit: 100`. Select the sessions of this repo whose name or branch contains `fleet-` or `scout-`.
Keep a session if it is working: its agent runs.
For each other session, read its worktree path and its branch with `get_session`. If `get_session` does not answer clearly, keep the session.
If the session has a worktree, keep it if one of these is true:
- `git -C '<worktree>' status --porcelain` prints a line: the session has changes that are not committed.
- `git merge-base --is-ancestor "$(git -C '<worktree>' rev-parse HEAD)" HEAD` fails: the session has commits that this branch does not have.
If the session has no worktree, keep it if `git merge-base --is-ancestor 'refs/heads/<branch>' HEAD` fails.
Archive each other session with `archive_session`. The app removes its worktree.
Tell the user that the Archived list of the app restores a session.

## 2. Worktrees and branches

Run `git worktree prune`.
For each worktree in `git worktree list` whose branch contains `fleet-` or `scout-` and has no kept session, run `git worktree remove '<path>'`. Skip this checkout. Do not use `--force`.
For each branch in `git branch --list '*fleet-*' '*scout-*'` that has no kept session, run `git branch -d '<branch>'`. Do not use `-D`.

## 3. Report

Show a table: item, type (session, worktree, branch), status (archived, removed, deleted, kept), reason.
