---
name: klna
description: Master orchestrator for Calendar-App regulated workflow. Drives a KLNA task end-to-end through 7 stages (intake → plan → implement → self-review → document → ship → report), emitting audit-mandated commits, SC.md, and VERIFY.md. Pauses for ambiguous AC, persistent build/test failure, unfixable review blockers, and always before world-action (git push, gh pr). Use when user says "/klna", "/klna KLNA-NNN", "run KLNA-NNN", "start the next task", or wants to drive a regulated Calendar-App task to PR.
---

# /klna — Calendar-App Master Orchestrator

Single skill replacing the old `/task` + 4-agent shadow pipeline. Solo-dev, origin-only, audit-preserved.

## Invocation

| Arg                  | Behaviour                                                                                                   |
| -------------------- | ----------------------------------------------------------------------------------------------------------- |
| `/klna KLNA-NNN`     | Drive that KLNA forward from its current `STATUS` (resume-aware via WORKLOG frontmatter).                   |
| `/klna` (no arg)     | List open tasks under `~/docspacevault/Tasks/` whose WORKLOG STATUS is not `done`, prompt user to pick one. |
| `/klna KLNA-NNN new` | Force re-INTAKE even if folder exists (asks before overwriting).                                            |

Resume by reading `WORKLOG.md` frontmatter `STATUS:` and jumping to the matching stage. Stages are idempotent — re-running a stage must not corrupt prior artifacts.

## Non-negotiables

1. **Audit format is byte-for-byte preserved.** Every commit, SC.md, VERIFY.md matches `~/docspacevault/Dev Flow/commit_protocol_spec.md` exactly. If the spec and this skill ever disagree, the spec wins.
2. **No AI artifacts in the repo.** Never create `CLAUDE.md`, `.claude/`, `.tasks/`, or any AI marker inside `/home/user76/code/Calendar-App`. All task docs live in `~/docspacevault/Tasks/<KLNA>/`.
3. **Blast-radius autonomy:**
   - **Local** (file edits, local commits, lint, build, test, vault writes, sub-agent spawn) → autonomous.
   - **World** (`git push`, `gh pr create/edit/merge`, MCP writes, any external API write) → ALWAYS ask first, show the exact command.
4. **Pause conditions** — stop and ask the user:
   - AC ambiguous or contradictory (PLAN).
   - Scope creep detected mid-IMPLEMENT (changes drifting outside Code Zones).
   - Build/lint/test fails persistently (≥ 3 auto-retry attempts on the same error).
   - Reviewer sub-agent blocks twice in a row on the same issue (SELF-REVIEW).
   - Any world action (SHIP).
5. **No gitmoji. No `Co-Authored-By`. No AI signatures anywhere.**
6. **PUBLIC line discipline.** English, neutral, no internal URLs, no org names, no branch names, no `Merge pull request`. Still enforced even though the shadow leak surface is gone — audit requires it.

## Stage 1 — INTAKE

**Goal:** materialize `~/docspacevault/Tasks/<KLNA>/` with `WORKLOG.md` (with frontmatter), `RC.md`.

1. If folder already exists and `WORKLOG.md` has a non-`initialized` STATUS, resume — do not re-intake unless user passed `new`.
2. Ask user for (one prompt, all fields, accept paste):
   - RC (e.g. `RC-CLDR-2026-005`) or `n/a`
   - REQ (e.g. `FR-01`) or `n/a` until known
   - OWNER — **always `Арсений Колесниченко`**. Vlad commits on his behalf; OWNER is the task owner, never the committer. Do not prompt unless user explicitly overrides.
   - MODULE (one of: Disk, Management, Mail, Calendar, Contacts, Projects, Pages, Forms)
   - PUBLIC (English neutral description)
   - TITLE (Russian title)
   - SOURCE (`bug report` | `feature request` | `improvement`)
   - AC list (paste — one per line, format `AC-NN: <text>`)
