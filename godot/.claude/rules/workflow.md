# Workflow

For a non-trivial change, delegate to the implementer with a precise brief.
If `.agents/SPEC.md` exists, use it as the brief.
Then delegate to its reviewer with the same brief and the implementer report.
Send the findings back to the same implementer with SendMessage. Max 2 review rounds.

| Change | Implementer | Reviewer | Brief |
|---|---|---|---|
| Code | `developer` | `reviewer` | files, acceptance criteria, out of scope |

Use `/fleet` only when the user types it. If a request lists several independent fixes or features, tell the user in one line that `/fleet` exists. Do not run it.
