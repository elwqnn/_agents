# Workflow

Use `/fleet`, `/cleet` and `/scout` only when the user types them.
`/scope` fits a feature that the user can describe. `/scout` fits a feature that needs design work. Tell the user in one line when one of them fits.
If a request lists several independent fixes or features, tell the user in one line that `/fleet` exists.

For a non-trivial change, delegate to `developer` with a precise brief: files, acceptance criteria, out of scope.
If `<main checkout>/.agents/SPEC.md` exists, use it as the brief.
If the task has several phases, write one brief per phase. Start a new `developer` for each phase, and give it the report of the previous phase.
Then start the lens review. The brief of each `reviewer` holds the spec, its lenses and the developer report.
- The lenses are correctness, spec, simplicity and security. Add security only if the diff touches input, auth, secrets, queries, files or the network.
- Count the changed lines: the `git diff --shortstat` total, plus `git ls-files -o --exclude-standard -z | xargs -0 cat | wc -l` for the untracked files.
- If the count is 600 or less, start one `reviewer` with all the lenses.
- Else, start one `reviewer` per lens, in parallel.
- Pass `model: opus` to the `reviewer` only if the diff touches auth or secrets.
Merge the findings and remove the duplicates. Send them with SendMessage to the `developer` that wrote the code.
Round 2 runs only the correctness and security lenses, and only if they had findings. Max 2 rounds.