3. Write `WORKLOG.md` with the schema below, STATUS=`initialized`.
4. Write `RC.md` from the RC paste (or skeleton `# RC: <RC>\n\nTBD — fill from PM` if user didn't have it).
5. Confirm folder created, files written. Advance STATUS → `planning`.

### WORKLOG.md frontmatter schema

```yaml
---
KLNA: KLNA-NNN              # required, format KLNA-\d{3,}
RC: RC-CLDR-2026-NNN | n/a  # required
REQ: FR-NN | NFR-NN | n/a   # required
OWNER: <full name>          # required
MODULE: Calendar            # required, one of the 8 modules
PUBLIC: "<English text>"    # required, validated (no internal URLs/orgs/branches)
TITLE: "<Russian text>"     # required
SOURCE: bug report          # required, one of three values
AC:                         # required, list, each "AC-NN: <text>"
  - "AC-01: ..."
CREATED: 2026-05-14         # required, ISO date
STATUS: initialized         # required, one of: initialized|planning|implementing|reviewing|documenting|shipping|done
BRANCH: ""                  # filled at IMPLEMENT
PR_URL: ""                  # filled at SHIP
TOKEN_LOG: []               # appended to per stage: [{stage, model, in, out, ts}]
---
```

Validation: refuse to advance if any required field is empty or `TBD`. PUBLIC must pass leak-check regex (no URLs, no `Organization76Business`, no `TEA-`, no branch-name patterns).

### WORKLOG.md body (unchanged from old `/task init`)

```markdown
# <KLNA> — <TITLE>

## Analysis
## Decisions
## Alternatives Considered
## Code Zones
## Implementation Notes
## Testing
### Manual
### Automated
## Risks
## Session Handoff
```

## Stage 2 — PLAN

**Goal:** fill WORKLOG `Analysis`, `Decisions`, `Alternatives Considered`, `Code Zones`. Identify ambiguity.

1. **Do code exploration in the main context** — no Explore sub-agent, keeps the prompt cache warm. Grep, read, follow imports, build a mental model.
2. Draft and write into WORKLOG:
   - **Analysis:** root cause (bugs) or current-state summary (features).
   - **Decisions:** chosen approach + WHY (cite specific code locations `path:line`).
   - **Alternatives Considered:** what was rejected and WHY.
   - **Code Zones:** explicit list of files/functions that will change.
3. **AC ambiguity check** — for each AC, can you write a test or a manual reproduction? If any AC is vague, contradictory, or untestable: **PAUSE**, list the ambiguous ACs, ask user to clarify before continuing.
4. Show the user the four sections + Code Zones list. Wait for confirmation (or autonomous-advance if user said "go through end-to-end" up front).
5. Advance STATUS → `implementing`.

## Stage 3 — IMPLEMENT

**Goal:** code the change on a fresh branch, commit-per-logical-chunk with regulated format, end with green lint/typecheck.

1. **Branch hygiene:** `git fetch origin && git checkout stage && git pull` → `git checkout -b <branch>`. Branch name: `<type>/<KLNA>-<kebab-summary>` (type ∈ `fix|feat|refactor|chore`). Write branch into WORKLOG frontmatter `BRANCH:`.
2. **Edit loop:** small focused edits matching Code Zones from PLAN.
3. **Verify loop** after each logical chunk:
   - `npx tsc --noEmit`
   - `npm run lint -- --fix` (Prettier auto-formats)
   - `npm run build` (if user requests, otherwise defer to ship-time)
   - Tests if relevant (`npm test` or specific file)
4. **Auto-retry** on failure: re-read the error, attempt fix, re-run. Max 3 retries per distinct error message. On the 4th: **PAUSE**, show error, ask.
5. **Scope creep guard:** if a needed edit falls outside the Code Zones declared in PLAN, **PAUSE** and ask before expanding scope. Update Code Zones in WORKLOG if approved.
6. **Commit-per-chunk:**
   - Draft full message using the generator (below).
   - **Show full message to user, ask before committing** (per audit protocol — never auto-commit).
   - On approve: `git commit -m "$(cat <<'EOF' ... EOF)"`.
   - Append per-commit notes to WORKLOG `Implementation Notes`.
7. **Bug-type tasks:** append entry to `~/docspacevault/Tasks/<KLNA>/bugs-log.md` (or project-level `bugs-log.md` per memory rule — check existing convention before deciding).
8. Advance STATUS → `reviewing` when all Code Zones are touched and verify loop is green.

### Regulated commit generator

Header: `<Module>: <neutral imperative description>` — no gitmoji, no WIP/tmp/fix-alone, no Russian in header.

Body template:

```
Что изменено:
• <bullet>
• <bullet>

Почему:
• <bullet>
• <bullet>

Что проверено:
• <bullet>
• <bullet>

RC: <from frontmatter>
REQ: <from frontmatter>
OWNER: <from frontmatter>
PUBLIC: <from frontmatter>
BOARD: <KLNA>
TEST: <actual test method — "manual: <repro>" | "tsc clean" | "lint clean" | combo>
DOC: <"n/a" | doc reference>
AC: <comma-separated AC IDs this commit closes — omit line entirely if none>
CR: <optional>
DCR: <optional>
ADR: <optional>
```

Pre-commit validation gate (refuse to commit if any fails):
- Header matches `^(Disk|Management|Mail|Calendar|Contacts|Projects|Pages|Forms): .+`.
- Body has three Russian sections in order: `Что изменено`, `Почему`, `Что проверено`.
- All 7 mandatory trailers present.
- **OWNER trailer must be `Арсений Колесниченко`** (NEVER `Vlad Polevoi` — Vlad is the committer, not the owner). Wrong OWNER cost a force-push twice already.
- PUBLIC passes leak-check.
- No `🤖`, no `Co-Authored-By`, no `Generated with`, no `Claude`.

## Stage 4 — SELF-REVIEW

**Goal:** independent fresh-context review by a Haiku sub-agent.

1. Spawn ONE Reviewer sub-agent via the Agent tool, `subagent_type: general-purpose`, `model: haiku`. (If a dedicated reviewer subagent type ever exists, switch to it.)
2. Prompt the sub-agent with: branch name, KLNA, path to vault `Tasks/<KLNA>/`, and the embedded checklist (below). It returns the verdict format.
3. **On APPROVED:** advance STATUS → `documenting`.
4. **On APPROVED WITH WARNINGS:** record warnings in WORKLOG `Risks`, advance STATUS → `documenting`.
5. **On BLOCKED:**
   - Show blockers to user briefly.
   - Orchestrator fixes each blocker (additional commits via Stage 3 commit generator).
   - Re-request review.
   - Max 2 review retries. After 2 blocked reviews: **PAUSE**, ask user.

### Embedded Reviewer checklist (narrowed, post-shadow)

Sub-agent prompt skeleton:

```
You are a fresh-context code reviewer for a regulated solo-dev workflow.
Repo: docs-space/Calendar-App, branch: <branch>, task: <KLNA>.
Vault task folder: ~/docspacevault/Tasks/<KLNA>/

Inspect:

1. COMMIT REGULATION COMPLIANCE — for every commit in `git log origin/stage..<branch>`:
   • Header: `<Module>: <description>`, no gitmoji, no banned words (WIP, tmp, fix alone, misc, правки, разное)
   • Body has all three Russian sections in order: `Что изменено`, `Почему`, `Что проверено`
   • Mandatory trailers present: RC, REQ, OWNER, PUBLIC, BOARD, TEST, DOC
   • PUBLIC: English only, single line, no URLs, no org names, no branch names, no `Merge pull request`, no `Co-Authored-By`
   • No AI artifacts: no `🤖`, no `Co-Authored-By`, no `Generated with`, no `Claude`

2. DOC COMPLETENESS — read vault folder:
   • WORKLOG.md frontmatter fields all populated (no TBDs in required fields)
   • WORKLOG.md body sections all have real content (Analysis, Decisions, Alternatives, Code Zones, Implementation Notes, Testing, Risks)
   • RC.md exists

3. AC TRACEABILITY:
   • Collect all AC IDs from WORKLOG frontmatter.
   • Collect all AC: trailer values from commits.
   • Every AC from the task must be addressed in at least one commit OR explicitly deferred in WORKLOG Risks.
   • No commit may reference an AC not in the task list.
   • Coverage <70% = BLOCK. 70–99% = WARNING. 100% = OK.

4. CODE HYGIENE — `git diff origin/stage...<branch>`:
   • No `console.log`, no `debugger`, no commented-out code blocks
   • No unrelated file changes (outside WORKLOG Code Zones)
   • No new TODO/FIXME without a tracking note
   • No `.tasks/`, no `CLAUDE.md`, no `.claude/` introduced in the repo

5. AUDIT-LEAK CHECK (narrower than legacy — still enforced):
   • No internal URLs in commit messages
   • No `TEA-` references (legacy Linear)
   • No `Organization76Business` references (legacy shadow org)
   • PUBLIC lines pass leak rules

Output exactly:

  VERDICT: APPROVED | APPROVED WITH WARNINGS | BLOCKED

  Blockers:
  - <commit SHA or doc path> — <issue> — <suggested fix>

  Warnings:
  - ...

  Notes:
  - ...

Be strict. Solo dev means you are the last gate.
```

## Stage 5 — DOCUMENT

**Goal:** generate `SC.md` (9 sections) and `VERIFY.md` (AC→commit matrix) from WORKLOG + git log.

**Delegate generation to the `klna-scribe` subagent (cheap model).** The orchestrator
gathers WORKLOG.md + the git log, hands them to `klna-scribe`, which transcribes them
into the audit templates and returns the file content as text. The orchestrator then
validates against `commit_protocol_spec.md` and saves. Scribe does no design — all
decisions are already fixed by earlier stages. If the scribe flags a missing field or
an uncovered AC, do not paper over it — stop and resolve upstream.

1. Read WORKLOG.md (frontmatter + body), `git log origin/stage..<branch> --format='%H %s%n%b'`.
2. Generate `SC.md` per the 9-section template in `commit_protocol_spec.md`. Russian-language preserved. Fields:
   - §1 Идентификация ← frontmatter
   - §2 Основание ← SOURCE, REQ, AC, WORKLOG Analysis/Decisions, ask user for Out of Scope if not in WORKLOG
   - §3 Решение ← WORKLOG Decisions + Alternatives + Risks
   - §4 Архитектурное основание ← n/a unless ADR/CR/DCR set
   - §5 Реализация ← Code Zones + commit list + PUBLIC
   - §6 Проверяемость ← WORKLOG Testing
   - §7 Публикация ← `origin`, `stage`, head SHA filled after SHIP (leave `TBD` here)
   - §8 Риски ← WORKLOG Risks
   - §9 Подтверждение: `Статус: подготовлено`
3. Generate `VERIFY.md`:
   - One row per AC.
   - Columns: `#`, `Требование/Критерий`, `Что реализовано`, `Где`, `Коммиты`, `SC ref`, `Ручная проверка`, `Авто проверка`, `Ожидаемое свидетельство`, `Факт. свидетельство`, `Статус`, `Ответственный`.
   - Refuse to write if any AC has no commit SHA — that means coverage failed and SELF-REVIEW should have caught it.
4. Both files saved to `~/docspacevault/Tasks/<KLNA>/`.
5. Advance STATUS → `shipping`.

## Stage 6 — SHIP gate

**Goal:** push branch, open PR. Both are world actions — always ask.

1. Pre-push pull: `git fetch origin stage`. If `stage` advanced, **ask user** whether to rebase or merge (memory rule: never rebase origin PR branches — default to merge, but confirm). Rerun verify loop after merge.
2. **Show user the exact commands** that will run:
   ```
   git push -u origin <branch>
   gh pr create --base stage --assignee @me --title "<header>" --body "<from .github/PULL_REQUEST_TEMPLATE.md filled from WORKLOG+SC>"
   ```
3. PR title: same as the leading commit's header (`<Module>: <desc>`), ≤ 70 chars.
4. PR body: load `.github/PULL_REQUEST_TEMPLATE.md`, fill from WORKLOG + SC. Format per memory:
   - Full RC reference (`<rc_doc>-<rc_id>` style)
   - Plain FR/AC list, no bold + em-dash decoration
   - No AI signatures
5. **Wait for user approval before each command.**
6. After PR opens: update WORKLOG `PR_URL`, advance STATUS → `done` (PR review/merge is out of `/klna` scope; never auto-merge).
7. **Board status is Vlad's, not a file.** There is NO kanban markdown in the vault — the live board is the Projects-app via `mcp__projects__*`. After the PR opens, leave the task status to Vlad: he merges the PR and deploys the branch to staging himself (`deploy-calendar --branch <branch>` → `dsd-calendar:/var/www/r7-office/calendar-app`, runs lint+typecheck+build, E2E not wired yet), which moves the board task to `Ready to test`. Don't flip board status from `/klna`.

## Stage 7 — REPORT

Formatting this summary is mechanical — delegate to `klna-scribe` (cheap model),
passing the WORKLOG frontmatter (branch, PR_URL, AC count, commit count, risks,
TOKEN_LOG). One short summary to the user — no fluff:

```
KLNA-NNN  <TITLE>
Branch:   <branch>
PR:       <url>
AC:       <covered>/<total> (100% required)
Commits:  <count>
Risks:    <count from WORKLOG, or "none flagged">
Tokens:   <total in/out from TOKEN_LOG, by stage>
```

## Stage 8 — Board sync (Projects MCP, post-deploy, on request)

**Trigger:** Vlad asks to "update the board" after the task is deployed to staging (`Ready to test`). MCP writes are world actions, but this is the explicit ask — proceed; still no destructive guessing.

**Mechanics (confirmed working 2026-06-23 on KLNA-2 = numeric id 35, project 6, sprint 8):**
1. Find the task: `mcp__projects__search_tasks --like "<feature>"` → `get_task` for the numeric id (**the `KLNA-N` key ≠ the numeric `taskId`** the comment/update tools need). `list_comments` first to avoid duplicates.
2. **One comment per commit:** post each commit's full regulated body (`git show -s --format=%B <sha>`) as a separate `add_comment`, oldest→newest, prefixed `[NN/M] commit <shortsha>`. Parallel batches of ~6 keep comment ids ascending (board sorts by id); the prefix guarantees order regardless. Include F1 + the stage-sync merge — "all commits".
3. **SC as an attached file** (Vlad wants the docx, not a text dump): generate the house-style SC docx (below); **Vlad attaches it in the UI**.

**Projects MCP hard limits — `add_comment` is create-only. There is NO delete-comment, NO edit-comment, NO file/attachment upload.** So removing a stray comment and attaching the SC file are **UI-only manual steps** — tell Vlad, don't fire MCP calls that will fail. Full write surface = add_comment, update_task (title/desc/status/priority/dueDate), assign_task, set_task_status, create_{task,subtask,sprint,project}.

**Comments render as HTML** (same as task descriptions — see [[feedback_board_task_format]]): angle-bracket generics like `Widget<T>` get stripped in display. Cosmetic for commit bodies; escape `<`/`>` only if it matters.

**SC docx generator** (house-style audit artifact, 5 sections: Таблица решений / Пояснения для тестирования / Known Issues / Список коммитов / Контрольная запись поставки — NOT the 9-section SC.md): adapt `~/docspacevault/Tasks/_refactor-bundle/build_sc_bundle.py` (copy its styling helpers verbatim), set `REF` = the task's own `SRS-*.docx` (style inheritance), `OUT` = `<task>/SC-<rc_id>.docx`; populate §1 per-AC (FR/NFR + SOL-id + решение, mark deferred/narrowed ACs) and §4 from the commit list. Run with `/home/user76/Downloads/OLD/.venv/bin/python3` — it has `python-docx`; the Calendar-App `.venv` does NOT.

## Token usage logging

After each stage, append a line to WORKLOG frontmatter `TOKEN_LOG`:

```yaml
TOKEN_LOG:
  - stage: plan
    model: opus-4-7
    in: 12345
    out: 678
    ts: 2026-05-14T10:23:00Z
```

Source: read from the most recent assistant turn's usage data if available; otherwise estimate from token count of inputs+outputs. Purpose: collect data for future cost-tuning (sub-agent model choice, batching, etc.). Best-effort — do not block on this.

## Interrupt recovery

If `/klna` is invoked on a folder whose STATUS doesn't match completed artifacts (e.g. STATUS=`implementing` but no commits on branch yet, or `documenting` but no SC.md):

1. Append a `Session Handoff` block to WORKLOG noting interruption and resume point.
2. Re-establish git context: `git status`, `git log origin/stage..<branch> --oneline`.
3. Resume at the earliest incomplete stage.
4. Never re-emit a commit that already exists (match by header).

## Multi-KLNA / follow-up fixes

**v1: not supported.** One KLNA per branch per PR. If a fix surfaces during IMPLEMENT that belongs to a different KLNA: pause, note in WORKLOG Risks, finish the current KLNA, then start a fresh `/klna` on the other one. Old "follow-up fixes pattern" is archived with the shadow pipeline.

## File paths reference

| Purpose             | Path                                                              |
| ------------------- | ----------------------------------------------------------------- |
| Spec source of truth| `~/docspacevault/Dev Flow/commit_protocol_spec.md`                |
| Vault tasks         | `~/docspacevault/Tasks/<KLNA>/`                                   |
| Project repo        | `/home/user76/code/Calendar-App`                                  |
| Kanban board        | `/home/user76/docspacevault/.../Tasks board` (per memory)         |
| Master plan         | `~/docspacevault/Master Skill Redesign Plan 2026-05-14.md`        |
| This skill          | `~/.claude/skills/klna/SKILL.md`                                  |

## What this skill does NOT do

- Merge PRs (manual).
- Push to `main` (never — base is always `stage`).
- Touch `.gitignore` (user decision per memory).
- Create AI artifacts in the repo.
- Run MCP writes (deferred — manual RC paste).
- Schedule itself, batch tasks, or run multiple KLNAs in parallel.
