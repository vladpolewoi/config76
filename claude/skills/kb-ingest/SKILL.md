---
name: kb-ingest
description: Turns a video, article, podcast, thread or book into actionable playbook knowledge in the vault76 Knowledge Playbooks system — checks the source ledger, fetches the text, routes it to the right collection (or seeds a new one), runs the slop/hype quality gate claim by claim, and folds only the surviving rules into playbooks with citations. Use only when the user explicitly asks: "/kb-ingest", "add this to the playbook/knowledge", "run it through the gate/filter", "is this slop/hype", "what's worth keeping here". A bare link with no such ask goes to yt-extract or a plain answer instead.
---

# kb-ingest

Source → ledger check → text → route → **quality gate** → fold into playbooks → ledger → short report.

The system lives in the vault. Read these first; they hold the rules, not this file:

| File | What it gives you |
|---|---|
| `~/vault76/01 Dashboard/Knowledge Playbooks.md` | Registry (collections, `kb:` slugs, **Feeds on** routing column), shared note shape, precedence |
| `~/vault76/01 Dashboard/Knowledge — Quality Gate.md` | Pass 1 triage, Pass 2 claim tags (E/R/G/H/S/X), keep rule, verdicts 🟢/🟡/🔴, slop/hype/real tells, worked examples |
| `~/vault76/01 Dashboard/Knowledge — Source Ledger.md` | Everything already processed |
| [templates.md](templates.md) | Skeletons: source note, playbook, digest, MOC, ledger row, new-collection seed |

## Workflow

### 0. Ledger check
`rg -n '<video-id-or-url-slug>' ~/vault76/01\ Dashboard/Knowledge\ —\ Source\ Ledger.md`
If it's there, report the old verdict and stop, unless the user asks for a re-run.

### 1. Get the text (work in the scratchpad)
- **YouTube:** `~/.claude/skills/yt-extract/scripts/fetch-transcript.sh "<url>" <scratch>/<id>`
  and metadata in the same step. The description and audience numbers are gate evidence:
  `yt-dlp --js-runtimes node --skip-download --print "%(id)s | %(title)s | %(duration_string)s | %(channel)s | %(channel_follower_count)s subs | %(view_count)s views | %(upload_date)s" "<url>"` and `--print "%(description)s"`.
- **Article / thread / docs page:** `mcp__searxng__web_url_read`. Fall back to `mcp__fetch__fetch`, and say so.
- **PDF / book:** Read with `pages`. Books over ~150 pages: chapters the user names, or the TOC first.
- Captions are auto-generated, so infer garbled names from context and mark them *unverified*.

### 2. Route and load the baseline
Match the source's topic against the registry's **Feeds on** column. A source can feed 2–3
collections; one is primary. Read the target's **digest** and the **one or two playbooks** it
touches. That's the baseline novelty is judged against. Don't skip this step, or the gate can't tell new from known.
- **No collection fits:** if the source is likely 🟢, propose a new collection (name, `kb:`
  slug, path, first playbook) in one line and wait for a yes. If it's 🟡, fold into the closest
  collection.

### 3. Run the quality gate
Follow the Quality Gate note exactly:
1. **Triage**: operator? incentive? pitch share % (count pitch words ÷ total)? specificity?
   self-consistency (title vs description vs body)? date?
2. **Claim audit**: one row per candidate claim, tagged E/R/G/H/S/X, with a fate (rule / citation-only
   / parked / dropped + reason). Check claims against the baseline: something already covered is a
   citation only (raise `n`).
3. **Grade** A/C/N/F out of 10, the signal ratio, then the verdict.

**Sizing:** under ~8k words, do it inline. Longer than that, spawn **one** subagent per ~15k words
(`model: sonnet`). Give it the transcript path, the Quality Gate path, the baseline digest and
playbook paths, and the user context (projects: Tend, Budget76, intelect.md, BibleTimeline; solo
dev; budget-conscious since the July 2026 income drop). Ask it to "return only the triage
answers + the claim table + grades, no preamble", and if it searches the web, to "use
`mcp__searxng__searxng_web_search`". Ask the user before running 3+ agents in parallel.

### 4. Write, by verdict

| Verdict | Write |
|---|---|
| 🟢 Keep | Source note in the collection (template) + raw transcript in `transcripts/<id>-<slug>.<lang>.txt` · each kept rule folded into its playbook, cited `([[Source Note]])` · digest updated when a rule now has n ≥ 2 or is top-tier · MOC: Sources row + router row if a new moment appears + Wanted list · ledger row |
| 🟡 Mine | No source note, no transcript. Kept rules go straight into the target note, citing the source by title + URL; changelog line if the note has one; ledger row listing kept / parked / why rejected |
| 🔴 Skip | Ledger row only |

Writing rules:
- **Paraphrase into rules.** At most one short quote per source note, used only where the wording itself is the lesson.
- **Every rule cites its source(s)** and sits in the right section of an existing playbook. Add a
  new playbook only when a moment has ≥3 rules and nowhere to live.
- **Number new rules after the existing ones** and never renumber, because other notes link to "rule 16".
- **My apps** bullets are *hypotheses* checked against each app's doctrine (Tend `DESIGN.md`,
  Budget76 ADRs, intelect `docs/design/`). App doctrine and Apple rules beat any source.
- Hype numbers never become rules. If they matter, list them under **Unverified claims** in the source note.
- Keep each note's `updated:` date, `> **Nav:**` line and frontmatter (`type`, `kb`, `summary`,
  `use_when`, `sources`, `grade`, `tags`) in step with the registry's shared shape.
- App Framework targets: also add a row to `12 Learning Library.md` § Verdict log.
- New collection: seed it with templates.md § New collection and register it in the hub (registry +
  router), and in `Home.md` if it's a major domain.

### 5. Report (short)
1. Verdict line: `🟢/🟡/🔴 · A/C/N/F · kept X of Y claims · pitch Z%` + one sentence on *why*
   (real experience vs hype vs slop).
2. The 3–5 most valuable kept rules, one line each, and which of Vlad's apps they hit.
3. One line on what was rejected and why.
4. Files touched, as paths. Never paste whole extractions into chat.

## Batch mode
Several links: run the ledger check and triage on all of them first, rank them, process the 🟢 ones
in full, then 🟡, and log the 🔴 ones. Finish with one combined report.

## Don't
- Write anything into a playbook before the gate has run.
- Count repeated statements as independent confirmation (same channel, recycled script).
- Keep transcripts of 🟡/🔴 sources. They can be refetched with one command.

## Calibration mode (testing the gate)
To check the gate against Vlad's own judgement, run it **blind** on a source he knows: agents get only the
raw transcript + the Quality Gate, never the old extraction or synthesis. Report the verdict, then compare
it with his estimate and with the old extraction, and fix the gate (not the verdict) where they disagree.
Don't write to playbooks during calibration; add the ledger row once he has compared.
