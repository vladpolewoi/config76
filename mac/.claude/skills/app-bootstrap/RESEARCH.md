# RESEARCH — tool routing, depth & citation

Research is the backbone of this skill. The framework itself was built by an 11-agent deep-research fan-out; a per-app bootstrap deserves the same rigor at smaller scale. **Answer with evidence, not vibes.** Never make the user supply a fact you could have looked up.

## Load the tools first

Most of these are deferred — their schemas aren't loaded until you fetch them. Before first use in a session, run `ToolSearch` with `select:<name>` (comma-separated) to load the exact schemas, e.g. `select:WebSearch,mcp__mobbin__search_screens,mcp__apple-docs__search_apple_docs`. If a tool errors as unavailable, fall back down the chain below.

## Routing table — question type → tool

| You need to know… | Primary tool | Fallback |
|---|---|---|
| Competitor revenue, market size, base rates, pricing benchmarks | Tavily MCP (if present) → `WebSearch` | `mcp__fetch__fetch` on a known report URL |
| App Store keyword popularity / ASO data | `WebSearch` (Appfigures, AppTweak, Sensor Tower blogs) | fetch the tool's public pages |
| Competitor 1–3★ reviews (the wedge) | `WebSearch` for review aggregators / App Store pages | `mcp__fetch__fetch` on the App Store listing |
| UI / flow / paywall / onboarding / share-card / settings patterns | `mcp__mobbin__search_screens`, `search_flows`, `search_sections` | `WebSearch` for teardowns |
| Apple APIs, entitlements, capabilities, WWDC guidance | `mcp__apple-docs__search_apple_docs`, `get_apple_doc_content`, `search_wwdc_content`, `get_platform_compatibility` | `WebSearch` developer.apple.com |
| StoreKit / RevenueCat / PostHog / Sentry SDK usage | `context7__resolve-library-id` → `context7__query-docs` | apple-docs / `WebSearch` |
| Patterns already proven in the user's own apps | `Grep` / `Glob` / `Read`; `Explore` agent for fan-out | — |

The user ships many iOS apps (BookNotes76, budget76, SpanishLearn76, HabitShare76, Tend…). **Check the codebase before researching externally** for anything they've likely already solved — analytics wiring, paywall/StoreKit, the canonical settings screen, compliance setup. Reuse beats re-research.

## Fan-out policy (deep, measured)

- **Default: research inline** in the main thread so findings stay in context and you can grill immediately.
- **Fan out only when a phase has several genuinely independent open questions** that don't depend on each other — e.g. Phase 2 (keyword demand ‖ competitor revenue ‖ review mining) or Phase 9 (keyword research ‖ screenshot patterns ‖ channel norms). Spawn `general-purpose` or `Explore` subagents, one per independent question, then synthesize.
- **Never fan out for a single lookup**, and never fan out just to "look thorough." One focused agent per real, separable question. Give each a tight brief and ask for a cited conclusion, not a file dump.

## Depth expectations

- Read the **whole** framework doc for the phase before researching — it already contains vetted 2025–2026 numbers and verdicts; your job is to specialize them to this app, not rediscover them.
- Triangulate market claims across ≥2 sources before treating them as decision-grade.
- Prefer primary/recent sources (2025–2026). The framework's numbers are dated; flag anything that looks stale and re-verify.
- Distinguish **fact** (cite it) from **recommendation** (label it as your call). The user is deciding; give them the evidence and your pick, separately.

## Citation rules

- Every output doc that used research ends with a `## Sources` list: `- <claim> — <source/URL> (<date accessed>)`.
- In the decision log, note when a decision was driven by a specific finding.
- If a claim couldn't be verified, say so in the doc rather than presenting it as fact — mark it `⚠️ unverified`.
- When a decision fights a framework load-bearing number, cite the number and make the user override it consciously.
