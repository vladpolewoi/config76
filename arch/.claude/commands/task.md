# Task Workflow

**Input:** $ARGUMENTS (subcommand + arguments)

---

## Subcommands

Parse the first word of `$ARGUMENTS` to determine the subcommand:

- `init <BOARD-ID>` — Initialize new task
- `log` — Log analysis, decisions, alternatives
- `commit` — Generate regulated commit
- `sc` — Generate Solution Card
- `handoff` — Generate Handoff to Testing sheet
- `verify` — Generate Verification Map
- `publish` — Generate Control Record
- `bundle` — Export all docs for attachment
- `status` — Show progress and what's missing

If no subcommand or unrecognized — show available commands and current task status.

**Vault path:** `~/docspacevault/Tasks/`

---

## Subcommand: `init`

**Usage:** `/task init KLNA-477`

1. Ask the user for:
   - BOARD ID (from argument, e.g. KLNA-477)
   - RC (from PM, or n/a)
   - External ID (e.g. CS24-2553)
   - Module (Disk, Management, Mail, Calendar, Contacts, Projects, Pages, Forms)
   - Owner name
   - Task title (in Russian, from the bug/feature description)
   - PUBLIC line (English, neutral, professional — for external commit history)
   - Source (bug report / feature request / improvement)

2. Create folder structure:
```
~/docspacevault/Tasks/<EXTERNAL-ID>/
├── task-context.yaml
├── WORKLOG.md
```

3. **task-context.yaml** format:
```yaml
RC: <from PM or n/a>
REQ: # TBD — fill from spec/BFT
OWNER: <name>
BOARD: <BOARD-ID>
PUBLIC: "<English neutral description>"
MODULE: <module>
EXTERNAL_ID: <external-id>
TITLE: "<Russian title>"
SOURCE: <bug report / feature request / improvement>
AC: # TBD — fill acceptance criteria
CREATED: <today's date>
STATUS: initialized
```

4. **WORKLOG.md** format:
```markdown
# <BOARD-ID> — <TITLE>

**RC**: <rc>
**BOARD**: <board>
**REQ**: TBD
**Module**: <module>

---

## Analysis
<!-- Root cause, investigation findings -->

## Decisions
<!-- Chosen approach and WHY -->

## Alternatives Considered
<!-- What was rejected and WHY -->

## Code Zones
<!-- Components, files, functions affected -->

## Implementation Notes
<!-- Key details during coding -->

## Testing
### Manual
<!-- Manual test scenarios -->

### Automated
<!-- Auto test coverage -->

## Risks
<!-- Potential regressions, limitations -->

## Session Handoff
### <today's date>
- Task initialized
```

5. Validate completeness — warn if RC is n/a (acceptable but noted).

---

## Subcommand: `log`

**Usage:** `/task log`

1. Find the current task — look for task-context.yaml in:
   - Current git branch name → match to BOARD ID
   - If not found, check `~/docspacevault/Tasks/*/task-context.yaml` for recent tasks
   - If multiple, ask user which task

2. Ask: "What do you want to log?" and offer categories:
   - **finding** — add to Analysis section
   - **decision** — add to Decisions section (include WHY)
   - **alternative** — add to Alternatives Considered (include WHY rejected)
   - **code** — add to Code Zones
   - **risk** — add to Risks
   - **note** — add to Implementation Notes

3. Append to the appropriate section in WORKLOG.md with timestamp.

4. If the user doesn't specify a category, infer from context or ask.

---

## Subcommand: `commit`

**Usage:** `/task commit`

1. Read task-context.yaml for the current task (find by branch or ask).

2. Read staged changes (`git diff --cached`).

3. Generate a regulated commit message:

**Header format:** `<Module>: <factual neutral description>`
- No gitmoji, no WIP, no tmp, no fix typo, no misc
- Professional, neutral, factual

**Body format:**
```
Что изменено:
• <bullet points of what changed>

Почему:
• <bullet points explaining why>

Что проверено:
• <bullet points of what was tested>

RC: <from context>
REQ: <from context>
OWNER: <from context>
PUBLIC: <from context — MUST be clean, no internal URLs/branches/org names>
BOARD: <from context>
TEST: <manual/auto description>
DOC: <n/a or doc reference>
AC: <acceptance criteria IDs this commit addresses, or n/a>
```

4. **Validate before committing:**
   - PUBLIC line has no internal URLs, branch names, "Merge pull request", org names
   - All 6 mandatory trailers present (RC, REQ, OWNER, PUBLIC, TEST, DOC)
   - Header is professional and neutral
   - No WIP/tmp/fix/misc in header

5. Show the full commit message to the user for review.

6. **Ask before committing** — never auto-commit.

7. Log key commit info to WORKLOG.md Implementation Notes.

