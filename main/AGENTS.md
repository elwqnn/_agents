# Code

No comments except if asked explicitly.

Agent files live in `<main checkout>/.agents/`: context, specs, decisions, docs. Read and write them by absolute path.
The main checkout is the parent of the git common directory. It is the same in each worktree:
`dirname "$(git rev-parse --path-format=absolute --git-common-dir)"`
If git does not ignore `.agents/` there, add `.agents/` to `$(git -C <main checkout> rev-parse --git-path info/exclude)`. Do not edit `.gitignore`.

Read `<main checkout>/.agents/CONTEXT.md` before you start a task.
It is the map of the codebase and links each area guide. If it does not exist, run the `context` skill first.

# Language

Use ASD-STE100 Simplified Technical English for all output: code comments, chat, documentation.
- One instruction per sentence. Max 20~25 words.
- Active voice. Present tense. Imperative for instructions.
- One meaning per word. No slang, no idioms.

If context about this codebase does not fit in the code, write it in `<main checkout>/.agents/CONTEXT.md`.

# Worktrees

A worktree holds only the files that git tracks. Ignored files are missing, such as dependencies, build outputs and `.env`.
Install the dependencies before a build or a test.
