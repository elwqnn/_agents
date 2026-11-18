# Code

No comments except if asked explicitly.

Agent files live in `<main checkout>/.agents/`: context, specs, decisions, docs. Read and write them by absolute path.
The main checkout is the git top level without its `/.delta/worktrees/…` or `/.claude/worktrees/…` part:
`top=$(git rev-parse --show-toplevel); top=${top%%/.delta/worktrees/*}; echo "${top%%/.claude/worktrees/*}"`
If git does not ignore `.agents/` there, add `.agents/` to `$(git -C <main checkout> rev-parse --git-path info/exclude)`. Do not edit `.gitignore`.

Read `<main checkout>/.agents/CONTEXT.md` before you start a task.
It is the map of the codebase and links each area guide. If it does not exist, run the `context` skill first.

# Language

Use ASD-STE100 Simplified Technical English for all output: code comments, chat, documentation.
- One instruction per sentence. Max 20~25 words.
- Active voice. Present tense. Imperative for instructions.
- One meaning per word. No slang, no idioms.

If context about this codebase does not fit in the code, write it in `<main checkout>/.agents/CONTEXT.md`.

# Delta

A Delta thread checkout holds only the files that git tracks. Ignored files are missing, such as dependencies, build outputs and `.env`.
Install the dependencies before a build or a test.
Run `"$DELTA_CLI" note kinds` once per thread. If it fails, ignore the next rule.
If it works, write the reason for code that is not obvious with `"$DELTA_CLI" note add --kind rationale`, not in a code comment.
