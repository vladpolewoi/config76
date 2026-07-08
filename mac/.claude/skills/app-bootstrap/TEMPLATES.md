# TEMPLATES — the per-app document set

Copy each skeleton into the output file when its phase starts; fill it as decisions land. Keep them terse and decided — these are commitments, not essays. Every doc opens with a status line and closes with a sources list where research was used. Replace `<App>` and `<date>` throughout.

---

## `00-INDEX.md`

```markdown
# <App> — Bootstrap Index

*One-liner: <what the app is, for whom, in one sentence>*
*Platform: iOS · Started <date> · Framework: vault76/.../App Framework*

## Status
| # | Phase | Doc | Status |
|---|---|---|---|
| 1 | Idea & niche | 01-strategy-one-pager.md | ⬜ |
| 2 | Validation | 02-validation-memo.md | ⬜ |
| 3 | PRD | 03-PRD.md | ⬜ |
| 4 | Price & unit economics | 04-pricing-unit-economics.md | ⬜ |
| 5 | Monetization & paywall | 05-monetization-paywall.md | ⬜ |
| 6 | Analytics | 06-tracking-plan.md | ⬜ |
| 7 | Retention surfaces | 07-retention-surfaces.md | ⬜ |
| 8 | Platform & compliance | 08-platform-compliance.md | ⬜ |
| 9 | Marketing, ASO & launch | 09-marketing-aso-launch.md | ⬜ |
| 10 | Build plan | 10-build-plan.md | ⬜ |

Legend: ⬜ todo · 🔟 in-progress · ✅ done

## Decision log
*Append one line per crystallized decision: `<date> — [phase] Decision — one-line rationale`.*

## Open questions (parking lot)
*Unresolved items to return to; who/what unblocks each.*

## Master pre-launch checklist
*(Pasted from the framework MOC; tick as covered by the docs above.)*
- [ ] Money: paywall reachable Day 0; 3.1.2-compliant; annual default; cost/LTV sheet filled …
- [ ] Stats: 20–40 event tracking plan; activation event; ReviewGate; crash+MetricKit; share card …
- [ ] Marketing: keywords; first 3 screenshots; locales; 2 channel bets; landing page …
- [ ] App: notifications primer; accessibility to AX5; widget/intents; settings screen …
- [ ] Compliance: privacy manifest; nutrition label; policy+ToS hosted; age rating; DSA; 4.3 distinctiveness …
- [ ] Launch gate: crash-free ≥99.5% · onboarding ≥60% · one real purchase · core-loop funnel live
```

---

## `01-strategy-one-pager.md`  `[general → mirror to vault]`

```markdown
# <App> — Strategy One-Pager

**Audience → Problem → Solution → Product**
- ICP (specific): …
- Recurring painful problem: …
- Why now: …

**Positioning**
> FOR <who> WHO <need>, <App> IS A <category> THAT <key benefit>, UNLIKE <alternative>, OURS <differentiator>.

**The key bet:** <the one thing that must be true>

**Pre-committed kill criteria:** <numbers/dates at which we walk away>

**Niche scorecard:** <score>/40  ·  Vetoes: <none / which>  ·  Gate 1: PASS/FAIL

## Sources
- …
```

---

## `02-validation-memo.md`  `[general → mirror to vault]`

```markdown
# <App> — Validation Memo

**Keyword demand:** <terms + popularity scores; bar = 30–40>
**Competitor revenue:** <who, est. revenue, source>
**Review-mining wedge:** <the recurring 1–3★ complaint we attack; sample size/sources>

**Gate 2 (demand proof):** GO / NO-GO — <why>
**Cheap validation to run (optional):** <landing page / waitlist / outreach>

## Sources
- …
```

---

## `03-PRD.md`

```markdown
# <App> — PRD (lean)

1. **Problem & user** — …
2. **Core loop** — the one job v1 does: …
3. **v1 features** — …
4. **Non-goals** — what v1 will NOT do: …
5. **Scope cuts** — considered & deferred (with why): …
6. **Success metrics** — activation = <event> (see tracking plan); north-star = …
7. **Risks & unknowns** — …
8. **Platform/tech constraints** — …
9. **Milestones (rough)** — see build plan.
10. **Launch gate** — crash-free ≥99.5% · onboarding ≥60% · one real purchase · core-loop funnel live · any unchecked = NO-GO.
```

---

## `04-pricing-unit-economics.md`  `[general → mirror to vault]`

