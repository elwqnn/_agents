# Figma

The `Figma` section of `<main checkout>/.agents/CONTEXT.md` holds the known Figma facts: file URLs, pages, frames, libraries, component keys, product font, and the map from Figma variables to code tokens.
Read it before a Figma call. Do not rediscover what it gives.
A Figma URL without `node-id` is not a valid brief. Ask for the URL of the frame or the component.

## Workflow

| Change | Implementer | Reviewer | Brief |
|---|---|---|---|
| Figma to code | `developer` | `reviewer` | Figma URL with `node-id`, target files, states, breakpoints, acceptance criteria, out of scope |
| Code to Figma, or a Figma edit | `designer` | `design-reviewer` | Figma URL with `node-id` or "new file", source (code paths or description), acceptance criteria, out of scope |

Delegate a Code to Figma task or a Figma edit to `designer`, then to `design-reviewer` with the same brief and the designer report. Send the findings to the same `designer` with SendMessage. Max 2 review rounds.
If a task changes Figma and code, split it in two tasks. Do the source of truth first. Give its report to the second implementer.
Read-only Figma calls stay in the main context: a screenshot for the user, metadata to find a node ID.
Do not call `get_design_context` in the main context. Its output is large. The `developer` calls it.

## Scope

For a Figma task, `/scope` adds these steps:
- Read the `Figma` section of `<main checkout>/.agents/CONTEXT.md` before you ask.
- If the request gives a Figma URL, look at the node with `get_screenshot` and `get_metadata` before you ask.
- Also cover: the direction (Figma to code, code to Figma, Figma edit), the Figma URL with `node-id`, the source of truth, states, breakpoints, library and tokens, assets.
- Add the direction and the Figma nodes to the spec.
