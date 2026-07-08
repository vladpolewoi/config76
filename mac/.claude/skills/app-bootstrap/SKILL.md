---
name: app-bootstrap
description: Bootstrap a brand-new app by walking the whole indie App Framework doc set one module at a time — a deep grilling session that researches every open question (web/Tavily, Mobbin, apple-docs, context7, codebase) and emits a complete per-app document folder (strategy one-pager, validation memo, PRD, cost/LTV sheet, monetization spec, tracking plan, retention/compliance specs, marketing one-pager, launch gate, build plan). Use when starting a new app and you want to turn the framework's questions into a full, decided, written plan before building.
---

# app-bootstrap

Take one new app idea and run it through the **entire App Framework** — module by module — until every recurring question the framework poses is answered, researched, and written down. The output is a folder of decided documents: a strategy one-pager, a validation memo, a PRD, a cost/LTV sheet, a monetization/paywall spec, a tracking plan, retention & compliance specs, a marketing one-pager, a launch gate, and a build plan. When you finish, the user has a complete plan of everything needed to build and launch the app.

This is a **big, deep, multi-session task**. Go slow. Think hard. Research before asking. Grill relentlessly. Do not shortcut to a shallow answer — the whole point is depth.

## The framework you are walking

The App Framework lives in the vault. Locate it at kickoff (do not assume the path is current):

```
/Users/quest76/Documents/vault76/04 Areas/Metier/Indie/App Framework/
  00 App Framework MOC.md        ← entry point; the lifecycle + master checklist
  01 Paywall & Monetization.md
  02 Pricing & Unit Economics.md
  03 Analytics & Event Logging.md
  04 Ratings, Reviews & Feedback.md
  05 Sharing & Virality.md
  06 Marketing, ASO & Launch.md
  07 iOS Platform Essentials & Compliance.md
  08 App Creation Process.md
  10 Business Foundations.md
  11 Settings, Donations & Trust.md
```

Find it robustly (the folder may have moved): glob for `**/App Framework/00 App Framework MOC.md` under `~/Documents/vault76`. If missing, ask the user where it is before starting.

**Docs 09, 12, 13 are NOT part of the per-app walk.** 09 (Reusable App Skeleton) is a demoted appendix — only touch it if the user raises code-duplication pain. 12 (Learning Library) and 13 (Research Intake Loop) are meta-docs about keeping the framework alive — ignore them here, except as a place to look for *how/where* to research.

This is a **thinking framework, not a code factory** (a hard rule the user has stated). You produce per-app decisions and documents. Do NOT propose shared Swift packages, template repos, or `new-app.sh` scaffolding.

## The research arsenal

Research is not optional — every phase researches its open questions *before* grilling the user. Many of these tools are deferred; load them with `ToolSearch` (`select:<name>`) before first use. Route by question type — see [RESEARCH.md](./RESEARCH.md) for the full routing table and citation rules.

- **Web / market facts** (competitor revenue, pricing benchmarks, ASO data, base rates): Tavily MCP if present, else `WebSearch`, else `mcp__fetch__fetch` for a known URL. Appfigures / Sensor Tower / RevenueCat reports via web.
- **UI & flow patterns** (paywall designs, onboarding, share cards, settings): `mcp__mobbin__search_screens` / `search_flows` / `search_sections`.
- **Apple platform** (APIs, entitlements, compliance, WWDC): `mcp__apple-docs__*` — `search_apple_docs`, `get_apple_doc_content`, `search_wwdc_content`, `get_platform_compatibility`.
- **Library / SDK docs** (StoreKit wrappers, PostHog, RevenueCat, Sentry SDKs): `context7` — `resolve-library-id` then `query-docs`.
- **The user's codebase / existing apps**: `Grep`/`Glob`/`Read`, and the `Explore` agent for fan-out (the user ships many iOS apps — reuse patterns already proven in BookNotes76, budget76, etc.).

Research depth is **deep with measured fan-out**: research inline by default; when a phase has several genuinely independent open questions, you MAY spawn parallel research subagents (`general-purpose` or `Explore`) — the way the framework itself was built via an 11-agent fan-out. Don't fan out for a single lookup.

## Operating principles (the grill)

1. **Research first, then ask.** If a question can be answered by the framework doc, the codebase, or a tool, answer it yourself and present the finding — don't make the user do your homework. Only ask the user what genuinely needs *their* judgment, taste, or private knowledge (audience, personal goals, risk appetite, brand).
2. **One question at a time.** Ask a single question, give **your recommended answer** with the reasoning and any research behind it, then wait. Do not dump a questionnaire. (Trivial confirmations may be batched; real decisions never are.)
3. **Recommend, don't interrogate blankly.** Every question comes with a default you'd ship. The user is reacting to a proposal, not filling a void.
4. **Walk the decision tree in dependency order.** Resolve upstream decisions (niche, ICP, price model) before downstream ones (paywall copy, event names). Later phases inherit earlier decisions — carry them forward explicitly.
5. **Challenge and stress-test.** Probe with concrete scenarios and edge cases. Surface contradictions between what the user says and what the framework/benchmarks/codebase show. Push back when an answer fights a load-bearing number.
6. **Capture inline, never batch.** The moment a decision crystallizes, write it into the relevant output doc and the decision log. Do not accumulate decisions in your head to write "later."
7. **Honor the gates.** The framework's gates default to NO. Do not wave an app through a gate (niche scorecard ≥27/40, demand proof, launch GO/NO-GO) on vibes. If a gate fails, say so plainly and record it.
8. **Deep-dive mode.** This skill is meant to be run with a high-reasoning model over a long session. Prefer thoroughness over speed. It is fine — expected — for a single phase to take many turns.

