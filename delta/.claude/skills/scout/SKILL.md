---
name: scout
description: Design a feature that needs exploration. An `architect` agent lists options, a Delta fork builds a prototype of each, and the architect picks the best. Manual only.
disable-model-invocation: true
---
Request: $ARGUMENTS

You are the main thread. The `architect` agent designs and judges. The forks build prototypes. Do not implement.

1. Run the `recall` skill on the request. Start one `architect` agent with the request and the recall result. It returns 1 to 3 options.
2. If one option is clearly best, the architect writes `<main checkout>/.agents/SPEC.md` and the decision record. Show its summary, and wait for the user.
3. Else, read steps 2 to 4 of `${CLAUDE_SKILL_DIR}/../fleet/SKILL.md`. Run them with one group per option to test, and with these changes:
   - `$MAIN` is the absolute path of the checkout of this thread. `$N` is the option number, from 1.
   - The slug is `<slug>-<option>`. Read `fleet-`, `/fleet` and `FLEET` as `scout-`, `/scout` and `SCOUT`.
   - Items: "Build a working prototype of the spec `<spec path>`. Do not run a review." Files in scope: the files of the spec.
   - Options can edit the same files. Remove the sentence about the files of the other groups.
   - Checks: the fast checks of the spec.
   - Do not merge. After the `git fetch` and the `git log` check, set the state to `reported`. Skip the rest of step 4.
4. When each row is `reported`, stop the `Monitor`. Send the branches and the `checks` lines to the same `architect` with `SendMessage`.
5. Show its summary, and wait for the user. The winning branch stays unmerged until the user says go.
   On go, merge the winning branch with `git merge --no-ff`, or copy its spec to `<main checkout>/.agents/SPEC.md` and follow the workflow rule.
   Then archive each fork that you did not merge with `"$DELTA_CLI" thread archive <id>`.
   Its branch stays in this checkout for reference. Tell the user that `git branch -D <branch>` deletes it.
