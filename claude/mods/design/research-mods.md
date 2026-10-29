# Claude Code mods: what the community finds useful (research, 2026-10-08)

Method: SearXNG (yandex/bing/google-cse only; brave/ddg/startpage were rate-limited or CAPTCHA'd) plus
direct reads of GitHub (authenticated `gh api`: star counts, issue reactions), HN (Algolia API) and
Anthropic docs. **Reddit and X could not be read**: reddit.com returns 403 to the SearXNG reader, to
`curl`, to r.jina.ai and to WebSearch (domain blocked). So "Reddit/X evidence" below is absent; HN,
GitHub issues, awesome-lists and blog posts stand in. WebSearch was used once as a fallback (query:
"Claude Code mods community favorites r/ClaudeCode ...") and only surfaced the capitalandcompute posts.

Existing token-ledger (this repo, `claude/mods/token-ledger`) already has: context bar by category,
5h/7d bars with reset countdown, session $, model/repo/branch card, per-answer turn line, `/tokens`
pane (by project/task/model/agent, cache %). Not present (grep'd): pace/forecast, cache-TTL clock,
live subagent roster, attention toasts, tool-row transparency, git/PR/CI, todo progress, memory health.
Note: community also has a *different* mod called `token-ledger` (Arunjay4213/claude-mods, 5 stars,
`/ledger` pane + pinned cost line) - name collision only.

---------------------------------------------------------------------------------------------------

## 0. Landscape facts worth knowing

* **Mods shipped 2026-10-01** (Claude Code 2.1.287+, on by default). Design thread
  https://github.com/anthropics/claude-code/issues/91870: 129 thumbs-up, 222 total reactions, 245 comments.
  Announcement https://claude.com/blog/claude-code-mods ; guide (Addy Osmani)
  https://claude.dev/blog/getting-started-with-claude-code-mods/ ; docs
  https://code.claude.com/docs/en/plugins/mods/overview , `/interface`, `/reference`.
* Ecosystem is already large: the community scanner lists **2,692 mods** (last scan 2026-10-06)
  https://github.com/karanb192/awesome-claude-code-mods ; two other directories listed 72-75 hand-checked
  mods on Oct 2 (https://capitalandcompute.net/blog/best-claude-code-mods/). Mod repos are brand-new, so
  stars are small (best: hamzafer/claude-code-mods 144, scasella/claude-flightdeck 29, cc-arcade 41).
  Star counts for the *statusline generation* (the demand signal that mods inherit) are far stronger:
  **claude-hud 28,392**, ccusage 18,916, **ccstatusline 13,221**, Claude-Code-Usage-Monitor 8,735,
  claude-squad 8,580, CCometixLine 3,469, tweakcc 2,536, token-optimizer 2,515, nilbuild/claude-statusline
  1,397, claude-powerline 1,173, ccmanager 1,260, Claude-Code-Agent-Monitor 1,052, claude-devtools 3,968.
* **Render sites available to a mod** (docs /reference): `Pane` (docked sidebar, or inline above prompt
  when narrow), `AbovePrompt` band (props: `isWorking`, `maxRows`, `bodyColumns`), status line under the
  prompt (`$.ui.status`), toast (`$.ui.toast`, top-right of transcript), transcript log line (`$.ui.log`),
  `UserMessage`, `AssistantMessage`, `ToolUse`, `ToolResult`, `ToolGroup`, `CommandOutput`,
  `AskUserQuestion`, `Spinner` (word/message/suffix), `ToolProgress`, `TurnDuration`, `InfoNotice`,
  `SessionMode` (footer mode labels), `PromptHint`. Elements: Box (borderStyle round/single/double/bold/
  dashed/quote...), Text (dimColor/inverse...), Button (hotkey; digit hotkey in band fires when typed alone
  into an empty prompt), Link, Code, Markdown, Input, Select, Raster (terminal-only colored cells grid,
  <=512x256), Image (terminal-only PNG), Svg (desktop-only), Client.
* **Events/data**: `turn.complete` can return `{text}` = a line under the answer (this is the per-answer
  footer); `session.measure` fires after each turn AND when a plan-limit percent changes;
  `$.session.usage()` -> `{context:{tokens,window,percent}, rateLimits:[{kind,percentUsed,resetsAt}], cost}`;
  `session.compact` (can skip), `prompt.attachment` (intercept CC's own reminders), `prompt.compose`
  (append system-prompt facts), `agent.spawn`, `tool.call`/`tool.check`, `$.model.fork` (cheap side
  question sharing prompt cache), `$.audio.play/speak`, `$.clock.every`, `$.store` (cross-session KV),
  `$.state` (survives hot reload), `$.process.run` (gh, git, ssh...).
* **Author-reported constraints** (issue #91870 comments): band redraws ~10x/sec max and is about half the
  terminal; `Client` tree <=2000 nodes / 100k chars; hook budget 10 s (time inside `$` calls excluded);
  module vars reset on hot reload (use `$.state`); desktop vs terminal element sets differ; an
  interactive `Svg` flashes when a sibling site redraws (3dnow/claude-mods); `ui.render` didn't arrive in
  the Desktop Code tab on some builds (seosy218). `/usage` etc. cannot be re-registered (built-in names).
* **Anthropic's own showcase mods** (what the vendor thinks is worth showing): Token Weather (context
  "forecast": ☀☁☂☇↯ + % + 12-turn sparkline + last-turn delta), Blast Radius (hold risky Bash, list what it
  would touch, Proceed/Cancel), Replay Theater (`/replay` steps through last turn's edits). Built-in mods:
  diff, agents-md, sec-default, telemetry.

---------------------------------------------------------------------------------------------------

## 1. Ranked mod ideas

Ranking = evidence strength x fit with "terse, label-free, glyph+position" x novelty vs current token-ledger.
"Site" = where it lives. All are zero-token (drawn locally) unless noted.

### Tier A - highest evidence, directly complementary to token-ledger

**A1. Prompt-cache clock (TTL countdown, $ at stake, miss reason)**  - strongest unmet need
* Shows: time until the prompt cache lapses (1 h on subscription / 5 min on API key; auto-detect from
  `usage.cache_creation.ephemeral_1h/5m`), last-message cache read %, "$ at stake" if it lapses (whole
  context rewritten at 2x input), and after a miss: cause (model changed / lapsed / prefix changed) and
  "+$" extra. Advice glyph past 100k tokens: compact up to ~300k, new thread beyond.
* Site: one band cell (glyph + `MM` minutes, no seconds) that turns amber <10 min; toast on "about to
  lapse with big context" and on "missed (+$2.10)"; miss reason as a segment of the per-answer footer.
  Also warn on model switch when context >50k (capitalandcompute "Usage and model" row).
* Evidence: requested in 4 separate statusline repos - claude-hud #400, ccstatusline #300 (+ shipped
  `Cache Timer` widget with HOT state, v2.2.22), claude-powerline #81 (+ shipped `cacheTimer` with
  elapsed/remaining modes, color tiers 0-3 m green, 3-5 yellow, 5+ red), claude-statusbar (377 stars)
  "prompt-cache-expiry countdown". Mods: cache-clock, token-weather-usage (augiefra, the most thought-out
  version), **Cache-Tax** (HN 49749632; `/keepwarm` pings via `$.model.fork`), YouTube "5 mods you need"
  lists Cache Control. Why people care: HN tare thread (88 pts) top comment "In 95% of cases it is
  because you had a large context for which the cache expired"; usage-drain megathreads
  anthropics/claude-code #16157 (695 +1, 1,499 comments), #38335 (476 +1, 875 comments), #46917 (215 +1,
  cache_creation inflation), #40524 (159 +1, history invalidated).
* Steal: augiefra's wording of consequence ("741k to rewrite ~ $5.93"), claude-esp's "prompt-cache miss
  (reason + extra tokens)" event line.

**A2. Pace + run-out forecast on the 5h / weekly / per-model bars**
* Shows: usage vs. fraction of window elapsed (ahead/behind), ETA to exhaustion ("runs out ~Sat 20:12"),
  per-model weekly buckets (Fable / Opus / Sonnet have their own windows now), "reset" instead of stale
  numbers once the window rolled, freeze at limit-hit.
* Site: extend the existing limit bars: a ghost cursor/hatched gap on the bar (no new row), forecast in
  `/tokens` pane (burn-up chart with past windows), toast "5h on pace to hit limit in 38 m".
* Evidence: claude-powerline `showPace` (◆ over / ◇ under pace); claude-hud `usagePace` + `timeFormat:
  elapsed`; ccstatusline "usage time cursor" and weekly Fable widget (v2.2.25); weektoken
  (3dnow/claude-mods) "Will you run out before the reset?"; token-weather-usage hatches the gap between
  bar and elapsed time (green/yellow/red; red when >15 pts ahead or >90%); statuslin.es #3 most-copied
  ("Pace Dot Meters", 91 copies); claude-statusbar "learned end-of-window projections" (377 stars);
  Claumon (HN 48488753) Gamma-process forecast with credible intervals; Claude-Code-Usage-Monitor (8,735
  stars) built on predictions, + request #167 weekly reset (13 +1); ccusage burn rate; cctop "exhaustion
  forecast"; ccstatusline #124 (13 +1) "remaining instead of elapsed".
* Steal: Apple-Activity-rings colour rule from weektoken - stay in the quota's own hue until exhausted,
  only then a warm colour; pace marker as one glyph.

**A3. Live subagent / background-task roster**
* Shows: count + per-agent {type, model, current tool, elapsed, tokens}, orphaned/stuck marker (elapsed
  after 30 s in state), Stop button; finish toast; background shells and MCP calls in same list.
* Site: band glyph+count (`⊜3`), `/agents` pane (docked), finish toast. Data: `agent.spawn`, `turn.step`
  usage, `$.agent.list()`.
* Evidence: ccstatusline #299 "Agent/Task widget for background subagents" (open; CC doesn't expose the
  list to status lines - mods can); claude-hud agents line + issues #798/#734; mods agent-radar,
  agentpane, mission-control (hamzafer 144 stars), flightdeck (29 stars: cards -> swimlanes + permission
  gate), agent-flow (12), agent-jobs (narrowstacks, with Stop + finish toast), swarm (OneWave); claude-esp
  (155 stars; subagent tree), cctop (tomstagl: agents view with `ret`/wasted reasons), claude-squad 8,580,
  Claude-Code-Agent-Monitor 1,052; anthropics/claude-code #24537 (19 +1) "Agent Hierarchy Dashboard"; Zak on
  HN: one open-ended request "dispatched five Fable subagents" and burned the quota.
* Steal: flightdeck/cctop "wasted" accounting (failed, killed, no return, idle) - ties into $ ledger.

**A4. Attention signal: "needs you" / "done" (permission, question, long turn finished)**
* Shows: a single state glyph (see glyph table in section 3) for main loop: working / waiting on
  permission / waiting on question / done; elapsed since entering state. Toast + optional
  `$.audio.play` + terminal title when it needs you and the terminal isn't focused. Dedupe: only main
  agent stop, main/subagent question or permission (HN: naive `Stop` hook also fires for subagents ->
  false positives).
* Site: band glyph, toast, window title. Data: `turn.complete`, `tool.check`, `AskUserQuestion` site.
* Evidence: anthropics/claude-code #13024 (81 +1) "hook for when Claude is waiting for user input";
  HN Claudoro thread (50 pts, 36 comments): "what I really want is a bell sound to ring when it's done"
  (hadlock) + hombre_fatal's de-dupe script; ccmanager (1,260 stars) core feature = busy/waiting/idle
  state per session; zellaude (53) permission "flash" + elapsed after 30 s; claude-squad 8,580; Amux HN:
  "agents silently block on permission prompts, no way to see which of 8 sessions needs attention";
  claude-control, AFKSwitch, cs-radio (sounds), miod (HN 49999983 MIDI).
* Steal: zellaude's "pulse bright for 2 s on a new permission request", rate limit once/10 s.

**A5. Tool-row transparency (which file / pattern) and "doing now" line**
* Shows: collapsed `Read 3 files` becomes `3 ▸ a.ts b.ts +1`; Grep shows pattern; Bash shows the
  description or trimmed command; ssh host; elapsed after 15 s; "waiting for signing approval" when a
  signed commit sits quiet. Plain-English intent line ("Find the commit that broke coupons - 1m 48s") to
  distinguish stuck from slow.
* Site: restyle `ToolGroup`/`ToolUse` rows; `Spinner` suffix; optional click-to-expand band box.
* Evidence (largest *complaint* signal in the whole survey): anthropics/claude-code **#21151 "No
  indication of WHICH file for READ tool": 186 +1, 133 comments**; HN "Claude Code is being dumbed
  down?" **1,085 points** (item 46978710); **claude-devtools 3,968 stars** exists solely to un-hide this
  ("Read 3 files", thinking, subagents, a context bar with no breakdown); claude-esp 155 stars; HN "Show
  HN claude-devtools" 69 pts/44 comments; mods live-spinner (narrowstacks), whats-agent-doing (tzafrir; Show
  HN 49934165), tessera, skins. Related: #8477 "always show thinking" 337 +1; #6814 silly progress words
  215 +1 (so a *quiet*, factual spinner is a feature).
