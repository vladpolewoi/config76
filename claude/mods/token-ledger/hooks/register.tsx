import { atom, read, update } from 'claude-code'
import type { EngineInterface, Register, SessionContextBreakdown, SessionUsage } from 'claude-code'

import type { Card, Range, ReportLine, Strip } from '../types'
import {
  aggregate,
  cardRows,
  dayOf,
  fmtTok,
  fmtUsd,
  newLedger,
  parseGitStatus,
  parseOffset,
  parseRange,
  record,
  reportRow,
  rowWidth,
  sinceDay,
  contextRow,
  legendLine,
  limitParts,
  taskLabel,
  totalTokens,
  turnLine,
} from './ledger'
import type { AgentRun, Budget, Part, SessionLedger } from './ledger'

type Engine = EngineInterface

const PANE = 'token-ledger'
const CONSULT = 'mcp__consult__consult'
const RANGES: readonly Range[] = ['today', '7d', '30d']
const NO_TASK = '(no prompt)'

const strip = atom({ plugin: 'token-ledger', key: 'strip' } as const, null)
const report = atom({ plugin: 'token-ledger', key: 'report' } as const, null)
const card = atom({ plugin: 'token-ledger', key: 'card' } as const, null)

/** A Part's style as Text props, leaving out what it does not set. */
function paint(p: Part) {
  return {
    ...(p.color === undefined ? {} : { color: p.color }),
    ...(p.bg === undefined ? {} : { backgroundColor: p.bg }),
    ...(p.dim === true ? { dimColor: true } : {}),
    ...(p.bold === true ? { bold: true } : {}),
  }
}

type SpendEntry = { ts: string; model: string; input_tokens: number; output_tokens: number; usd: number }

// Module state: a hot reload starts it over, and the ledger reloads from its file.
let home = ''
let offsetMin = 0
let isInteractive = false
let ledger: SessionLedger | undefined
let turn: { id: string; usdAt?: number; agents: AgentRun[] } | undefined
let saving: Promise<void> = Promise.resolve()
let hasWarned = false
let budget: Budget = { good: 150_000, limit: 300_000 }
const spawns = new Map<string, { type: string; task: string; turnId?: string }>()
const bookedConsults = new Set<string>()

async function folder($: Engine): Promise<string> {
  if (home === '') home = (await $.env.get('HOME')) ?? ''
  return `${home}/.claude/token-ledger`
}

async function localOffset($: Engine): Promise<number> {
  try {
    const { exitCode, stdout } = await $.process.run(['date', '+%z'])
    const offset = exitCode === 0 ? parseOffset(stdout) : undefined
    if (offset !== undefined) return offset
  } catch {
    // fall through to the environment's own idea of the zone
  }
  return -new Date().getTimezoneOffset()
}

/** This session's ledger; a new id (start, /clear, reload) picks up its file. */
async function bookFor($: Engine): Promise<SessionLedger> {
  const id = await $.session.id()
  if (ledger?.sessionId === id) return ledger
  let saved: SessionLedger | undefined
  try {
    const parsed = JSON.parse(await $.fs.read(`${await folder($)}/${id}.json`)) as SessionLedger
    if (parsed.v === 1) saved = parsed
  } catch {
    // nothing booked for this session yet
  }
  const root = await $.session.root()
  ledger = saved ?? newLedger(id, root.split('/').filter(Boolean).pop() ?? root)
  return ledger
}

/** Writes the ledger; chained, so an older snapshot never lands after a newer one. */
function save($: Engine): Promise<void> {
  const book = ledger
  if (book === undefined) return saving
  saving = saving
    .then(async () => {
      book.updatedAt = await $.clock.now()
      await $.fs.write(`${await folder($)}/${book.sessionId}.json`, JSON.stringify(book))
    })
    .catch((error: unknown) => {
      if (hasWarned) return
      hasWarned = true
      $.ui.toast(`token-ledger: could not save the ledger (${String(error)})`)
    })
  return saving
}

type Figures = Pick<SessionUsage, 'rateLimits' | 'cost'> & {
  context: SessionUsage['context'] & { breakdown?: SessionContextBreakdown }
}

