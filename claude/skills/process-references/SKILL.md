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
   - instagram → the `ig-extract` skill (one `fetch-ig.py` call for the whole batch, run in the background: it
     downloads everything first, then transcribes the batch, and writes `post.md` only at the very end; the
     `media/` and `frames/` folders appear per post, so start reading while Whisper runs, and each reel's speech
     lands in `media/01.transcript.txt` as soon as it is done (≈1 min per reel on CPU): read those, don't wait for
     `post.md`; only the caption needs it). Many items at once? `sqlite3 -readonly ~/code/reference76/server/data/reference76.db
     "select number, json_extract(data,'$.url'), json_extract(data,'$.voice.transcript') from items where …"` lists
     URLs and voice notes in one call instead of N `get_item`s. youtube → `yt-extract`;
     tiktok → `yt-extract` (yt-dlp handles it);
   - web → `mcp__searxng__web_url_read`; pinterest → the pin's image/description is the content.
   - Music-only reels (most edits): the stock 15-frame sheet is too sparse for a 15 s reel. Make a 20-frame sheet
     (`scripts/sheet.sh <mp4> <out.jpg>`) and the cut list (`scripts/cuts.sh <mp4>`), read the edit from those
     (in a `while read` loop give each call `</dev/null`, or ffmpeg eats the loop's input: run 8 lost a letter of a code);
     mark sound readings as inferences. Prompts or lists on screen too small to read → crop and re-tile
     (`ffmpeg -vf "fps=1,crop=…,tile=2x5"`). A reel with a static part (an editing timeline under the picture,
     a frame or caption band) hides cuts from `cuts.sh` (№46: 2 found, 33 real): crop to the moving region before
     `select='gt(scene,0.25)'`, and zoom a 2× crop of the timeline to read track and clip names. A dark reel (mostly black frames,
     №47: 5 found, ~15 real) under-counts too: read a 2 fps tile instead (`ffmpeg -vf "fps=2,scale=240:-1,tile=8x7"`).
   - Fetch fails ("no media in page") → it is usually a login wall for anonymous clients, not a private account
     (№16 was public). Second route, Vlad present: his logged-in Chrome via claude-in-chrome. Run
     `list_connected_browsers` first; two Chromes are normal here (this PC + the Mac) and the session often sits on
     the Mac's, which times out: ask, `select_browser` the local one, then `navigate` to the reel and `get_page_text`
     for the caption. The video cannot be pulled this way (CDN URLs come back with the signature redacted), so gate
     on caption + on-screen text and say the speech was not transcribed. If the speech matters: plan A is the
     yt-dlp cookie route (ig-extract § When fetch fails, Vlad runs it once); plan B, tested 2026-11-07, is a screen
     recording of the reel playing in his Chrome: `wf-recorder -y -a="$(pactl get-default-sink).monitor" -f out.mp4`
     for the reel's length + 2 s (Hyprland, h264 + aac), then `transcribe.py` and `scripts/sheet.sh` on the file.
     Real-time and needs the desktop free, so only when the cookie route is off the table. Still unreachable → `save_result` with `verdict: "skip"`,
     `why` naming the failure, and `status: "inbox"` so Vlad sees it again. Don't guess the content.
4. **Decide the kind** (routing map § 1): knowledge, inspiration, project material — or two of them.
   **Dig deeper when it changes the outcome** (Vlad, 2026-11-07): a schedule or price a trip save depends on, a claim
   the verdict hinges on, a tool or file the reel points at (`mcp__searxng__searxng_web_search`, then
   `web_url_read`). Say in the result what was checked and what was not; don't research for its own sake.
5. **Process by kind:**
   - *Knowledge* → the **kb-ingest** skill's gate (ledger check → triage → claim audit → grades → verdict →
     write by verdict). Design/strategy/money → its playbooks; anything else → the topic's Tips note.
   - *Inspiration* → no claim audit. Keep (something specific worth borrowing) or skip. **Most design saves are
     this** ("sick edit", "cool AI edit", "I like this look"): the picture is the save, so it lands on a board of
     `05 Resources/Design/Reference Library/` (edits & motion, AI video, UI & apps, brand & graphic), a room on the
     House moodboard. Save the hero frame `moodboard/rN-<slug>.jpg` (long side ≤ 1200), the 20-frame sheet
     `rN-<slug>-sheet.jpg` (≤ 1600), and for an edit the clip `rN-<slug>.mp4`; add the entry (newest first) with
     **Take:** naming exactly what to borrow and **Watch for:** the timings. A lesson inside a look also goes
     through the gate into its playbook, each citing the other.
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
8. **Collections are Claude's on ingest** (Vlad, 2026-11-07: picking one at save time was the uncomfortable
   step; the app no longer pre-fills one). No collection → `move_item` it into the matching one from the content;
   a clearly mis-filed one → move it; Vlad's own pick stays unless the content plainly belongs elsewhere. A
   topic with no collection → `create_collection` (next free colour) and add a row to the map § 3. List every
   move and new collection in the report.

## Close the run

- Add one entry at the top of `Saves — Journal.md`: **In**, **Landed**, **Learned** (1–3 things from the
  content worth remembering), **Process** (what went wrong or could be better; if you changed the routing
  map or this skill, say what).
- Improve as you go: a recurring problem in *Process* → fix it in the map or this file, not just the journal.

## Report

One line per item: `№249 · Keep · 4 of 11 kept → Playbook — Gestures & Drag` (inspiration:
`№31 · Keep · inspiration → House Build — Interior Moodboard`), a one-line answer to each note, new
destinations created, collection moves, decisions for Vlad, then the totals (`stats({ since: <start of this run> })`).
The phone shows the same on its next sync.

## Single item questions

"what's in №249?" → `get_item({ number: 249 })` and answer from the result and note; don't run the
gate unless asked.
