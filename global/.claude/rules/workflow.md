# Workflow

Use `/fleet`, `/cleet` and `/scout` only when the user types them.
`/scope` fits a feature that the user can describe. `/scout` fits a feature that needs design work. Tell the user in one line when one of them fits.
If a request lists several independent fixes or features, tell the user in one line that `/fleet` exists.

For a non-trivial change, delegate to `developer` with a precise brief: files, acceptance criteria, out of scope.
If `<main checkout>/.agents/SPEC.md` exists, use it as the brief.
Then start the lens review. The brief of each `reviewer` holds the spec, its lenses and the developer report.
- The lenses are correctness, spec, simplicity and security. Add security only if the diff touches input, auth, secrets, queries, files or the network.
- Count the changed lines: the `git diff --shortstat` total, plus `git ls-files -o --exclude-standard -z | xargs -0 cat | wc -l` for the untracked files.
- If the count is 200 or less, start one `reviewer` with all the lenses.
- Else, start one `reviewer` per lens, in parallel.
Merge the findings and remove the duplicates. Send them to the same `developer` with SendMessage.
Round 2 runs only the lenses that had findings. Max 2 rounds.