/** Redraws the band; a reading without a breakdown keeps the last one's categories. */
async function showUsage($: Engine, usage: Figures) {
  const at = await $.clock.now()
  const limits = usage.rateLimits.map(l => ({ kind: l.kind, pct: l.percentUsed, resetsAt: l.resetsAt }))
  const b = usage.context.breakdown
  await update($, strip, last => {
    const context =
      b === undefined
        ? {
            ctxPct: usage.context.percent ?? last?.ctxPct,
            ctxTokens: usage.context.tokens ?? last?.ctxTokens,
            ctxWindow: last?.ctxWindow ?? usage.context.window,
            compactAt: last?.compactAt,
            categories: last?.categories ?? [],
          }
        : {
            ctxPct: b.percentage,
            ctxTokens: b.totalTokens,
            ctxWindow: b.rawMaxTokens,
            compactAt: b.isAutoCompactEnabled ? b.autoCompactThreshold : undefined,
            categories: b.categories.map(c => ({ name: c.name, tokens: c.tokens, color: c.color, kind: c.kind })),
          }
    const next: Strip = { at, ...context, limits, usd: usage.cost?.usd }
    return next
  })
}

async function startingEffort($: Engine): Promise<string | undefined> {
  const fromEnv = await $.env.get('CLAUDE_EFFORT')
  if (fromEnv !== undefined && fromEnv !== '') return fromEnv
  const settings = (await $.settings.read()) as { effortLevel?: unknown }
  return typeof settings.effortLevel === 'string' ? settings.effortLevel : undefined
}

/** Updates the card: `patch` from the turn, branch and dirtiness from git. Never throws: the card is decoration. */
async function showCard($: Engine, patch: Partial<Card> = {}) {
  try {
    const root = await $.session.root()
    let where: Partial<Card> = { repo: root.split('/').pop() ?? root, isDirty: false }
    const top = await $.process.run(['git', '-C', root, 'rev-parse', '--show-toplevel'])
    if (top.exitCode === 0) {
      const status = await $.process.run(['git', '-C', root, 'status', '--porcelain=v2', '--branch', '--untracked-files=no'])
      where = { repo: top.stdout.trim().split('/').pop() ?? root, ...parseGitStatus(status.stdout) }
    }
    const fallback = await $.session.model()
    const last = await read($, card)
    // Effort before any turn has reported one: what the engine hands its tools, else settings.
    const effort = last?.effort ?? patch.effort ?? (await startingEffort($))
    await update($, card, held => {
      const next: Card = {
        model: held?.model ?? fallback,
        isDirty: false,
        ...held,
        ...(effort === undefined ? {} : { effort }),
        ...where,
        ...patch,
      }
      return next
    })
  } catch {
    // no git, or the session's figures were not to be had: the card keeps what it showed
  }
}

/** A full reading: the window broken down as /context does, estimated locally (no API call). */
async function measure($: Engine) {
  await showUsage($, await $.session.usage({ breakdown: 'summary' }))
}

async function showReport($: Engine, range: Range) {
  await save($)
  const now = await $.clock.now()
  const since = sinceDay(range, now, offsetMin)
  // A file untouched since the day before `since` holds nothing in range.
  const cutoff = Date.parse(since) - 86_400_000
  const dir = await folder($)
  const entries = await $.fs.list(dir).catch(() => [])
  const books = await Promise.all(
    entries
      .filter(f => f.kind === 'file' && f.name.endsWith('.json') && f.mtimeMs >= cutoff)
      .map(f =>
        $.fs
          .read(`${dir}/${f.name}`)
          .then(text => JSON.parse(text) as SessionLedger)
          .catch(() => undefined),
      ),
  )
  const ledgers = books.filter((b): b is SessionLedger => b?.v === 1)
  await update($, report, () => aggregate(ledgers, range, since))
}

