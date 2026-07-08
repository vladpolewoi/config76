# PHASES — per-phase playbooks

Read the relevant section **before** starting a phase. Each phase follows the same rhythm:

> **Read** the framework doc(s) in full → **Research** the open questions with the right tools → **Grill** the user one question at a time (with a recommended answer each time) → **Honor the gate** → **Write** the output doc + update the decision log & status table in `00-INDEX.md`.

Every phase ends by (a) writing/finishing its output doc from [TEMPLATES.md](./TEMPLATES.md), (b) appending its decisions to the decision log, (c) flipping its status to ✅, and (d) for `[general]` docs, mirroring to the vault.

Carry decisions forward: each phase opens by restating the upstream decisions it depends on (from the decision log) so nothing drifts.

---

## Phase 1 — Idea & niche → `01-strategy-one-pager.md`
**Framework:** `10 Business Foundations` (also skim the MOC lifecycle step 1).

**Research first:**
- Competitor scan for the space (web): who exists, positioning, review sentiment, rough scale.
- Mobbin: what the incumbents' apps look/flow like (screens + flows) — grounds the "UNLIKE".
- If the user has an adjacent shipped app, read its docs/memory for audience learnings.

**Grill (in order, one at a time):**
1. **Audience → problem → solution → product** chain — force the specific ICP, not "everyone". Who exactly, what painful recurring problem, why now.
2. **Positioning: FOR [who] WHO [need] UNLIKE [alt] OURS [key differentiator].** Draft it; sharpen every fuzzy word.
3. **The key bet** — the one thing that must be true for this to work.
4. **Pre-committed kill criteria** — the numbers/dates at which the user walks away. Get these *before* emotional investment grows.
5. **Niche scorecard** (from doc 10): score the niche out of 40 across its criteria; apply the vetoes.

**Gate 1:** scorecard **≥27/40** and **zero** veto triggers. If it fails, say so and stop pushing forward — record the failing dimension and let the user decide to pivot or proceed knowingly.

**Output:** strategy one-pager. `[general]` → mirror to vault.

---

## Phase 2 — Validation ($0–100, no code) → `02-validation-memo.md`
**Framework:** `08 App Creation Process` (validation stage).

**Research first (this phase is mostly research):**
- **Keyword/App Store demand:** popularity of the core search terms (target ≥30–40 popularity). Use web/ASO sources; note methodology.
- **Competitor revenue:** Appfigures / Sensor Tower / public RevenueCat data via web — is there money in this space?
- **Review mining:** pull 1–3★ reviews of the top 3–5 competitors (web / App Store), extract the recurring complaint = the wedge. Aim to characterize 200+ reviews' worth of signal even if sampled.

**Grill:**
1. Confirm the wedge you found is the one to attack (present the mined evidence).
2. Is demand proof sufficient to justify building? (Present the keyword + revenue evidence; recommend GO/NO-GO.)
3. Any cheap validation the user should run before code (landing page, waitlist, DM outreach)?

**Gate 2:** demand proof — keyword popularity clears the bar, competitors show revenue, a specific wedge is named. Weak demand = record it and recommend not building or re-scoping.

**Output:** validation memo (with cited evidence). `[general]` → mirror to vault.

---

## Phase 3 — Define (PRD) → `03-PRD.md`
**Framework:** `08 App Creation Process` (lean PRD section).

**Research first:** Mobbin for the core-loop screens of best-in-class analogues; apple-docs for any platform capability the core loop leans on (so scope is realistic).

**Grill — the lean 10-section PRD, section by section.** The **Non-goals** and **Scope cuts** sections are the money sections — spend the most time there; a tight v1 is the point. For each:
1. Problem & target user (inherit from Phase 1).
2. Core loop / the one job v1 does.
3. Feature list for v1 — then aggressively cut.
4. **Non-goals** — what v1 explicitly will NOT do.
5. **Scope cuts** — features considered and deliberately deferred, with why.
6. Success metrics (ties to Phase 6 activation event).
7. Key risks & unknowns.
8. Platform/tech constraints (inherit codebase reality).
9. Rough milestones (placeholder; Phase 10 details them).
10. Paste the **launch gate** into the PRD now (day-one discipline) — filled in Phase 9.

**Gate 3:** an explicit scope cut the user agrees to — v1 must be smaller than the instinct.

**Output:** PRD (repo only).

---