---

## Subcommand: `sc`

**Usage:** `/task sc`

1. Read task-context.yaml and WORKLOG.md for the current task.

2. Read git log for commits related to this BOARD ID.

3. Generate Solution Card from template (9 sections):

```markdown
# Solution Card

## 1. Идентификация

Task title: <from TITLE>
RC: <from context>
REQ: <from context>
BOARD: <from context>
Owner: <from context>
Product block: <from MODULE>
Components / repositories: <from WORKLOG Code Zones>

## 2. Основание

Источник запроса: <from SOURCE>
БФТ / спецификация: <from REQ details>
Acceptance criteria:
<from AC in context or WORKLOG>
In Scope:
<from WORKLOG Analysis/Decisions>
Out of Scope:
<infer from WORKLOG or ask>

## 3. Решение

Краткое описание: <from WORKLOG Decisions>
Почему выбрано: <from WORKLOG Decisions — the WHY>
Альтернативы: <from WORKLOG Alternatives>
Ограничения: <from WORKLOG Risks>

## 4. Архитектурное основание

ADR: <n/a or reference>
CR: <n/a or reference>
DCR: <n/a or reference>
Смежные задачи: <n/a or reference>

## 5. Реализация

Затронутые компоненты: <from WORKLOG Code Zones>
Зоны кода: <from WORKLOG Code Zones>
Ключевые коммиты: <from git log>
PUBLIC: <from context>

## 6. Проверяемость

Ручная проверка: <from WORKLOG Testing Manual>
Авто: <from WORKLOG Testing Automated>
Риски: <from WORKLOG Risks>

## 7. Публикация

Target repository: <from git remote>
Target branch: stage
Target head SHA: <from git log or "после merge">
Control record ID: <n/a or reference>
Дата: <today>

## 8. Риски

<from WORKLOG Risks>

## 9. Подтверждение

Статус: подготовлено
```

4. Save to `~/docspacevault/Tasks/<EXTERNAL-ID>/SC.md`

5. Show the user for review and edits.

---

## Subcommand: `handoff`

**Usage:** `/task handoff`

1. Read task-context.yaml, WORKLOG.md, and SC.md.

2. Generate Handoff to Testing and Publication sheet:

```markdown
# Handoff to Testing and Publication

## 1. Идентификация

Task title: <from TITLE>
RC: <rc> | REQ: <req> | BOARD: <board>
Owner: <owner>

## 2. Основание

Solution Card: Tasks/<EXTERNAL-ID>/SC.md
Verification Map: Tasks/<EXTERNAL-ID>/VERIFY.md
Acceptance criteria: <from AC>
ADR/CR/DCR: <references or n/a>
Особые условия: <from WORKLOG Risks>

## 3. Поставка

Source repo: <from git remote>
Source branch: <current branch>
Target repo: <target>
Target branch: stage
HEAD SHA: <git rev-parse HEAD>
Ключевые коммиты: <from git log>
PUBLIC: <from context>

## 4. Ручное тестирование

Сценарии: <from WORKLOG Testing Manual>
Обязательные проверки: <from AC>
Исключения: <if any>
Ответственный: <owner>

## 5. Автоматическое тестирование

Проверки: <from WORKLOG Testing Automated>
Обязательное покрытие: <if specified>
Исключения: <if any>
Ответственный: <owner>

## 6. Решение о публикации

Публикация: да/нет
Авторизовал: TBD
Дата/время: <today>
Control record ID: TBD

## 7. Результаты тестирования

Ручное: ожидает
Автоматическое: ожидает

## 8. Закрытие

Статус: подготовлено к тестированию
```

3. Save to `~/docspacevault/Tasks/<EXTERNAL-ID>/HANDOFF.md`

---

## Subcommand: `verify`

**Usage:** `/task verify`

1. Read task-context.yaml, WORKLOG.md, SC.md, and git log.

2. Generate Verification Map — one row per requirement/AC:

```markdown
# Verification Map

## Идентификация

Task: <TITLE>
RC: <rc> | REQ: <req> | BOARD: <board>

## Traceability Matrix

| # | Требование/Критерий | Что реализовано | Где (компонент/файл) | Коммиты | SC ref | Ручная проверка | Авто проверка | Ожидаемое свидетельство | Факт. свидетельство | Статус | Ответственный |
|---|---|---|---|---|---|---|---|---|---|---|---|
| AC-01 | <from AC> | <from WORKLOG> | <from Code Zones> | <from git log> | SC.md §3 | <method> | <method or n/a> | <expected> | <actual or TBD> | готово/ожидает | <owner> |

## Риски и ограничения

<from WORKLOG Risks>

## Подтверждение

Статус: подготовлено
```

