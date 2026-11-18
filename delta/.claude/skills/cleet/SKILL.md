---
name: cleet
description: Clean up after `/fleet` and `/scout`. Archive the merged fork threads, which removes their checkouts, and delete their merged branches. Manual only.
disable-model-invocation: true
---
Clean up the forks of this repo. Keep `<main checkout>/.agents/fleet/`: the next fleet uses `SETUP.md` again.
Never lose work that is not merged. If a check or a command fails, keep the item and tell the user why.

## 1. Threads

Run `"$DELTA_CLI" --json thread list`. Select the threads that are not archived and whose name starts with `fleet-` or `scout-`.
Keep a thread if its `status` is `streaming`: its agent runs.
For each other thread, find the checkout path in its last report. Write the id of the thread in the pattern:

```sh
"$DELTA_CLI" thread show <id> --format full | grep -o 'checkout: <id> [^"\\]*' | tail -n 1
```

The path is the text after the id. A report line of another thread does not match, so the thread is kept.

Keep the thread if one of these is true:
- No path is found, or the path does not exist.
- `git -C <checkout> status --porcelain` prints a line: the fork has changes that are not committed.
- `git merge-base --is-ancestor "$(git -C <checkout> rev-parse HEAD)" HEAD` fails in this checkout: the fork has commits that this branch does not have.
Archive each other thread with `"$DELTA_CLI" thread archive <id>`.
Tell the user that `"$DELTA_CLI" thread unarchive <id>` restores an archived thread.

## 2. Branches

For each branch in `git branch --list 'fleet-*' 'scout-*'` that has no kept thread, run `git branch -d <branch>`. Do not use `-D`.

## 3. Report

Show a table: item, type (thread, branch), status (archived, deleted, kept), reason.
