---
name: recall
description: Find past decisions, specs, rejected options and open questions about a topic in earlier Delta threads. Use before you scope or design a feature.
context: fork
---
Topic: $ARGUMENTS

Run `"$DELTA_CLI" --json thread list`. Pick up to 3 threads whose names match the topic.
Skip the thread `$DELTA_CURRENT_THREAD_ID`, the archived threads, and the names that start with `fleet-` or `scout-`: a fork copies its parent.
Read each thread with `"$DELTA_CLI" thread show <id> --format summarize | head -c 20000`.
Return max 15 lines: decisions, specs, rejected options and open questions. Give the thread id with each item.
