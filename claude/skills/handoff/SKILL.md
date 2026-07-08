---
name: handoff
description: Write or read a compact session-handoff pointer so a fresh session can find where work left off. The file is a breadcrumb (pointers to where the real context lives), not a context dump. On-demand only — no auto-load. Use when the user says "/handoff", "handoff", "save handoff", "where did we leave off", or wants to resume a previous session.
---

# /handoff — compact session breadcrumb

Purpose: let the user `/clear` freely. State lives in a small pointer file; the next
session fetches it only when needed. This is an **index to context**, not the context.

## Where the file lives

NOT in the working repo (respects the no-AI-artifacts rule for code repos). Store it in
the current project's memory dir:

1. Take the current working directory.
2. Slugify: replace every `/` with `-` (e.g. `/home/user76/code/Calendar-App` →
   `-home-user76-code-Calendar-App`).
3. Path = `~/.claude/projects/<slug>/memory/HANDOFF.md`.

If that memory dir doesn't exist, fall back to `~/.claude/projects/<slug>/memory/` after
creating it, or ask the user for a location.

## SAVE mode (`/handoff`, "save handoff")

Write `HANDOFF.md` — keep it tight, pointers over prose:

```markdown
# HANDOFF — <short title>  (<YYYY-MM-DD>)

Task:    <id / one-line what we're doing>
State:   <where we left off — stage, status, what just finished>
Resume:  <the single next action to take>

Context lives in:
- <path:line | dir | doc | PR url | memory slug> — <what's there, why it matters>
- ...

Gotchas: <one line, optional — the thing future-me would trip on>
```

Rules:
- Pointers, not payloads. Link to WORKLOG / memory files / PR / file:line — don't paste
  their contents.
- If the work is a /klna task, the WORKLOG.md frontmatter STATUS is already the resume
  anchor — just point to it; don't duplicate it.
- One screen max. If it's longer, you're dumping context instead of indexing it.

After writing, tell the user the file path in one line.

## LOAD mode ("where did we leave off", "resume", "/handoff load")

1. Read `HANDOFF.md` from the path above.
2. Open only the pointers you actually need for the immediate next action — fetch lazily.
3. Confirm the resume point with the user in one line before acting.
4. If the file is stale (task says done, or user moved on), say so and offer to clear it.
