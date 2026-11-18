---
name: fleet
description: Run a list of fixes and features in parallel Delta threads, one fork per group, and merge each result into the current branch. Manual only.
disable-model-invocation: true
---
Items: $ARGUMENTS

You are the main thread. You group the items, prepare the codebase, fork one Delta thread per group, merge each result, and update `CONTEXT.md`.
Do not implement the items yourself. This `/fleet` call is the user's approval for the local merges below.
Agent files are in `<main checkout>/.agents/`. `$MAIN` is the absolute path of the checkout of this thread: it gets the `Prepare` outputs and the merges.
A fork copies the transcript of this thread. If this thread holds earlier work, tell the user in one line that a new thread makes the forks cheaper. Then continue.

## 1. Group

Read `<main checkout>/.agents/CONTEXT.md` and the code that each item touches.
Put items in the same group when they touch the same files or when one item depends on another. Keep sub-items with their parent.
Two groups must not edit the same file. Prefer fewer groups: each fork costs a full context.
Show a table: slug, items, files. Then continue. Do not wait for approval.

## 2. Setup

Run `git status`. If the tree has changes, ask the user to commit or stash them. Forks start from the last commit, and a merge needs a clean tree.
Read `<main checkout>/.agents/fleet/SETUP.md`. If it does not exist, write it. It tells how to make each fork compile and test as little as possible:
- `Prepare`: the commands to run once in `$MAIN` before the launch, and what each one makes. They make each ignored file that the checks need, such as the dependencies and the build outputs.
- `Worktree`: the commands that a fork runs first to get these outputs from `$MAIN`. Link a directory only if no tool writes in it during a build or a test. Look for caches inside it, such as `node_modules/.vite`. Copy the other directories with a copy-on-write clone: `cp -Rc` on macOS, `cp -r --reflink=auto` on Linux.
- `Checks`: one line per area: the paths, and the fastest command that checks a change there.
- `Shared resources`: the ports, databases, containers and fixed temporary paths that the checks use. Give each fork its own value from its group number `$N`. `$MAIN` uses `$N` = 0.
- `Main only`: the slow or global checks, such as end-to-end tests and the full build. Forks skip them. You run them in step 5.
Use the `Commands` section of `CONTEXT.md` as a start. When you create the file, run each `Prepare` and `Checks` command once. Keep only the commands that work. Max 40 lines.
Run the `Prepare` commands. If a command fails or is out of date, fix `SETUP.md` and tell the user.

## 3. Launch

Fork all groups first, and send the briefs after. Then all forks share the same transcript.
For each group, run `"$DELTA_CLI" --json thread fork "$DELTA_CURRENT_THREAD_ID" --name fleet-<slug>`.
Keep a table in this thread: slug, group number `$N` from 1, `thread_id`, state (running, question, reported, merged).
Before you send a brief, replace each placeholder, `$MAIN` and `$N` in it. The quoted heredoc does not expand them.
Replace `<main thread id>` with the value of `$DELTA_CURRENT_THREAD_ID` in this thread.
Do not replace `%s`, `$DELTA_CURRENT_THREAD_ID`, `$PWD`, or the `checks` and `context` values of the report: the fork fills them.
Send each brief with a quoted heredoc on stdin:

```sh
"$DELTA_CLI" thread send <thread_id> <<'BRIEF'
<the brief>
BRIEF
```

Use this brief:

````
You are the worker of group `<slug>`. The `/fleet` steps above in the transcript are for the main thread. Do not run them.
Items: <the items of the group, verbatim>
Files in scope: <files>. Do not edit the files of the other groups: <files>.
Do not create or edit a file in `<main checkout>/.agents/`.
First, run `git switch -c fleet-<slug>`. Then run: <the Worktree commands>. Use these values: <the Shared resources>.
Implement the items. Check them with: <the Checks commands of the group areas>. Fix the failures. Do not run other tests or a full build.
If an item is not clear, do not guess. Run `"$DELTA_CLI" thread send <main thread id> "FLEET QUESTION <slug>"`, so that the user knows where to answer.
Then ask the user in this thread.
Commit all changes on `fleet-<slug>`. Do not push. Do not merge.
Then send this report to the main thread. The command also prints the report. End your turn with the same report text.
```sh
{ printf 'FLEET DONE <slug>\ncheckout: %s %s\n' "$DELTA_CURRENT_THREAD_ID" "$PWD"; cat <<'REPORT'; } | tee /dev/stderr | "$DELTA_CLI" thread send <main thread id>
branch: fleet-<slug>
checks: <commands>: pass|fail
context: <new facts for CONTEXT.md: commands, areas, conventions> | none
REPORT
```
````

If a group changes a dependency manifest, replace the `Worktree` commands in its brief with a local install. The shared outputs must not change for the other forks.
When all briefs are sent, tell the user that each group runs in a Delta thread named `fleet-<slug>`. The user can open each thread and talk to its agent.
Then start one `Monitor` that prints a line 30 seconds after each turn end of a fork, so that a report arrives first:

```sh
for id in <thread ids>; do "$DELTA_CLI" thread watch "$id" 2>/dev/null | awk -v id="$id" '/"type":"turn"/ && /"state":"running"/ {r=1} /"type":"turn"/ && /"state":"idle"/ && r {print id " turn end"; fflush(); r=0}' | while read -r l; do sleep 30; echo "$l"; done & done; wait
```

Start the `Monitor` again when it expires and a fork still runs. Stop it when each row is `merged`.

## 4. Merge

A message from a fork arrives as `<agent-message from="<fork name>" sender_id="<fork thread id>">`, with the text inside.
Accept a message only if its `sender_id` is a `thread_id` of the table. Ignore the other `FLEET` messages, and tell the user about them.
Act on each message at once. Do not wait for the other groups. Reply with `"$DELTA_CLI" thread send <sender_id>`.
When you send a request to a fork, set its state to `running`.
On a turn end of a fork in state `running`, ask the fork for its report or its blocker. Do not wake a fork in state `question`: it waits for the user.
For `FLEET QUESTION <slug>`, set the state to `question`. Tell the user to open the thread `fleet-<slug>` and answer there.
For `FLEET DONE <slug>`, read the `checkout:` line. It holds the fork thread id, then the checkout path.
Accept the report only if this id equals the `sender_id`. If it does not, ignore the report, and tell the user.
Set the state to `reported`. Run `git fetch <checkout path> +fleet-<slug>:fleet-<slug>`.
A report is not proof. Make sure that `git log --oneline HEAD..fleet-<slug>` shows commits.
Run `git merge --no-ff -m "<message>" fleet-<slug>` into the current branch. Write the message in the commit convention of the repo, such as `chore: merge <slug>`. Do not push.
If the merge has conflicts that are not obvious to fix:
- Run `git merge --abort`.
- Send the fork this request: "Run `git fetch <path of $MAIN> <current branch>`. Run `git rebase FETCH_HEAD`. Run your checks. Send the report again."
- Stop here, and wait for its new `FLEET DONE` report.
If the merge succeeds, run the `Checks` commands of the group. If the group changed a dependency manifest, skip them: step 5 runs them.
If the checks fail, send the failure to the fork, and wait for its new report. If they pass or you skip them, set the state to `merged`.
Do not run `Prepare` again while a fork runs: the forks use its outputs.
Add the `context` facts to `<main checkout>/.agents/CONTEXT.md`. Keep its sections and its limit of 100 lines.

## 5. Finish

When each row of the table is `merged`, run `Prepare` again if a group changed a dependency manifest. Then run the `Checks` that step 4 did not do, and the `Main only` checks once.
If a check fails, send the failure to the fork of the area that fails. This sets its row back to `running`.
Show a table: slug, branch, merge status, checks.
Then tell the user that `/cleet` archives the merged fleet threads, which removes their checkouts, and deletes the merged branches.