3. Save to `~/docspacevault/Tasks/<EXTERNAL-ID>/VERIFY.md`

---

## Subcommand: `publish`

**Usage:** `/task publish`

1. Read all task docs (context, WORKLOG, SC, HANDOFF, VERIFY).

2. Generate Control Record:

```markdown
# Control Record

RC: <rc>
REQ: <req>
OWNER: <owner>
BOARD: <board>

Solution Card: Tasks/<EXTERNAL-ID>/SC.md
Handoff Sheet: Tasks/<EXTERNAL-ID>/HANDOFF.md
Verification Map: Tasks/<EXTERNAL-ID>/VERIFY.md

Спецификация: <ref>
ADR/CR/DCR: <refs or n/a>

Source commits: <commit range from git log>
Target repo: <target>
Target branch: stage
Target HEAD SHA: <sha>

DoD: <checklist status>
Testing: <ref to test results>
Acceptance: ожидает

Дата: <today>
```

3. Save to `~/docspacevault/Tasks/<EXTERNAL-ID>/CONTROL-RECORD.md`

---

## Subcommand: `bundle`

**Usage:** `/task bundle`

1. Find all docs for the current task in `~/docspacevault/Tasks/<EXTERNAL-ID>/`.

2. List all generated docs with status:
   - ✅ exists / ❌ missing for each:
     - task-context.yaml
     - WORKLOG.md
     - SC.md
     - HANDOFF.md
     - VERIFY.md
     - CONTROL-RECORD.md

3. If any are missing, warn and offer to generate them.

4. Show the user a summary:
```
Task <BOARD> (<EXTERNAL-ID>) — ready to attach:
✅ Solution Card (SC.md)
✅ Handoff Sheet (HANDOFF.md)
✅ Verification Map (VERIFY.md)
✅ Control Record (CONTROL-RECORD.md)

All docs are in: ~/docspacevault/Tasks/<EXTERNAL-ID>/
Attach these to the task tracker as .docx or .md.
```

---

## Subcommand: `status`

**Usage:** `/task status`

1. Read task-context.yaml and check which docs exist.

2. Map to the 9-stage flow with responsibilities:

```
Stage 1: Registration       — ✅/❌  │ PM (руководитель проекта)
  (EXTERNAL-ID, RC, REQ, AC, spec)  │ provides all inputs
                                     │
Stage 2: Completeness Check  — ✅/⚠️  │ PM + Dev Lead
  (RC, REQ, AC, scope, ADR/CR/DCR)  │ confirm ready for dev
                                     │
Stage 3: Internal Task       — ✅/❌  │ PM
  (BOARD linked to external ID)      │ creates internal task
                                     │
Stage 4: Solution Card       — ✅/❌  │ Dev Lead ← YOU write it
  (SC.md)                            │ after implementation
                                     │
Stage 5: Implementation      — ✅/❌  │ Developer ← YOU
  (commits with BOARD trailer)       │ Dev Lead owns quality
                                     │
Stage 6: Testing             — ✅/❌  │ QA Manual + QA Auto
  (HANDOFF.md)                       │ you provide handoff sheet
                                     │
Stage 7: Verification        — ✅/❌  │ QA Manual + QA Auto + Dev Lead
  (VERIFY.md)                        │ shared responsibility
                                     │
Stage 8: Publication         — ✅/❌  │ Dev Lead (exec) + PM (approves)
  (CONTROL-RECORD.md)                │ PM must authorize
                                     │
Stage 9: Closure             — ✅/❌  │ PM (all 4 leaders confirm)
  (manual — update external board)   │ full package required
```

3. Show what the next action should be and who is responsible.

---

## Session Handoff

When ending a conversation or switching context, **always** append a handoff entry to WORKLOG.md:

```markdown
### <today's date>
- Current stage: <stage number and name>
- What was done: <summary>
- What's next: <next steps>
- Blockers: <if any>
```

This ensures the next conversation can pick up exactly where you left off.

---

## Rules

### Commit rules (CRITICAL)
- **Header**: Professional, neutral, factual. No gitmoji, no WIP, no tmp, no fix, no misc
- **Body**: Three sections — Что изменено / Почему / Что проверено
- **Mandatory trailers**: RC, REQ, OWNER, PUBLIC, TEST, DOC
- **Conditional trailers**: BOARD, AC, CR, DCR, ADR
- **PUBLIC line**: MUST be clean — no internal URLs, branch names, "Merge pull request", org names
- **Always ask before committing**

### Document rules
- SC is written AFTER implementation, documents what was done
- WORKLOG is the living document — log everything as you go
- All docs reference each other via links
- Verification Map must trace every AC to a commit

### Code rules
- Follow existing codebase patterns
- Run lint after changes
- Stay within In Scope
- Split work into small, verifiable commits
