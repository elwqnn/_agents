---
name: scope
description: Interview the user to turn a vague request into a precise spec. Covers Figma tasks. Manual only.
disable-model-invocation: true
---
Request: $ARGUMENTS

Interview me with the AskUserQuestion tool until the task is fully scoped. Do not implement.
Read the related code and the `Figma` section of `ARCHITECTURE.md` before you ask, so each question is specific to this codebase.
If the request gives a Figma URL, look at the node with `get_screenshot` and `get_metadata` before you ask.
Ask one round at a time, up to 4 questions per round. Do not ask obvious questions. Dig into the hard parts.
Cover: goal, users, files and modules touched, data and edge cases, constraints, verification, out of scope.
For a Figma task, also cover: the direction (Figma to code, code to Figma, Figma edit), the Figma URL with `node-id`, the source of truth, states, breakpoints, library and tokens, assets.
Stop when no question is open. Then write `SPEC.md`: goal, direction, Figma nodes, files, acceptance criteria, edge cases, out of scope, verification step.
