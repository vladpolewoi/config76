---
name: yt-extract
description: Extracts full transcripts from YouTube videos (no video download) and turns them into structured knowledge extractions via subagents, saved as markdown research files. Use when the user shares YouTube links wanting the text, a summary, or analysis — "get transcript", "analyze this video", "what does this video say", "extract from youtube" — or wants a channel scanned for relevant videos.
---

# yt-extract

Pipeline: video ID → transcript (captions, no video download) → one subagent per transcript → per-video extraction .md + raw transcript saved to the project.

## Quick start

```bash
# 1. Transcript (handles URL parsing + language fallback)
~/.claude/skills/yt-extract/scripts/fetch-transcript.sh "<url>" <outdir> [langs...]

# 2. Metadata (title, duration, channel)
yt-dlp --js-runtimes node --skip-download \
  --print "%(id)s | %(title)s | %(duration_string)s | %(channel)s | %(channel_url)s" "<url>"

# 3. Channel catalog (when scanning for more topics)
yt-dlp --js-runtimes node --flat-playlist \
  --print "%(id)s | %(duration_string)s | %(title)s" "<channel_url>/videos"
```

## Workflow

1. **Fetch transcripts first, agents second.** Run `fetch-transcript.sh` per video (default langs `en ru`; auto-retries with whatever is available). Fetch metadata in the same step. Work in the scratchpad.
2. **Spawn one extraction subagent per transcript.** Sizing: bundle videos under ~5k words into one agent; one agent per 10-20k words; for 30k+ words instruct the agent to Read the file fully in sequential offset/limit chunks. Respect CLAUDE.md parallel-agent limits (ask before 3+ parallel).
3. **Agent prompt template** — always include:
   - File path + video title/duration/channel + note that transcript is auto-generated (garbled words — infer from context).
   - Who the output is for (pull user context from memory: role, goals, current projects) so the "top-N for you" section is targeted.
   - Ask for: overview paragraph; ALL concrete advice/facts grouped by theme (completeness over brevity — keep every number, named tool, platform); marked region-/platform-specific vs universal items when the source is foreign-market; top 3-10 highest-value items for the user.
   - "Return only the extraction, no preamble."
4. **Save results as the agents finish** (don't wait for all):
   - `docs/research/<topic>/NN-<slug>-<videoid>.md` — extraction with header (URL, duration, channel, extraction date, source caveats).
   - `docs/research/<topic>/transcripts/<videoid>-<slug>.<lang>.txt` — raw transcript (greppable later).
   - If no obvious project home, ask where or default to `docs/research/`.
5. **Multi-video batches**: write a final `00-SYNTHESIS.md` — cross-video deltas mapped to the user's actual system/goals, priority-ordered actions, and a "worth extracting later" list from the channel catalog.
   **When a baseline synthesis already exists for the topic**: give the agent the synthesis file too and have it grade the new video (actionable density / credibility / novelty, 1-10) and split findings into NEW-vs-baseline and confirms-baseline. Then keep only what survives: fold novel items into the synthesis, keep a short trimmed per-video file (kept + rejected-with-reason), and delete the raw transcript of low-value videos (refetchable in one command). Quality bar: Nazarov-corpus level; below that, trim aggressively.
6. **Report**: lead with the highest-value findings for the user, then file locations. Never paste whole extractions into chat.

## When transcript fetch fails

- `yt-dlp --write-auto-sub` caption downloads 429 from this network even with `--impersonate chrome` — expected; that's why the API route is primary. yt-dlp stays for metadata/catalogs only.
- Script exits 1 with "No transcripts were found" → video has captions disabled. Fall back: `yt-dlp -f worstaudio` + whisper transcription — confirm with the user first (slow, large).
- Tools missing: `uv tool install "yt-dlp[default,curl-cffi]"`; `uvx` runs youtube-transcript-api with no install.

## Video analysis (rare)

Captions cover talking-head content. Only if the user says visuals matter (slides, screenshots, demos): `yt-dlp` the video at low res into the scratchpad, extract frames at the relevant timestamps with `ffmpeg -ss <t> -i <file> -frames:v 1`, Read the images. Ask before downloading video.
