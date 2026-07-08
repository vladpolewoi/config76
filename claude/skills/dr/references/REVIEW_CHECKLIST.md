# DR Review Checklist — the review lens

Run every БФТ through these passes. Each hit becomes a Раздел A row. The single highest-yield question throughout: **"does this match what the product actually does?"** — verify in code, don't trust the prose.

## 1. Model & terminology vs product reality  → usually Блокирующее
- Does the БФТ describe a permission/access/state model that differs from the product's? (allow-by-default vs explicit-grant; deny-record vs absence-of-record; role names; enum values.)
- Are named "levels/roles/statuses" actually present in the enums? (`src/shared/declarations/enums/*`). A claimed level that doesn't exist, or that collides with an existing value's meaning, is a blocker.
- Do quoted **HTTP status codes / error codes** match the real backend contract?
- Do named **statuses** (free/busy/tentative/OOF, etc.) exist, or only a subset?

## 2. Internal contradictions  → Блокирующее
- Scope §OutScope excluding something an FR/AC requires.
- Two FRs/ACs that can't both hold.
- DoD promising behaviour no FR defines.

## 3. Cross-task / cross-этап dependencies  → Блокирующее
- "этап 1 / этап 2" pairs: does one task honour a setting/state the other task creates? Which must ship first? Can task A even be tested before task B exists?
- External system dependencies (BE endpoint, directory/groups, migration) not yet available.

## 4. Data model & persistence  → Блокирующее / Существенное
- New persisted entity, field, or enum value required? Migration implied (DoD "изменения схемы данных")?
- Uniqueness / single-active-record assumptions — does the current model enforce them?

## 5. API / contract gaps  → Существенное (often Блокирующее for estimate)
- Which endpoint serves this? Response shape defined? Batch vs per-item?
- **Server-side vs client-side filtering**: if an NFR forbids leaking data via API, the filtering MUST be server-side. Check the actual payload — does it already carry fields that should be hidden? (privacy leak on the wire / via non-web clients).

## 6. Privacy & security  → Существенное / Блокирующее
- Does the current payload leak details the requirement says to hide? (cite the type/transformer.)
- Enforcement point: web UI only, or at the data source (so CalDAV/external clients can't bypass)?
- Abuse/probing: does an "on-by-default" model let anyone harvest data trivially? Does an NFR claim a guard that the FRs don't actually provide?

## 7. Testability per AC  → Существенное / Незначительное
- Is each AC unambiguously verifiable? Flag undefined terms: "в пределах прав", "поддерживаемые сценарии", "понятное состояние", "существующая логика" — these need a concrete mapping/list or they can't be tested or built.
- Missing field×level / state×condition matrices.

## 8. Edge cases  → Существенное / Незначительное
- Timezones; all-day → interval mapping (reference TZ?); recurring instances (which window?); caching & invalidation; concurrency (rapid add/remove); group-conflict resolution; empty/error/loading states; failure isolation (one item's failure must not break the whole view).

## 9. NFRs concretised  → Существенное / Незначительное
- Performance: batch? lazy? large N behaviour.
- Localization: new labels/states need approved strings per supported language.
- Validation: invalid-input behaviour + error surface.

## 10. Hygiene  → Незначительное
- Product naming consistent (e.g. «Р7-Календарь» vs «Календарь КС24»).
- Versions/dates/owner present on the БФТ.

---

## Effort verdict
- Any **Блокирующее** open → Раздел B = `n/a`, list exactly what must be fixed before estimating (mirror the example DR). Don't guess hours over an undefined contract.
- Only Существенное/Незначительное → may estimate, stating assumptions.

## Решение
- `Требуется доработка БФТ` if any Блокирующее (or enough Существенное to prevent a safe estimate).
- `Готово к разработке` only if nothing blocks implementation or estimation.

## Criticality calibration (one line each)
- **Блокирующее** — start coding and you'll build the wrong thing or hit an undefined contract.
- **Существенное** — you could start, but you'd guess on something that changes the design or estimate.
- **Незначительное** — safe to resolve during implementation; note it so it isn't forgotten.
