---
name: dr
description: Development Review gate for incoming analytics tasks. Reads a board task + its attached RequestCard/БФТ, grounds every requirement claim against the real Calendar-App product code, and emits a Заключение разработки (DR) per task — findings table, effort verdict, recommendations — as DR.md + a house-style .docx. Use when user says "/dr", "/dr KLNA-NNN", "analyze this task", "write a DR", "заключение разработки", "прилетели задачи на аналитику", or pastes projects board task links for review.
---

# /dr — Development Review (Заключение разработки)

The pre-development requirements gate. We act as the **lead developer who decides whether a task's requirements are ready to be implemented**. Manager (аналитик) sends tasks for аналитику; we review the БФТ and return a DR. The governing principle: **every miss we let through becomes our bug when we start coding** — so scan carefully and ground every claim in product reality.

This is the sibling of `/klna` (which implements). `/dr` runs *before* a task is accepted for development.

## Invocation

| Arg | Behaviour |
| --- | --- |
| `/dr KLNA-NNN` | Full DR for that board task (downloads attachments, grounds, analyses, emits DR.md + .docx). |
| `/dr KLNA-NNN KLNA-MMM` | Several tasks; do them one at a time, and check for cross-task dependencies between them. |
| `/dr` (no arg) | Ask which task key(s) or board links to review. |

Output lives in `~/docspacevault/Tasks/<KEY>/`: `DR.md` (source of truth) + `DR-<id>.docx` (manager-ready).

## Non-negotiables

1. **Ground in product reality.** The strongest DR findings are "БФТ says X exists / works like Y, but the product actually does Z." Never assert a gap from the БФТ text alone — confirm against the real Calendar-App code (`/home/user76/code/Calendar-App/src`). Cite concrete refs (enum values, file paths, components).
2. **Blast-radius autonomy.** Reading the board, downloading attachments, writing files in the vault, running the python tools, searching code → **autonomous**. Posting to the board, attaching the docx, sending anything to the manager → **world action, ALWAYS ask first.**
3. **Don't invent product facts.** If you can't confirm a claim in code, frame it as a question/dependency to the постановщик, not as a stated fact.
4. **Pause** and ask the user when: an AC hinges on product behaviour only Vlad knows; the verdict is borderline (ready vs needs-rework); or before any world action.
5. **Python only in venv.** System python is broken on this box. Use a venv with `python-docx`: `/home/user76/Downloads/OLD/.venv/bin/python3` (fallback: any `.venv` that imports `docx`).

## Stage 0 — INTAKE

For each task key:
1. `mcp__projects__get_task` → read description and the **## Attachments** list (ids + names). The newer MCP exposes `download_attachment`; if attachments aren't listed, re-fetch get_task (the field was added).
2. `mcp__projects__download_attachment idOrKey=<KEY> dir=~/docspacevault/Tasks/<KEY>/src` → saves all files (typically `01_RequestCard*.docx` + `02_БФТ*.docx`).
3. `mcp__projects__list_comments` — attachments/clarifications sometimes arrive as comments.
4. First time only / if format unsure: read `references/EXAMPLE_DR.md` (the manager's gold example) to match structure and altitude.

## Stage 1 — EXTRACT

Convert each `.docx` to readable markdown so you can analyse it:
```
<venv>/bin/python3 tools/docx2md.py "<src>/02_БФТ….docx" "<KEY>/_md/BFT.md"
```
Read the RequestCard (business framing, External ID, links) and the **БФТ** in full — every BR / FR / NFR / AC / Scope / DoD. The БФТ is the spec; the RequestCard is context.

## Stage 2 — GROUND (the differentiator)

Search the Calendar-App codebase for every entity the БФТ names and confirm/refute each "уже существует / по умолчанию / уровень / статус / код ошибки" claim. Useful sweeps:
- enums & contracts: `src/shared/declarations/enums/*`, entity `types.ts` / `api.ts` / `transformer.ts`
- the feature surface named in the БФТ (settings page, dialog, component)
- access/permission model, free/busy, status codes, localization keys (`src/i18n/*`)

Record concrete findings: actual enum values, what the UI currently offers, what the API payload actually contains. These become the cited evidence in Раздел A.

## Stage 3 — ANALYSE

Apply `references/REVIEW_CHECKLIST.md` across the БФТ. For every issue, classify criticality:
- **Блокирующее** — cannot start dev (model mismatch, internal contradiction, missing contract, unresolved cross-task dependency).
- **Существенное** — must clarify before estimate/implementation (undefined mapping, underspecified edge case, NFR not concretised).
- **Незначительное** — clarify in passing (naming, i18n, minor UX/error states).

Then decide:
- **Effort (Раздел B):** give hours only if no blocker remains; otherwise `n/a` with the explicit list of what must be fixed first (mirrors the example).
- **Verdict (Решение):** `Готово к разработке` or `Требуется доработка БФТ`.

## Stage 4 — AUTHOR DR

Copy `templates/DR_TEMPLATE.md` to `~/docspacevault/Tasks/<KEY>/DR.md` and fill it. Keep the exact section structure (the docx generator parses it):
- Title block + meta table (RC ID / SRS ID / ADR ID / External ID / Рецензент / Дата / Решение).
- Раздел A — findings table `№ | FR/NFR ID | Замечание | Критичность`.
- Раздел B — effort table `FR/NFR ID | Задача | Роль | Часы | Допущения` + ИТОГО row.
- Раздел C — `Вывод:` paragraph + numbered recommendations.
- DR ID = `DR-CS2024-2026-<ExternalID>-<FE|BE|DEV>`. Default discipline **FE** (we own Calendar frontend); BE items go in as dependencies. Confirm the discipline suffix/owner with the постановщик if unsure.
- Рецензент = the reviewer (Полевой Владислав). Дата = today.

## Stage 5 — RENDER

```
<venv>/bin/python3 tools/dr_to_docx.py "<KEY>/DR.md" "<KEY>/DR-<id>.docx"
```
The generator reproduces house style (18pt bold title, blue Раздел headings, grey meta label column, dark-blue table headers). Verify it reads back (table count + Решение cell).

## Stage 6 — REPORT

Summarise to Vlad: per task, the verdict, the blocking findings, and what the постановщик must fix. **Do not** post to the board or attach the docx without explicit approval. The projects MCP has no file-upload and no edit/delete-comment — docx attachment is manual in the web UI; board comments are append-only.

## Notes / gotchas

- Two tasks that are "этап 1 / этап 2" of one initiative are almost always **mutually dependent** — check whether one honours a setting the other creates. Flag sequencing explicitly.
- "По умолчанию" / "уже предусмотрено" in a БФТ are the highest-yield claims to verify — they're often aspirational, not current product behaviour.
- Watch for requirement-vs-contract mismatches: HTTP status codes, enum values, level/role names, status sets. The example DR's blockers were all of this shape.