/** Books the consult call that just ran from the consult server's own spend log. */
async function bookConsult($: Engine, startedAt: number) {
  const log = await $.fs.read(`${home}/.consult-mcp/spend.jsonl`)
  const lines = log.trim().split('\n').reverse()
  for (const line of lines) {
    const entry = JSON.parse(line) as SpendEntry
    // Older than the call: nothing was billed (blocked by the guardrail, or failed).
    if (Date.parse(entry.ts) < startedAt - 5_000) return
    const key = `${entry.ts}|${entry.usd}`
    if (bookedConsults.has(key)) continue
    bookedConsults.add(key)
    const book = await bookFor($)
    record(book, {
      day: dayOf(Date.parse(entry.ts), offsetMin),
      task: book.task ?? NO_TASK,
      model: entry.model,
      agent: 'consult',
      usage: {
        input_tokens: entry.input_tokens,
        output_tokens: entry.output_tokens,
        cache_read_input_tokens: 0,
        cache_creation_input_tokens: 0,
      },
      usd: entry.usd,
    })
    await save($)
    return
  }
}

export const register: Register = (on, options) => {
  budget = { good: Number(options.goodTokens ?? budget.good), limit: Number(options.limitTokens ?? budget.limit) }

  on('session.start', async ($, e, next) => {
    isInteractive = e.isInteractive
    offsetMin = await localOffset($)
    await bookFor($)
    await $.command.register({
      name: 'tokens',
      description: 'Where the tokens went, by project, task, model and agent',
      argumentHint: '[today|7d|30d]',
      immediate: true,
    })
    await measure($)
    await showCard($)
    // Keeps the reset countdowns and the branch current between turns; both are cheap.
    $.clock.every(60_000, () => {
      void $.session.usage().then(usage => showUsage($, usage))
      void showCard($)
    })
    return next(e)
  })

  on('session.measure', async ($, e, next) => {
    await (e.changed.includes('context') ? measure($) : showUsage($, e))
    return next(e)
  })

  on('prompt.submit', async ($, e, next) => {
    if (e.origin.kind === 'composer' || e.origin.kind === 'bridge') {
      const book = await bookFor($)
      book.task = taskLabel(e.text, book.task)
    }
    return next(e)
  })

  on('turn.start', async ($, e, next) => {
    const { cost } = await $.session.usage()
    turn = { id: e.turnId, usdAt: cost?.usd, agents: [] }
    return next(e)
  })

  on('agent.spawn', async ($, e, next) => {
    const spawned = await next(e)
    if (spawned.agentId !== undefined) {
      const book = await bookFor($)
      spawns.set(spawned.agentId, { type: e.subagentType, task: book.task ?? NO_TASK, turnId: turn?.id })
    }
    return spawned
  }).catch(($, e, next) => next(e))

  // The settings hooks' Stop carries the turn's effort, after any downgrade for the model.
  on('classic.Stop', async ($, e, next) => {
    const level = e.effort?.level
    if (level !== undefined) await showCard($, { effort: level })
    return next(e)
  })

  on('turn.complete', async ($, e, next) => {
    const answered = await next(e)
    const book = await bookFor($)
    const day = dayOf(await $.clock.now(), offsetMin)
    const usage = e.usage

    if (e.agentId !== undefined) {
      const spawn = spawns.get(e.agentId)
      if (usage !== undefined) {
        record(book, {
          day,
          task: spawn?.task ?? book.task ?? NO_TASK,
          model: usage.model,
          agent: spawn?.type ?? 'subagent',
          usage,
        })
        if (spawn !== undefined && turn !== undefined && spawn.turnId === turn.id) {
          turn.agents.push({ type: spawn.type, model: usage.model, tokens: totalTokens(usage) })
        }
        await save($)
      }
      return answered
    }

    if (usage !== undefined) {
      record(book, { day, task: book.task ?? NO_TASK, model: usage.model, agent: 'main', usage })
      await save($)
    }
    const { cost } = await $.session.usage()
    const usd = cost !== undefined && turn?.usdAt !== undefined ? cost.usd - turn.usdAt : undefined
    const line = turnLine(usage, turn?.agents ?? [], usd)
    turn = undefined
    await showCard($, usage === undefined ? {} : { model: usage.model })
    // A headless run prints the answer; leave it alone there.
    return isInteractive && line !== undefined ? { ...answered, text: line } : answered
  })

  on('tool.call', { tool: CONSULT }, async ($, e, next) => {
    const startedAt = await $.clock.now()
    const ran = await next(e)
    try {
      await bookConsult($, startedAt)
    } catch {
      // the spend log is the consult server's; a missing or odd line books nothing
    }
    return ran
  }).catch(($, e, next) => next(e))

  on('command.run', { command: 'tokens' }, async ($, e) => {
    await showReport($, parseRange(e.args))
    await $.ui.open({ id: PANE, title: 'Tokens' })
    return {}
  })

  on('ui.render', { component: 'AbovePrompt' }, async ($, e, next) => {
    const figures = await read($, strip)
    if (e.props.hasSurvey || figures === null || figures.categories.length === 0) return next(e)
    const { Box, Text } = $.ui.resolve(e)
    const line = (parts: readonly Part[]) => (
      <Text wrap="truncate-end">
        {parts.map(p => (
          <Text {...paint(p)}>{p.text}</Text>
        ))}
      </Text>
    )
    const frame = { borderStyle: 'round', borderColor: 'inactive', paddingX: 1 } as const
    // Three rows, framed where the slot has two more to spare; the card beside them
    // where there is width for both.
    const isFramed = e.props.maxRows >= 5
    const where = await read($, card)
    const cardLines = where === null ? [] : cardRows(where)
    const cardWidth = Math.max(0, ...cardLines.map(rowWidth)) + 4
    const hasCard = isFramed && cardLines.length > 0 && e.props.bodyColumns >= cardWidth + 61
    const width = Math.min(e.props.bodyColumns - (hasCard ? cardWidth + 1 : 0), 110)
    const inner = isFramed ? width - 4 : width
    const limits = limitParts(figures, inner)

    return (
      <Box gap={1}>
        <Box key="context" flexDirection="column" width={width} {...(isFramed ? frame : {})}>
          {line(contextRow(figures, inner, budget))}
          {line(legendLine(figures, inner, budget))}
          {limits.length > 0 && line(limits)}
        </Box>
        {hasCard && (
          <Box key="card" flexDirection="column" width={cardWidth} {...frame}>
            {cardLines.map(line)}
          </Box>
        )}
      </Box>
    )
  })

  on('ui.render', { component: 'Pane', requestId: PANE }, async ($, e) => {
    const { Box, Button, Text } = $.ui.resolve(e)
    const r = await read($, report)
    if (r === null) return <Text dimColor>Counting…</Text>
    const columns = e.props.bodyColumns
    const cached = r.input > 0 ? Math.round((r.cacheRead / r.input) * 100) : 0
    const section = (title: string, lines: readonly ReportLine[], total: number, limit: number) => (
      <Box flexDirection="column" marginTop={1}>
        <Text bold>{title}</Text>
        {lines.length === 0 ? (
          <Text dimColor>  nothing yet</Text>
        ) : (
          lines.slice(0, limit).map(line => <Text wrap="truncate-end">{reportRow(line, total, columns)}</Text>)
        )}
      </Box>
    )

    return (
      <Box flexDirection="column">
        <Box gap={1}>
          {RANGES.map((range, i) => (
            <Button
              key={`range-${range}`}
              label={range}
              hotkey={String(i + 1)}
              variant={range === r.range ? 'primary' : 'secondary'}
              onPress={() => showReport($, range)}
            />
          ))}
        </Box>
        <Box flexDirection="column" marginTop={1}>
          <Text>
            <Text bold>{fmtUsd(r.usd)}</Text> API-equivalent · {fmtTok(r.tokens)} tokens · {r.sessions}{' '}
            {r.sessions === 1 ? 'session' : 'sessions'} since {r.since}
          </Text>
          <Text dimColor>
            {fmtTok(r.input)} in ({cached}% cached) · {fmtTok(r.output)} out · $ estimated from list prices
          </Text>
        </Box>
        {section('By project', r.byProject, r.usd, 6)}
        {section('By task', r.byTask, r.usd, 10)}
        {section('By model', r.byModel, r.usd, 6)}
        {section('By agent', r.byAgent, r.usd, 8)}
        {r.consult.calls > 0 &&
          section(
            `Fable consults · off-plan, billed · ${r.consult.calls} ${r.consult.calls === 1 ? 'call' : 'calls'} · ${fmtUsd(r.consult.usd)}`,
            r.consult.byTask,
            r.consult.usd,
            5,
          )}
      </Box>
    )
  })
}