```markdown
# <App> — Pricing & Unit Economics

**Product type:** <subscription / one-time / freemium+IAP / consumable> — why: …
**Price anchors:** monthly $__ · annual $__ (≈50% of monthly×12, default-selected) · trial __ days
**Cost/LTV sheet**
| Item | Value |
|---|---|
| Fixed cost / month | $__ |
| Variable cost / payer | $__ |
| Expected LTV / payer | $__ |
| **Break-even paying subs** | __ |
**Kill / scale thresholds:** kill if <…>; scale if <…>

## Sources
- …
```

---

## `05-monetization-paywall.md`

```markdown
# <App> — Monetization & Paywall

**Model:** freemium + Day-0 exposure / hard paywall — why: …
**Day-0 paywall placement:** <exact screen/moment>
**Free tier & quota gates:** free = <…>; contextual paywall triggers at <…>
**Paywall design:** reference = <e.g. Blinkist transparent timeline>; required elements = StoreKit price+period, trial terms, Restore, ToS/privacy links (3.1.2).
**Tip jar:** yes/no — consumable IAPs in Settings; supporter flag in iCloud KV.

## Sources
- …
```

---

## `06-tracking-plan.md`

```markdown
# <App> — Tracking Plan

**Stack:** PostHog EU + RevenueCat server-truth · distinct ID == RC App User ID.
**Activation event:** `<object_action>` — means: …
**Events** (~20–40, `object_action`, typed):
| Event | Props | Cluster |
|---|---|---|
| `screen_viewed` | screen | global |
| … | … | onboarding / core loop / paywall funnel / retention |
**Day-one dashboards:** paywall funnel · activation · retention cohorts · revenue.

## Sources
- …
```

---

## `07-retention-surfaces.md`

```markdown
# <App> — Retention Surfaces

**Review prompt (ReviewGate):** aha-moment = <…>; gates = event + time + version; ≤3/365d; suppression = <…>.
**Crash & feedback:** Sentry/Crashlytics + MetricKit; feedback form auto-attaches diagnostics.
**Share moment:** trigger = <emotional peak>; card says <about the poster>; formats = story 1080×1920 + square; wordmark + `pt`/`ct` link.
**Notifications:** primer after <value moment>; retention loop = <local notification cadence>.
**Widgets / App Intents:** <1 widget + 2–3 intents> OR consciously deferred because <…>.

## Sources
- …
```

---

## `08-platform-compliance.md`

```markdown
# <App> — Platform & Compliance

**Feature matrix:** in = <widgets, intents…>; skip = <Watch, Vision…>.
**Accessibility baseline:** Dynamic Type→AX5 · VoiceOver labels · 4.5:1 contrast · Reduce Motion · String Catalogs from commit 1.
**Compliance checklist**
- [ ] Privacy manifest + required-reason APIs
- [ ] Nutrition label matches data use
- [ ] Privacy policy + ToS hosted & linked
- [ ] Age-rating questionnaire
- [ ] DSA trader status (EU)
- [ ] `ITSAppUsesNonExemptEncryption = NO`
- [ ] Account deletion (if accounts)
- [ ] 4.3 distinctiveness vs dev's other apps
- [ ] Demo account in review notes
**Settings screen (canonical):** restore · manage subscription · legal links · version footer · debug menu.

## Sources
- …
```

---

## `09-marketing-aso-launch.md`  `[general → mirror to vault]`

```markdown
# <App> — Marketing, ASO & Launch

**ASO metadata:** title = … · subtitle = … · keyword field = <no repeated words>.
**Screenshots:** #1 value promise · #2 hero use case · #3 social proof; captions = search phrases; PPO A/B queued.
**Locales:** en-GB / AU / CA metadata filled.
**2 channel bets:** (1) <channel> — scale if <n>, kill if <n>; (2) <channel> — scale/kill …
**Landing page:** og:image + smart app banner.
**Featuring:** nomination submitted ≥3 weeks pre-launch.
**Launch gate (GO/NO-GO):** crash-free ≥99.5% · onboarding ≥60% · one real purchase verified · core-loop funnel live.

## Sources
- …
```

---

## `10-build-plan.md`

```markdown
# <App> — Build Plan

**Order:** core loop (tracer bullet) → monetization → retention → polish. Analytics + a11y/compliance baseline wired from commit 1.
**Core-loop tracer bullet:** <thinnest end-to-end slice that proves the app>
**Milestones (vertical slices):**
| # | Slice | Proves | Depends on |
|---|---|---|---|
| 1 | <tracer bullet> | core value | — |
| 2 | monetization | … | 1 |
| … | … | … | … |
**Sequencing risks:** …
**Next:** hand to /to-issues to cut tickets.
```