* Steal: narrowstacks live-spinner (elapsed only after 15 s), what's-agent-doing's click-to-expand step list.

**A6. Turn receipt: extend the per-answer footer with *work* (not just tokens)**
* Shows: outcome glyph `✓ done / ✗ error / ◼ interrupted`, duration, files changed with +/- lines,
  commands run/failed, subagents used, **"unverified"** flag when code was edited after the last
  test/build/lint/typecheck, and a toast when the model "goes in circles" (same call failing N times with
  no edit between, default 3).
* Site: `turn.complete -> {text}` (same line as the token footer, second segment) + toast; `/replay` pane
  for diffs (Anthropic's Replay Theater).
* Evidence: two independent `receipt` mods (hoobnn, yash-gadodia; yash also "names an unverified claim in
  the spinner"), change-ledger (arasovic: which agent edited each file, vs git working tree), Replay
  Theater is one of only three Anthropic showcase mods; #44763 + #2441 timestamps (94 +1 /
  63 +1) are the same itch ("what happened when").
* Steal: the "unverified" flag - the one thing that changes what you do next.

### Tier B - strong evidence, moderate fit / cost

**B1. Context foresight (beyond the fill bar you already have)**
* Shows: autocompact-aware denominator (subtract the ~33k buffer: "167K usable"), growth per turn and
  *turns left before compaction*, 12-turn sparkline, compaction counter + tokens reclaimed, "what grew"
  (largest contributor last turn: tool result / file read), idle MCP/tool-schema overhead (capitalandcompute:
  "almost half of the 56k at session start was tool definitions").
* Site: extend the existing context row + toasts at 60/80/90 % (narrowstacks context-watch) - but make them
  one-shot per threshold; CCometixLine ships a *disabler* for CC's own "Context low" nag, so nagging is a
  known annoyance.
* Evidence: claude-powerline `autocompactBuffer`; claude-hud issues #48 / #540 (mismatch vs `/context`)
  and `autoCompactWindow`; ccstatusline compaction counter (count/auto/manual/reclaimed) and
  post-`/compact` reset; anthropics #516 "always show available context %" (130 +1), #18456 (149 +1);
  context-lens, context-bar (144 stars), agent-compact-advisor (0-100 "good moment to /compact" score),
  token-optimizer 2,515 stars ("ghost tokens"), cctop (context body "five slices in order of what you can
  do about them").

**B2. Git / PR / CI micro-row (hide when clean)**
* Shows: `⎇ main ±3 ↑2 · #123 ✓` ; CI pass/pending/fail counts; unresolved review threads; worktree name;
  toast on check flip green/red/merged.
* Evidence: ccstatusline ships ~30 git widgets incl. PR + CI status + worktree; Matt Pocock's "perfect
  status line" = repo/branch/S-U-A counts + ctx % (aihero.dev); mods pr-watch, cc-pr-tracker, gh-ci-status,
  pr-pulse, `/worktrees` pane (each worktree: branch, dirty, ahead/behind, PR state); capitalandcompute
  row 4 (`PR #42 draft · CI 4/5 · 2 threads`, `/ci` speeds up polling). Risk: `gh` is slow -> cache 5 min,
  `--no-optional-locks`, bounded timeouts (ccstatusline learned this the hard way).
* Steal: TevvvB/termagitchi idea (listed in awesome-claude-code) - one glyph whose expression encodes repo hygiene (dirty, unpushed,
  behind trunk, last test result).

**B3. Plan / todo progress + "where am I"**
* Shows: `▸ Fix auth (2/5) 3m` from TodoWrite/Task tool results; goal / doing-now / waiting-on-you.
* Evidence: claude-hud todos line; hoobnn todo-bar; hamzafer where-am-i; YouTube "Claude Code Mods Are
  Finally Here: 5 You Need Right Now" lists Plan Progress (a checklist) next to Next Steps, Cache Control,
  Blast Radius; pinboard; gsd-status-mod.

**B4. Cross-session spend: today / 7-day $, burn $/h, cache-saved $**
* Evidence: claude-hud `showDailyCost/showWeeklyCost` ("Today $12.34", per-day ledger); claude-powerline
  today/month budgets with warning thresholds; ccusage statusline (session / today / block / burn rate);
  cc-costline 7d/30d; Caprock notes today's total can't come from stdin (needs a record - `$.store` can
  keep it, capitalandcompute does `cost:<day>:<session>`). Your `/tokens` pane has this per range; the gap
  is a *glanceable* `today $x` cell.

**B5. "Where did my quota go" attribution pane**
* Shows: ghost tokens, cache rebuilds, subagent overhead, background automations, per-day spikes.
* Evidence: HN tare (88 pts) "Ask Claude Code where your usage went"; cc-probeline (prices every turn,
  subagents, cache rebuilds); claude-quota menubar (HN 69 pts/40 c); token-optimizer 2,515 stars;
  commenters: "a cause, not a wall of numbers" (luciandan: tare shows *where* not *why*).
  Your `/tokens` already breaks down by project/task/model/agent; add *anomaly* sentences.

**B6. Memory-index health (MEMORY.md truncation at 200 lines / 25 KB)** - personal fit
* Auto-memory silently drops everything past 200 lines or 25 KB (capitalandcompute row 6: "this mod alone
  justified building the set"; their index was at 22.2/25 KB). Your global CLAUDE.md + MEMORY.md make this
  relevant. Show only when >80 % (`mem 88%`), otherwise invisible.

**B7. Device / build fleet band (iOS workflow)** - personal fit, thin community evidence
* Shows: Mac reachable? (often asleep), phone `connected` vs `available (paired)` (screenshots need
  connected), last `iosdev` build/test result, flag runs that executed 0 tests, Xcode lock.
* Evidence: narrowstacks `xcode-status` (flags 0-test runs, booted simulator, blocks 2nd xcodebuild);
  hoobnn `ts-band` (Tailscale nodes - lists *only* relayed/offline ones, toast on up/down) is the exact
  "show only the abnormal" shape. Pull from `ssh mac`/`devicectl` on a slow `$.clock.every`.

**B8. Service health, hidden when green**
* ccstatusline v2.2.28 `Claude Status` widget (live severity + 48 h incident strip, `?` when unknown);
  AIWatch. Pain: #46987 (168 +1) stream idle timeout, #26224 hangs; HN: "Anthropic's recent reliability
  problems". Distinguishes "Claude is down" from "my session is stuck".

### Tier C - real demand, lower fit for a terse UI (do last or minimally)

* **C1. Safety guard with preview** (Blast Radius is Anthropic's flagship example; launch-codes; remote-guard
  asks before destructive ssh commands). Not display, but its pane/band fallback pattern is worth copying.
* **C2. Message timestamps** (#44763 94 +1, #2441 63 +1; `time` mod): dim `HH:MM` on `TurnDuration`.
* **C3. Next-step chips** (Haiku via `$.model.fork`; YouTube top-5; pawandeepdhall/next-steps,
  hamzafer/next-steps). Costs tokens; conflicts with "terse" - maybe 1 dim `prompt.suggest` instead.
* **C4. Message-queue indicator** (#50246, 211 +1): queue count near the prompt; verify API supports it.
* **C5. Companion glyph** - /buddy removal thread **#45596: 1,186 +1, 280 comments**; ccpet 64, openpets
  723 (per list), claude-code-personalities (kaomoji that escalate with errors), clawd-dash, Tamagotchi
  (HN 2025), cc-arcade (41 stars, one comment with 35 reactions - the most-liked contribution in the mods
  thread). Terse variant: a single fused-state glyph rather than an animated pet.
* **C6. "While you wait" toys** (arcade, Pomodoro `Claudoro` 50 pts HN, breathing, Terminal Gym): popular but
  against the brief; HN critique to heed: "a ticking MM:SS timer where my focus is would be very
  distracting" (incidentist) -> never tick seconds in the main band.
* **C7. System/ports pane** (RAM, listeners, Kill button) from capitalandcompute row 7: "five of the eight
  largest processes were Claude sessions; Ports tab used most".

---------------------------------------------------------------------------------------------------

## 2. Per-answer footer / toast / statusline allocation (suggested)

| Site | Put here | Why |
|---|---|---|
| Band cells (always visible) | context, 5h/7d + pace marker, cache clock, agents count, attention glyph, git glyph | glance-state; position = meaning |
| `turn.complete` footer line | tokens + $ (have) + outcome glyph, files +/-, cmds failed, unverified, cache miss+$ | per-answer, scrolls away |
| Toast | threshold crossings (one-shot), cache about to lapse, check flipped, agent finished, circling, service incident | events, not state |
| Pane `/x` | breakdowns, forecasts, rosters, receipts (`/replay`), attribution | detail on demand |
| `ToolGroup`/`Spinner` restyle | which file, elapsed >15 s, plain-English step | fixes the #1 complaint |
| `$.ui.status` (under prompt) | at most one thing; or leave empty | avoid clutter |

---------------------------------------------------------------------------------------------------

## 3. Visualization techniques worth stealing

Bars and gauges
* **Pace ghost / hatched gap**: fill = used, hatch after bar = margin when under pace, same hatch in a
  deeper shade where over pace (token-weather-usage; weektoken). Reads in one glance, zero labels.
* **Pace diamond** `◆` over / `◇` under, `◈` where it meets (claude-powerline).
* **Quarter-step dot meters** `◔◑◕●` with colour = ahead/behind pace (statuslin.es "Pace Dot Meters",
  91 copies; good for 1-cell-per-window label-free rows).
* **"Capped" line bars** `━━━╸┄┄┄` and **ball bars** `──●───` - lightest weight; `▰▱`, `█░` heavier
  (claude-powerline's 11 styles).
* **Fractional blocks** `▏▎▍▌▋▊▉█` for sub-cell precision (Unifly, per hyperbliss.tech); **sparklines**
  `▁▂▃▄▅▆▇█` (Token Weather); **braille 2x4** for double data density and smooth charts (btop; neomon "2x
  data density"; dual layer: half-block area fill + braille line overlay).
* **Stacked categorical bar** with a compaction tick (context-bar; context-lens) - you already do this.
* **Usable-window denominator** (subtract autocompact buffer) so 100 % means "compaction fires".
* **Weather / metaphor icon** compresses 5 thresholds into 1 glyph: `☀ ☁ ☂ ☇ ↯` (Token Weather);
  fire-bar for spend (burn-meter); hygiene face (TermaGITchi).
* **Threshold colours** green <50, yellow >=50, orange >=70, red >=90 (daniel3303, 614 stars) - but see
  "colour restraint" below.

Information design
* **Show only when abnormal** (starship's battery module is "only visible when the device's battery is
  below 10 %" - starship.rs/config; ts-band lists only relayed/offline nodes; ccstatusline `hide when
  zero/empty`; claude-powerline `outputStyle.hideDefault`). Calm default = empty band.
* **Priority-ordered degradation**: Caprock drops token totals first, then cache, then turns; model,
  context, cost, plan windows always stay. weektoken drops the elapsed figure, then the bar. Define the
  drop order per cell.
* **Fixed slots / spatial consistency**: weektoken uses a fixed-width name slot so arrows don't jump;
  hyperbliss: "panels don't move; users navigate by location memory" - the prerequisite for label-free.
* **Numbered rows, digit opens pane in place** (capitalandcompute dashboard: 8 rows, "type the digit";
  cctop: six cells, digit opens body, `0` home, `?` keys; hamzafer; Button `hotkey` fires from an empty
  prompt). One number per row; detail one keypress away. Their finding: separate rows beat cramming one
  status line ("became too crowded to read at a glance").
* **State glyph vocabulary** (zellaude): `◆` starting `●` thinking `⚡` Bash `◉` read/search `✎` edit
  `⊜` subagent `◈` web `⚙` other `▶` waiting for prompt `⚠` waiting for permission `✓` done `○` idle,
  + elapsed after 30 s so stuck sessions stand out. Map your own set once, reuse across cells/toasts.
* **Provenance marker**: Claude-Code-Usage-Monitor labels numbers `official | local_estimate |
  experimental | unknown` and falls back to a labelled estimate when the official capture is stale. Use a
  tiny `~` prefix for estimates (e.g. $, forecasts).
* **Freeze / "reset" states**: show `reset` when a window rolled and no new reading arrived (weektoken);
  freeze at limit-hit (Usage Monitor) instead of showing stale %.
* **No ticking seconds** in always-visible spots (HN); minute granularity, `refreshInterval` 10 s max.
* **Progressive disclosure in 3 tiers**: footer shows 3-5 keys, `?` overlay, docs (hyperbliss). Mods:
  band -> `/pane` -> `/pane` tabs.
* **Colour discipline**: semantic slots (text.muted / status.warn ...) instead of hex (hyperbliss, Opaline,
  Bubble Tea charter); "usable at 16 colours, beautiful at true colour", honour `NO_COLOR`; never colour-only
  (pair with glyph); three background layers ~5-8 % lighter instead of borders; dim = secondary,
  reverse = focus. Keep one hue per quota until exhausted (weektoken / Apple rings).
* **Degrade to the band when no pane fits** (`$.ui.open().isPlaced === false`, Blast Radius) and design for
  80 columns first (charter; Anthropic guide draws the same tree for dock and inline).

Beloved-TUI notes (sources: hyperbliss.tech/blog/terminal-renaissance, btop/starship/posting READMEs,
the comnam90 "TUI Design Charter" gist; stars today: lazygit 82,991, starship 60,183, yazi 42,687, btop
34,905, k9s 34,761, bottom 14,090, posting 12,493, harlequin 6,451)
* btop: braille graphs, 24-bit gradient themes, selectable graph symbol, every button's highlighted key is
  clickable, presets, fast. Lesson: one graph vocabulary, themeable.
* lazygit / btop / Unifly: **persistent multi-panel** = spatial memory is the navigation.
* k9s: drill-down stack with `:resource` jump, `pulses` overview view, skins; yazi: Miller columns
  (parent/current/preview) - hierarchical data flows left-to-right; harlequin: IDE 3-panel
  (navigate / work / inspect); posting: "jump mode", command palette.
* starship: modules are context-sensitive and silent unless relevant.
* Bubble Tea charter: header / content / footer; max 3 bands on 80x24; footer = keybinding hints +
  transient status; mode always visible; destructive = confirm.

Performance / trust lessons (from usage-tool issue trackers)
* Accuracy is the #1 complaint class for usage monitors: ccusage #288/#483/#487 ("Live Blocks not accurate,
  limit reached earlier", 27 comments), #298 "shows normal usage but limit is reached"; Usage Monitor #137
  (not accurate without subagent monitoring), #48; ccstatusline #109 (context underreported), #126 (use
  CC's own `context_window`, 20 +1); claude-hud #666 (double-counts cache_read on advisor turns).
  => Prefer `$.session.usage()` official numbers over transcript math; label estimates.
* Don't poll APIs per session: claude-hud #173 (16 +1), #187, #275, #333 (persistent `⚠ 429`, multiple
  windows hammering the usage endpoint). `rateLimits` from `session.measure` costs nothing.
* CPU / spawn loops: ccusage statusline #459 (infinite spawn, 100 % CPU), ccstatusline #397 (high CPU with
  many sessions), claude-hud #525 (memory spike) - in-process mods avoid per-repaint process spawn (ccstatusline
  measured 633 ms per `bunx @latest` repaint on Windows vs 202 ms pinned).
* Rendering stability: flicker/scroll bugs are among the most upvoted (#769 300 +1, #1913 321 +1, #826 690
  +1, #3648 693 +1); statusline wrap/flicker without TTY (claude-hud #404/#581). Keep band height stable and
  redraw only on state change.

---------------------------------------------------------------------------------------------------

## 4. Pain points in the default Claude Code UI (with evidence)

1. **"Where did my quota go?"** - the biggest, loudest pain. #16157 (695 +1, 1,499 comments), #38335 (476
   +1, 875), #41930, #45756 (146 +1), #9424 (115 +1 weekly limits); HN tare 88 pts, claude-quota 69 pts, cc-probeline,
   Claumon. Need: per-turn price, cache rebuild flag, subagent overhead, forecast.
2. **Hidden tool/agent detail** - "Read 3 files" with no path (#21151: 186 +1), thinking hidden (#8477: 337
   +1), subagents collapsed, `--verbose` is raw JSON with "no middle ground" (claude-devtools README);
   HN 1,085-pt thread (46978710).
3. **Context visibility/accuracy** - only a coarse bar (devtools: "three-segment progress bar with no
   breakdown"), #516 (130 +1), #18456 (149 +1), `/context` vs status-line % mismatch because of the compact
   buffer (claude-hud #48/#540), annoying "context low" messages (CCometixLine patcher exists to remove them).
4. **Rate limits not exposed** - #13585 (127 +1), #21943 (50 +1), weekly reset day/time (#167), per-model
   buckets (Fable/Sonnet/Opus) only recently surfaced.
5. **Subagent / background visibility** - ccstatusline #299, #24537 (19 +1), VS Code background tasks panel
   #75863; Amux HN ("silently block on permission prompts").
6. **No "needs you / done" signal** - #13024 (81 +1); HN bell requests; Stop-hook false positives from
   subagents.
7. **No timestamps** - #44763 (94 +1), #2441 (63 +1).
8. **Interaction**: message queue (#50246: 211 +1), silly progress words (#6814: 215 +1), no multi-account
   indicator/switching (#18435: 866 +1, #30031: 75 +1 - an account/plan cell is a real need), /buddy removed
   (#45596: 1,186 +1).
9. **Statusline mechanics** (why people move to mods): command re-run per repaint (cost), `refreshInterval`
   only from 2.1.97, `cost.total_cost_usd` resets on `/clear` and "may differ from your bill",
   `context_window.used_percentage` null early in a session, `rate_limits` only on Pro/Max and only after the
   first response, status line runs only in trusted workspaces (Caprock; ccstatusline docs), no list of
   running background agents in the payload (ccstatusline #299).
10. **Unseen config bloat** - MEMORY.md truncation at 200 lines/25 KB is silent; idle MCP tool schemas
    ride along every request (capitalandcompute).

---------------------------------------------------------------------------------------------------

## 5. Source index

Statuslines: https://github.com/jarrodwatts/claude-hud (28.4k) | https://github.com/sirmalloc/ccstatusline
(13.2k; README changelog = widget list) | https://github.com/Owloops/claude-powerline (1.2k; README = segment
list, pace, cacheTimer, autocompact) | https://github.com/Haleclipse/CCometixLine (3.5k) |
https://github.com/nilbuild/claude-statusline (1.4k, minimal) | https://github.com/leeguooooo/claude-code-usage-bar (377) |
https://statuslin.es/status-lines/best (most-copied) | https://github.com/MackDing/awesome-claude-statusline (80+ projects) |
https://caprock.dev/guides/claude-code-statusline/ (what stdin gives / can't) | https://ccusage.com/guide/statusline |
https://www.aihero.dev/creating-the-perfect-claude-code-status-line
Mods: https://github.com/anthropics/claude-code/issues/91870 | https://github.com/karanb192/awesome-claude-code-mods |
https://github.com/hamzafer/claude-code-mods | https://github.com/narrowstacks/claude-code-mods |
https://github.com/augiefra/claude-mods (token-weather-usage) | https://github.com/3dnow/claude-mods (weektoken) |
https://github.com/scasella/claude-flightdeck | https://github.com/tomstagl/cctop | https://github.com/arasovic/claude-code-mods |
https://github.com/OneWave-AI/claude-code-mods | https://github.com/sezaakgun/cc-arcade |
https://github.com/tzafrir/whats-agent-doing | https://github.com/Arunjay4213/claude-mods |
https://capitalandcompute.net/blog/claude-code-mods-for-monitoring-a-session/ (numbered rows) |
https://capitalandcompute.net/blog/best-claude-code-mods/ | https://claude.dev/blog/getting-started-with-claude-code-mods/
Companions: https://github.com/Maciek-roboblog/Claude-Code-Usage-Monitor (8.7k) | https://github.com/smtg-ai/claude-squad (8.6k) |
https://github.com/kbwo/ccmanager (1.3k) | https://github.com/matt1398/claude-devtools (4.0k) | https://github.com/phiat/claude-esp (155) |
https://github.com/ishefi/zellaude (53) | https://github.com/hoangsonww/Claude-Code-Agent-Monitor (1.1k) | https://github.com/kelviq/tare |
https://github.com/fabioconcina/claumon
HN: 48745590 (Claudoro 50 pts), 49467551 (tare 88), 46978710 (dumbed-down 1,085), 47004712 (devtools 69),
48488753 (Claumon), 49934165 (whats-agent-doing), 49749632 (Cache-Tax).
Design: https://hyperbliss.tech/blog/terminal-renaissance/ |
https://gist.github.com/comnam90/32bda9c0a6a0fc8e9fd2b6d025f96b38 (TUI charter) | https://github.com/aristocratos/btop |
https://starship.rs/config/
Not reachable: Reddit (403 everywhere), X.
