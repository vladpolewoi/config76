---
name: ig-extract
description: Pulls Instagram reels, video posts and carousels (no login) — caption, author, slide images, local-Whisper transcript of the speech, and a contact sheet of on-screen text — then turns them into structured knowledge extractions saved as markdown. Use when the user shares instagram.com links (/reel/, /p/, /tv/) wanting the text, a summary or analysis — "what does this reel say", "extract this post", "transcribe this reel", "the reels I saved" — the Instagram sibling of yt-extract.
---

# ig-extract

Pipeline: link → caption + media (anonymous) → Whisper transcript (local, CPU) + video contact sheet → read slides/sheets → per-post extraction .md + raw post.md saved to the project.

## Quick start

```bash
python3 -I ~/.claude/skills/ig-extract/scripts/fetch-ig.py <outdir> "<url>" ["<url>"...]
```

Per post it writes `<outdir>/<code>/`:
- `post.md` — URL, author, date, likes, type, **caption**, media list, **transcript** per video (`[lang prob]` + timestamped lines).
- `media/NN.jpg|mp4` — carousel slides / videos, full res.
- `frames/NN-sheet.jpg` — 15 stills of video NN tiled 5×3: one Read shows all on-screen text. `frames/NN-MM.jpg` = single stills for zooming in.

Batch every link into one call — Whisper loads once (~10 s), then a 70 s reel transcribes in ~20 s. Reruns skip what's already downloaded/transcribed. Work in the scratchpad.

## Where links come from

- Pasted in chat (share links with `?igsh=` / `?vrfl=` are fine).
- **"the reels I saved"** → Telegram Saved Messages: `get_messages(chat="me", only_media="link")` and keep the instagram.com ones. `search_messages` full-text does **not** match URLs.

## Workflow

1. **Fetch first.** Run `fetch-ig.py` with all links, then Read each `post.md`.
2. **Read the visuals when the text doesn't carry it:**
   - Carousel → Read every slide in `media/` (the slides are the content; the caption is often a teaser).
   - Video with thin speech (`(no speech — …)`, music, < ~30 words) or on-screen lists/prompts/numbers → Read `frames/NN-sheet.jpg`; zoom into single stills only when a sheet tile is too small.
   - Talking head with a full transcript → the sheet is optional; skip it unless the user says visuals matter.
3. **Extract.** Reels are short (100–400 words), so do 1–4 posts inline. For bigger batches spawn one subagent per ~5 posts (respect CLAUDE.md: ask before 3+ parallel), handing it the post.md paths + which images to Read. Always ask for: overview; ALL concrete advice/facts/numbers/named tools grouped by theme (slides + speech + caption merged, deduped); what is hype or a lead magnet ("comment X and I'll send…" = the real content is withheld — say so); top 3–5 items for Vlad (pull context from memory/Goals).
4. **Save:**
   - `docs/research/<topic>/ig-<code>-<slug>.md` — extraction with header (URL, author, date, type, extraction date, caveats).
   - `docs/research/<topic>/raw/<code>.md` — copy of post.md plus slide/sheet text you read (greppable later). Images stay in the scratchpad.
   - No obvious project home → ask where, or default to `docs/research/`.
5. **Into the playbooks** only on an explicit ask → hand the extraction to `kb-ingest`.
6. **Report:** lead with the highest-value findings, then file locations. Never paste whole extractions into chat.

## Gotchas

- **Whisper mishears names and jargon** ("Claude Code" → "CloudCode", product names). Fix them from the caption and the on-screen text before extracting.
- **Lead magnets:** a lot of reels hold back "every prompt/guide" behind a comment. Extract what's shown; don't imply the guide was captured.
- `gallery-dl` and plain `yt-dlp` hit the login wall / drop image slides. The script's route (yt-dlp `--write-pages` → parse the media JSON from the page dump) is why carousels work without login.

## When fetch fails

- `ERROR: <code>: no media in page` → private account, deleted post, or a rate limit. Rate limit: wait 15–60 min, retry with gaps. Many links in a row: the script already sleeps 5 s between posts.
- **Private accounts, stories, highlights need Vlad's Instagram login.** That means browser cookies (`yt-dlp --cookies-from-browser firefox:<zen-profile>`): his call, ask first. Never open the browser cookie store yourself.
- Whisper deps: `uv run --python 3.12 --with faster-whisper`; the model `large-v3-turbo` is already cached in `~/.cache/huggingface`. Decoding goes through system ffmpeg (PyAV breaks on Arch's ffmpeg).
