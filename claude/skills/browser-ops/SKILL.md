---
name: browser-ops
description: Reliable browser automation on this machine — claude-in-chrome connection diagnosis, the Playwright fallback for background agents, and the reference-capture procedure. Use when a mcp__claude-in-chrome__* call times out, when browser work must run in a background subagent, or when gathering visual references (Pinterest, Mobbin, live sites).
---

Three failure modes account for every browser-automation loss on this machine so far. Each has a
procedure. Skipping the diagnosis and "just retrying" cost three timeouts in a row on 2026-08-11 —
the error message blames permission prompts, but that has not once been the actual cause.

## 1. claude-in-chrome times out (main thread)

**The usual cause is routing, not permissions: more than one Chrome is connected** (this Arch box
+ the remote Mac). Commands go to the remote browser where nobody can approve anything, and every
call times out with a misleading "check the side panel" hint.

Procedure, in order — never retry the failing call blind:

1. `list_connected_browsers`. Two or more entries → you found it.
2. Ask the user which to drive (the tool mandates AskUserQuestion listing every browser). Local
   work → the `isLocal: true` entry.
3. `select_browser` with that deviceId, then `tabs_context_mcp {createIfEmpty: true}`.
4. Still dead after selection → now it really may be the side panel; ask the user to open the
   Claude extension in Chrome and approve. One ask, not a retry loop.

Load tools in ONE ToolSearch (`select:` list). Use `browser_batch` for any predictable sequence —
per-call round trips are the slow path.

## 2. Browser work in a background subagent

**The extension is unavailable to background agents** — its permission prompts need an interactive
user; measured result: 3/3 timeouts. Do not hand a background agent claude-in-chrome tools.

Fallback that works (proven in the flow76 critique run): a plain Node script driving **system
Chrome via Playwright**, borrowed from any repo that has playwright installed — run it with that
repo's `node_modules` on NODE_PATH rather than installing per-task. For sites needing login, use
`launchPersistentContext` with a dedicated profile dir (e.g. `~/.cache/claude-pw-profile`) and have
the user log in once in a headed session — the Calendar-App login pattern, generalized. The
subagent returns text + saved files, never inline images to its parent.

## 3. Reference capture (Pinterest, Mobbin, live sites)

Pinterest/Dribbble are login-walled and JS-heavy — headless scraping wastes the session. The
authed path is the user's own Chrome via claude-in-chrome, main thread, user present:

1. Navigate straight to the search URL (`/search/pins/?q=...`). **Wait ≥5s before the first
   screenshot** — the first paint is a blank white shell and screenshotting early reads as a bug.
2. Search broad and by feeling, never the product vertical — the vertical returns its own median,
   the exact thing a reference hunt exists to escape.
3. Capture picks with `zoom` on the pin's region + `save_to_disk: true`, then `cp` the saved paths
   into the project's `artifacts/references/` with numbered, named files.
4. The agent that saw the images writes the notes (typography / layout / colour / rhythm). The
   human writes the one-line "what I like" per keeper — that line is the taste and cannot be
   delegated.

Mobbin has MCP (`mcp__mobbin__*`) — it needs no browser at all, but it MUST run in a subagent:
its own schema warns context cost scales with results, and inline images belong in the context of
whoever writes the annotations, never the parent's.
