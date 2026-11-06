---
name: process-references
description: Works through the Reference76 ingest queue — fetches each saved reel/video/link, decides what kind of save it is (knowledge, inspiration, project material), routes it to the right place in the vault (playbooks, life-area tips, moodboards, project lists) via the routing map, runs knowledge through the kb-ingest quality gate with Vlad's own note as the intent, writes the verdict back to the phone through the reference76 MCP, and keeps a run journal. Use when the user says "process my references", "process the queue", "ingest my saves", "what's in №249", or names Reference76 items.
---

# Process references

The phone queues items in **Ingest** (new saves land there automatically). This skill empties that queue
into the vault. The data contract is `~/code/reference76/docs/SYNC.md`; the MCP server is `reference76`.

**Read first, every run** (vault `~/vault76`):
- `01 Dashboard/Saves — Where Things Go.md` — the routing map: kinds, topic → note, collection hints, note shapes.
- `01 Dashboard/Saves — Journal.md` — the last three entries; act on any open *Process* item.

## Loop

1. `list_items({ status: "ingest" })`. Nothing there → say so and stop. Several → all of them, oldest first;
   ask before starting more than 10 unless Vlad already said to do them all. More than ~8 → split into
   batches of ≤ 8 run one after another (never two batches writing the vault at once).
2. For each item, `get_item({ number })`. Vlad's **note** and **voice transcript** say why he saved it:
   treat them as the question the source must answer, and as the fit (F) baseline.
   A voice file with no transcript → transcribe the `audio_path` with the local Whisper first.
3. Fetch the content by source:
   - instagram → the `ig-extract` skill; youtube → `yt-extract`; tiktok → `yt-extract` (yt-dlp handles it);
   - web → `mcp__searxng__web_url_read`; pinterest → the pin's image/description is the content.
   - Music-only reels: read the edit from frames and scene-cut times; mark sound readings as inferences.
   - Fetch fails (login wall, gone) → `save_result` with `verdict: "skip"`, `why` naming the failure,
     and `status: "inbox"` so Vlad sees it again. Don't guess the content.
4. **Decide the kind** (routing map § 1): knowledge, inspiration, project material — or two of them.
5. **Process by kind:**
   - *Knowledge* → the **kb-ingest** skill's gate (ledger check → triage → claim audit → grades → verdict →
     write by verdict). Design/strategy/money → its playbooks; anything else → the topic's Tips note.
   - *Inspiration* → no claim audit. Keep (something specific worth borrowing) or skip. Save the thumbnail
     or clearest frame to the Moodboard's `moodboard/rN-<slug>.jpg` (long side ≤ 1200 px), add the entry
     with **Take:** naming exactly what to borrow.
   - *Project material* → verify it exists and is current, add it to the project's list.
   - Destination by the map § 2. **No row fits → create the destination** (Tips / Moodboard note in the
     right PARA folder, the shape in § 4), add the row to the map, and report it. Don't stop to ask.
   - Already in the Source Ledger → reuse the old verdict, don't re-run.
6. Log every save in `01 Dashboard/Knowledge — Source Ledger.md` (Kind column: reel / inspiration / trip …).
7. `save_result({ number, result, tags })` — status defaults to `done`:
   - `verdict` keep/mine/skip; `kind` real/hype/slop when the gate ran;
   - `grades` {a,c,n,f} 0–10 and `claims` {kept,total}, `pitch_pct` when the gate ran;
   - `why`: one sentence; `summary`: the answer to Vlad's note; `takeaways`: kept rules or "take" lines, ≤ 6;
   - `landed_in`: every note written to, `{ title, path }` with the path relative to `~/vault76`;
   - `next_step` only if there is a concrete one; 2–5 lowercase `tags`.
8. Collections are Vlad's: never `move_item` unless he asks. A collection not in the map § 3 → add a row.

## Close the run

- Add one entry at the top of `Saves — Journal.md`: **In**, **Landed**, **Learned** (1–3 things from the
  content worth remembering), **Process** (what went wrong or could be better; if you changed the routing
  map or this skill, say what).
- Improve as you go: a recurring problem in *Process* → fix it in the map or this file, not just the journal.

## Report

One line per item: `№249 · Keep · 4 of 11 kept → Playbook — Gestures & Drag` (inspiration:
`№31 · Keep · inspiration → House Build — Interior Moodboard`), a one-line answer to each note, new
destinations created, decisions for Vlad, then the totals (`stats({ since: <start of this run> })`).
The phone shows the same on its next sync.

## Single item questions

"what's in №249?" → `get_item({ number: 249 })` and answer from the result and note; don't run the
gate unless asked.