## Phase 4 — Price & unit economics → `04-pricing-unit-economics.md`
**Framework:** `02 Pricing & Unit Economics` + `10 Business Foundations`.

**Research first:** competitor price points (web), category price norms, any per-user cost drivers (API/AI/backend costs — critical if the app calls paid LLM/APIs; the user's apps often do).

**Grill:**
1. **Product-type** (subscription / one-time / freemium+IAP / consumable) from doc 02's table — recommend based on the app shape.
2. **Price anchors:** monthly, annual (default-select annual at ~50% of monthly×12), trial length (long trials convert far better — 17–32d). Recommend concrete numbers.
3. **The cost/LTV sheet:** fixed monthly cost, per-payer variable cost, expected LTV per payer, **break-even paying-sub count**.
4. **Kill/scale thresholds** — written numbers, consistent with Phase 1 kill criteria.

**Gate 4:** the break-even sub count is known and written; the model isn't underwater at realistic conversion.

**Output:** pricing & unit-economics sheet. `[general]` → mirror to vault.

---

## Phase 5 — Monetization & paywall → `05-monetization-paywall.md`
**Framework:** `01 Paywall & Monetization` + `11 Settings, Donations & Trust`.

**Research first:** Mobbin paywall + onboarding-to-paywall flows (Blinkist transparent-timeline is the framework's proven reference); apple-docs/context7 for StoreKit 2 / RevenueCat specifics.

**Grill:**
1. **Freemium vs hard paywall** — apply the framework's verdict (organic/ASO-only → freemium + aggressive Day-0 exposure; paid-acquisition → hard paywall). Recommend based on Phase 6/9 acquisition plan.
2. **Where does the paywall appear on Day 0?** (80–90% of trials start install day — it must be reachable in session one.) Name the exact placement.
3. **Free-tier limits / quota gates** (if freemium) — what's free, what's the contextual paywall trigger.
4. **Paywall design & required elements** — StoreKit-fetched price+period, trial terms, Restore, ToS/privacy links (3.1.2 compliance).
5. **Tip jar?** — consumable IAPs in Settings, supporter flag in iCloud KV. Beer money, not the business — keep it optional.

**Gate 5:** paywall Day-0 placement is decided and named; required compliance elements listed.

**Output:** monetization/paywall spec (repo only).

---

## Phase 6 — Analytics → `06-tracking-plan.md`
**Framework:** `03 Analytics & Event Logging`.

**Research first:** context7 for the chosen analytics SDK (framework default PostHog EU + RevenueCat server-truth); confirm event-taxonomy conventions.

**Grill:**
1. **The activation event** — the single event that means "this user got the value". Everything hangs off this.
2. **The ~20–40 typed `object_action` events** — draft the list together, one cluster at a time (onboarding, core loop, paywall funnel, retention surfaces). 50 clean events beat 500 messy ones; audio/long-running features use state-changes + milestones, never heartbeats.
3. **The 4 day-one dashboards** — paywall funnel, activation, retention cohorts, revenue. Confirm each is buildable from the event list.
4. **Identity:** analytics distinct ID == RevenueCat App User ID.

**Gate 6:** the activation event is chosen and the paywall funnel is expressible in the event list.

**Output:** tracking plan (repo only).

---

## Phase 7 — Retention surfaces → `07-retention-surfaces.md`
**Framework:** `04 Ratings, Reviews & Feedback` + `05 Sharing & Virality` + `07 iOS Platform Essentials & Compliance` (notifications/widgets bits).

**Research first:** Mobbin for review-prompt timing, share-card designs, notification primers; apple-docs for `SKStoreReviewController`, notifications, WidgetKit, App Intents.

**Grill:**
1. **The aha-moment(s)** that trigger the review prompt — triple-gated (event + time + version), ≤3 prompts/365d, suppression rules. Name the exact moment.
2. **Crash + feedback:** Sentry/Crashlytics + MetricKit subscriber; feedback form with auto-attached diagnostics.
3. **The share moment at an emotional peak** — what does the card say about the *poster* (not just the app)? Two formats (story 1080×1920 + square), wordmark, `pt`/`ct` attribution.
4. **Notifications:** primer after a value moment (never first launch); the local-notification retention loop.
5. **Widgets / App Intents:** ship 1 widget + 2–3 intents, or consciously defer.

**Gate 7:** aha-moment (review trigger) and share moment are both named.

**Output:** retention & surfaces spec (repo only).

---

## Phase 8 — Platform & compliance → `08-platform-compliance.md`
**Framework:** `07 iOS Platform Essentials & Compliance` + `11 Settings, Donations & Trust`.

**Research first:** apple-docs for current compliance requirements (privacy manifest, required-reason APIs, DSA trader status, encryption declaration, account deletion, age rating); the user's existing apps for a proven settings screen + compliance setup to reuse.

**Grill / assemble (much of this is a checklist to fill, not open questions):**
1. **Platform-feature matrix** — which platform features are in scope (widgets/intents early; Watch/Vision usually skip). Confirm with the user.
2. **Accessibility baseline** — Dynamic Type to AX5, VoiceOver labels, 4.5:1 contrast, Reduce Motion, String Catalogs from first commit.
3. **The compliance checklist** — privacy manifest + required-reason APIs, nutrition label, hosted privacy policy + ToS, age rating, DSA trader status (EU), `ITSAppUsesNonExemptEncryption=NO`, account deletion (if accounts), 4.3-spam distinctiveness (this dev ships many apps — each must look visibly distinct), demo account for review.
4. **Canonical settings screen** — restore, manage sub, legal links, version footer, debug menu (90% identical across the user's apps — reuse).

**Gate 8:** the compliance checklist is drafted with owners/answers, not blank.

**Output:** platform & compliance checklist (repo only).

---

## Phase 9 — Marketing, ASO & launch → `09-marketing-aso-launch.md`
**Framework:** `06 Marketing, ASO & Launch`.

**Research first:** keyword research (web/ASO tools) — title/subtitle/keyword-field candidates with zero repeated words; Mobbin/competitor screenshots for the caption+creative pattern; featuring/launch-channel norms.

**Grill:**
1. **ASO metadata:** title, subtitle, keyword field (no repeated words); screenshot captions written as OCR-indexed search phrases.
2. **First 3 screenshots:** value promise → hero use case → social proof. Queue a PPO A/B test.
3. **Locales:** fill en-GB/AU/CA metadata (free keyword real estate).
4. **The 2 channel bets** — pick *exactly two*, each with kill/scale thresholds. (Don't spread thin.)
5. **Landing page:** og:image + smart app banner.
6. **Featuring:** nomination submitted ≥3 weeks ahead.
7. **Fill the launch gate** (into the PRD + here): crash-free ≥99.5%, onboarding completion ≥60%, one real purchase verified, core-loop funnel live. Any unchecked = NO-GO.

**Gate 9:** exactly 2 channel bets chosen with numbers; launch gate filled with real targets.

**Output:** marketing one-pager + launch gate. `[general]` → mirror to vault.

---

## Phase 10 — Build plan → `10-build-plan.md`
**Framework:** `08 App Creation Process` (build stage ordering).

**Research first:** the user's codebase for reusable patterns (analytics wiring, paywall, settings) already proven in shipped apps; apple-docs/context7 for anything novel in the core loop.

**Grill / assemble:**
1. **Build order:** core loop first (tracer bullet, ~week 1) → monetization → retention → polish. Wire analytics + the accessibility/compliance baseline from the first commit (brutal to retrofit).
2. **The core-loop tracer bullet** — the thinnest end-to-end slice that proves the app. Define it precisely.
3. **Milestones** — break the PRD into vertical slices, each shippable/demoable, mapped to the phases above.
4. **Sequencing risks & dependencies.**

**Gate 10:** the core-loop tracer bullet is defined concretely enough to start building.

**Output:** build plan / roadmap (repo only). Offer to hand to `/to-issues`.

---

## Phase 11 — Assemble & review → finalize `00-INDEX.md`
**Framework:** `00 App Framework MOC` (master checklist + load-bearing numbers).

1. Walk the **Master pre-launch checklist** from the MOC and reconcile every item against the docs produced — tick what's covered, flag gaps.
2. Reconcile all decisions against the **load-bearing 2025–2026 numbers** — flag any decision that fights a benchmark.
3. Finalize the **decision log** and the **open-questions parking lot** in `00-INDEX.md`.
4. Confirm all `[general]` docs are mirrored to the vault.
5. Set the whole status table to ✅ (or note deliberate skips).
6. Offer next steps: `/to-issues` for the build plan; scheduling a re-verify of benchmark numbers; kicking off the tracer bullet.
