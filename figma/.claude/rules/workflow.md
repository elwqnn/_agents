# Workflow

For a non-trivial change, delegate to the implementer with a precise brief.
If `.agents/SPEC.md` exists, use it as the brief.
Then delegate to its reviewer with the same brief and the implementer report.
Send the findings back to the same implementer with SendMessage. Max 2 review rounds.

| Change | Implementer | Reviewer | Brief |
|---|---|---|---|
| Code | `developer` | `reviewer` | files, acceptance criteria, out of scope |
| Figma to code | `developer` | `reviewer` | Figma URL with `node-id`, target files, states, breakpoints, acceptance criteria, out of scope |
| Code to Figma, or a Figma edit | `designer` | `design-reviewer` | Figma URL with `node-id` or "new file", source (code paths or description), acceptance criteria, out of scope |

If a task changes Figma and code, split it in two tasks. Do the source of truth first. Give its report to the second implementer.
Read-only Figma calls stay in the main context: a screenshot for the user, metadata to find a node ID.
Do not call `get_design_context` in the main context. Its output is large. The `developer` calls it.