## Output: the per-app document set

**Source of truth = the app repo.** Write everything to `<app-repo>/docs/bootstrap/`. Ask for the repo path at kickoff (offer to create the folder). If the app has no repo yet, create the folder wherever the user keeps the app (e.g. `~/Documents/apps/<App>/docs/bootstrap/`) or, pre-code, a plain new folder.

```
<app-repo>/docs/bootstrap/
  00-INDEX.md                  ← MOC for this app: status table, decision log, master checklist
  01-strategy-one-pager.md     ← niche, ICP, FOR/WHO/UNLIKE, key bet, kill criteria      [general]
  02-validation-memo.md        ← keyword demand, competitor revenue, review-mining wedge [general]
  03-PRD.md                    ← lean 10-section PRD; non-goals & scope cuts
  04-pricing-unit-economics.md ← product-type, price anchors, cost/LTV sheet, break-even  [general]
  05-monetization-paywall.md   ← paywall placement/design, freemium vs hard, trial, tips
  06-tracking-plan.md          ← ~30 typed events, activation event, day-one dashboards
  07-retention-surfaces.md     ← ReviewGate, crash/feedback, share moments, notifications, widgets
  08-platform-compliance.md    ← feature matrix, compliance checklist, canonical settings screen
  09-marketing-aso-launch.md   ← keywords, screenshots, 2 channel bets, launch gate       [general]
  10-build-plan.md             ← core-loop-first roadmap, milestones, tracer bullets
```

Templates for each are in [TEMPLATES.md](./TEMPLATES.md).

**Vault mirror.** After a `[general]`-tagged doc (01, 02, 04, 09) is finalized, mirror a copy into the vault at `vault76/03 Projects/Active/<App>/bootstrap/` so the user's portfolio-level strategy knowledge accrues there. The repo copy stays canonical — put a one-line header on each vault copy: `> Canonical copy: <repo path>. Mirrored <date>.` Do not mirror the code-facing docs (03, 05, 06, 07, 08, 10) — they belong only in the repo.

## Resumability

This runs across multiple sessions. On every invocation:
1. Locate the framework and the output folder.
2. If `00-INDEX.md` exists, read its **status table** and **decision log**, then resume at the first phase not marked ✅. Re-confirm nothing already decided — carry it forward.
3. If it doesn't exist, start at Phase 0.

Keep the status table in `00-INDEX.md` current as you complete each phase (`⬜ todo / 🔟 in-progress / ✅ done`), so a fresh session (or a fresh model) can pick up exactly where you left off.

## The phases

Grouped from the framework's 9-stage lifecycle. Each phase reads its framework doc(s) in full, researches the open questions, grills the user, honors the gate, and writes its output doc. Full per-phase playbooks — the exact questions, what to research, the gate, the output — are in [PHASES.md](./PHASES.md). **Read PHASES.md before starting a phase.**

| # | Phase | Framework doc(s) | Output | Gate |
|---|---|---|---|---|
| 0 | Kickoff & intake | 00 MOC | `00-INDEX.md` skeleton | — |
| 1 | Idea & niche | 10 | `01-strategy-one-pager.md` | Scorecard ≥27/40, no veto |
| 2 | Validation ($0–100, no code) | 08 | `02-validation-memo.md` | Demand proof |
| 3 | Define (PRD) | 08 | `03-PRD.md` | Scope cut agreed |
| 4 | Price & unit economics | 02, 10 | `04-pricing-unit-economics.md` | Break-even known |
| 5 | Monetization & paywall | 01, 11 | `05-monetization-paywall.md` | Paywall placement decided |
| 6 | Analytics | 03 | `06-tracking-plan.md` | Activation event chosen |
| 7 | Retention surfaces | 04, 05, 07 | `07-retention-surfaces.md` | Aha-moment + share moment named |
| 8 | Platform & compliance | 07, 11 | `08-platform-compliance.md` | Compliance checklist drafted |
| 9 | Marketing, ASO & launch | 06 | `09-marketing-aso-launch.md` | 2 channel bets + launch gate |
| 10 | Build plan | 08 | `10-build-plan.md` | Core-loop tracer bullet defined |
| 11 | Assemble & review | 00 MOC | Finalized `00-INDEX.md` | Master checklist reconciled |

## Kickoff (Phase 0) — do this first

1. **Locate** the framework (glob) and read `00 App Framework MOC.md` in full — it holds the lifecycle, the master pre-launch checklist, and the load-bearing 2025–2026 numbers you will hold everyone to.
2. **Get the concept**: ask the user for the app in one line, and the target platform (assume iOS unless told otherwise).
3. **Set the output folder**: ask for the app repo path; create `docs/bootstrap/` (offer to `git init`/create the folder if none). Note the vault mirror path `vault76/03 Projects/Active/<App>/bootstrap/`.
4. **Write `00-INDEX.md`** from the template: app one-liner, the status table (all phases ⬜), an empty decision log, and a copy of the master pre-launch checklist to tick off as you go.
5. **Confirm the plan**: show the user the 11-phase walk and that it's a multi-session grill. Then begin Phase 1.

Do not skip phases or reorder them without the user's say-so — downstream docs depend on upstream decisions. If the user only wants a subset (e.g. "just do strategy + PRD"), honor it, but flag which downstream docs will be left unfilled.

## Finishing

At Phase 11: reconcile every decision against the framework's **Master pre-launch checklist** and **load-bearing numbers**, fill the launch gate with real target numbers, list unresolved open questions in the index's parking lot, mirror the `[general]` docs to the vault, and offer to hand the build plan to `/to-issues` to cut the roadmap into tracer-bullet tickets.
