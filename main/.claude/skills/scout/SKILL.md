---
name: scout
description: Design a feature that needs exploration. An `architect` agent lists options, a session builds a prototype of each, and the architect picks the best. Manual only.
disable-model-invocation: true
---
Request: $ARGUMENTS

You are the main session. The `architect` agent designs and judges. The sessions build prototypes. Do not implement.

1. Run the `recall` skill on the request. Start one `architect` agent with the request and the recall result. It returns 1 to 3 options.
2. If one option is clearly best, the architect writes `<main checkout>/.agents/SPEC.md` and the decision record. Show its summary, and wait for the user.
3. Else, read `${CLAUDE_SKILL_DIR}/../fleet/SKILL.md`. Run its steps 1, 3 and 4 with one new session per option to test, and with these changes:
   - Do not read or write `STATE.md`. Keep the session table in this session, with the state of each row. There is no item table, question list or limit of sessions. Skip the last line of step 1.
   - `$MAIN` is the absolute path of this checkout. `$N` is the option number, from 1.
   - The slug is `<slug>-<option>`, with max 16 characters: a-z, 0-9 and -. `git branch --list '*scout-<slug>*'` must print nothing. Read `fleet-`, `/fleet` and `FLEET` as `scout-`, `/scout` and `SCOUT`.
   - Items: "Build a working prototype of the spec `<spec path>`. Do not run a review." Files in scope: the files of the spec.
   - Options can edit the same files. Remove the sentence about the files that the other sessions hold.
   - Workers get no later items. Remove the `commit:` and `items:` lines of the report, and the last part of the brief from "Accept a later message".
   - For a question, the worker sends `SCOUT QUESTION <slug>`, then asks the user in its session. Set the state to `question`, and tell the user to answer there.
   - If the worker is an agent, ask the user, and send the answer to the agent with `SendMessage`.
   - Checks: the fast checks of the spec.
   - Do not merge. Read `<commit>` as `<branch>`. For a report, do only its `branch:` check and the `git log` check. Then set the state to `reported`, and skip the rest of step 4.
4. When each row is `reported`, send the branches and the `checks` lines to the same `architect` with `SendMessage`.
5. Show its summary, and wait for the user. The winning branch stays unmerged until the user says go.
   On go, run the path check of fleet step 4 on the winning branch, and show its list to the user. For this check, the sessions hold the files of their specs.
   Then merge the winning branch with `git merge --no-ff`, or copy its spec to `<main checkout>/.agents/SPEC.md` and follow the workflow rule.
   Then archive each session that you did not merge with `archive_session`.
   Its branch stays in this checkout for reference. Tell the user that `git branch -D <branch>` deletes it.
