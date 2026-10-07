// Pure accounting: prices, a session's ledger rows, the cross-session report, and
// the text the strip, the turn line and the pane draw. Nothing here touches `$`.

import type { Card, Range, Report, ReportLine, Strip, StripCategory } from '../types'

/** The four token counts of one API call or a turn's sum, as the API spells them. */
export type Usage = {
  input_tokens: number
  output_tokens: number
  cache_read_input_tokens: number
  cache_creation_input_tokens: number
}

/** Tokens and estimated $ for one day × task × model × agent of a session. */
export type Row = {
  day: string
  task: string
  model: string
  /** `main`, a subagent type, or `consult` (Fable through the consult MCP, off-plan). */
  agent: string
  /** Turns for main, runs for a subagent, calls for a consult. */
  runs: number
  input: number
  output: number
  cacheRead: number
  cacheWrite: number
  usd: number
}

/** One session's file under ~/.claude/token-ledger/. Only that session writes it. */
export type SessionLedger = {
  v: 1
  sessionId: string
  project: string
  /** The label the next turn is booked under (from the last real prompt). */
  task?: string
  updatedAt: number
  rows: Row[]
}

// $ per million tokens: input, output, cache read. Cache writes bill at 2x input,
// since Claude Code writes its prompt cache with the 1-hour TTL. Rates from the
// claude-api skill's model table (cached 2026-09-25). First prefix match wins, so
// the longer ids come first and a dated id still prices.
const PRICES: readonly [prefix: string, input: number, output: number, cacheRead: number][] = [
  ['claude-fable-5-1', 10, 50, 0.25],
  ['claude-fable-5', 10, 50, 1],
  ['claude-opus-5-5', 4, 20, 0.2],
  ['claude-opus-5', 5, 25, 0.5],
  ['claude-opus-4', 5, 25, 0.5],
  ['claude-sonnet-5-5', 2, 10, 0.2],
  ['claude-sonnet-5', 2, 10, 0.2],
  ['claude-sonnet-4', 3, 15, 0.3],
  ['claude-haiku-4-5', 1, 5, 0.1],
]

/** API-equivalent $ of `usage` on `model`; 0 for a model with no known rate. */
export function costOf(model: string, usage: Usage): number {
  const price = PRICES.find(([prefix]) => model.startsWith(prefix))
  if (price === undefined) return 0
  const [, input, output, cacheRead] = price
  return (
    (usage.input_tokens * input +
      usage.cache_creation_input_tokens * input * 2 +
      usage.cache_read_input_tokens * cacheRead +
      usage.output_tokens * output) /
    1e6
  )
}

export function totalTokens(usage: Usage): number {
  return (
    usage.input_tokens +
    usage.output_tokens +
    usage.cache_read_input_tokens +
    usage.cache_creation_input_tokens
  )
}

/** `+0300` → 180. */
export function parseOffset(z: string): number | undefined {
  const m = /^([+-])(\d{2})(\d{2})$/.exec(z.trim())
  if (m === null) return undefined
  const minutes = Number(m[2]) * 60 + Number(m[3])
  return m[1] === '-' ? -minutes : minutes
}

/** The local calendar day of `ms`, `offsetMin` east of UTC. */
export function dayOf(ms: number, offsetMin: number): string {
  return new Date(ms + offsetMin * 60_000).toISOString().slice(0, 10)
}

// A short reply that steers the running task rather than starting a new one.
const STEER =
  /^(y|yes|yep|yeah|no|nope|ok|okay|k|sure|go|go on|go ahead|do it|continue|proceed|next|lets? (go|do|continue)|thanks|thank you|ty|lgtm|nice|great|cool|done)\b/i

/** The task a prompt is booked under: its first line, or `previous` for a steer. */
export function taskLabel(text: string, previous: string | undefined): string {
  const line = (text.split('\n').find(l => l.trim() !== '') ?? '').trim().replace(/\s+/g, ' ')
  const isSteer = line.length < 12 || (line.length < 40 && STEER.test(line))
  if (previous !== undefined && isSteer) return previous
  if (line === '') return '(no prompt)'
  return line.length > 48 ? `${line.slice(0, 47)}…` : line
}

export function newLedger(sessionId: string, project: string): SessionLedger {
  return { v: 1, sessionId, project, updatedAt: 0, rows: [] }
}

/** Books one turn, run or call into `ledger`; `usd` overrides the price table. */
export function record(
  ledger: SessionLedger,
  entry: { day: string; task: string; model: string; agent: string; usage: Usage; usd?: number },
): void {
  const { day, task, model, agent, usage } = entry
  let row = ledger.rows.find(
    r => r.day === day && r.task === task && r.model === model && r.agent === agent,
  )
  if (row === undefined) {
    row = { day, task, model, agent, runs: 0, input: 0, output: 0, cacheRead: 0, cacheWrite: 0, usd: 0 }
    ledger.rows.push(row)
  }
  row.runs += 1
  row.input += usage.input_tokens
  row.output += usage.output_tokens
  row.cacheRead += usage.cache_read_input_tokens
  row.cacheWrite += usage.cache_creation_input_tokens
  row.usd += entry.usd ?? costOf(model, usage)
}

const RANGE_DAYS: Record<Range, number> = { today: 1, '7d': 7, '30d': 30 }

export function parseRange(args: string): Range {
  const word = args.trim().toLowerCase()
  if (word === '7d' || word === 'week') return '7d'
  if (word === '30d' || word === 'month') return '30d'
  return 'today'
}

/** The first day `range` covers, counting today. */
export function sinceDay(range: Range, now: number, offsetMin: number): string {
  return dayOf(now - (RANGE_DAYS[range] - 1) * 86_400_000, offsetMin)
}

function rowTokens(r: Row): number {
  return r.input + r.output + r.cacheRead + r.cacheWrite
}

function breakdown(rows: { key: string; row: Row }[]): ReportLine[] {
  const lines = new Map<string, ReportLine>()
  for (const { key, row } of rows) {
    const line = lines.get(key) ?? { name: key, tokens: 0, usd: 0 }
    line.tokens += rowTokens(row)
    line.usd += row.usd
    lines.set(key, line)
  }
  return [...lines.values()].sort((a, b) => b.usd - a.usd || b.tokens - a.tokens)
}

/** Folds every session's rows from `since` on into the /tokens report. */
export function aggregate(ledgers: SessionLedger[], range: Range, since: string): Report {
  const plan: { project: string; row: Row }[] = []
  const consults: Row[] = []
  let sessions = 0
  for (const ledger of ledgers) {
    const rows = ledger.rows.filter(r => r.day >= since)
    if (rows.length > 0) sessions += 1
    for (const row of rows) {
      if (row.agent === 'consult') consults.push(row)
      else plan.push({ project: ledger.project, row })
    }
  }
  const sum = (pick: (r: Row) => number) => plan.reduce((n, { row }) => n + pick(row), 0)
  return {
    range,
    since,
    sessions,
    tokens: sum(rowTokens),
    input: sum(r => r.input + r.cacheRead + r.cacheWrite),
    cacheRead: sum(r => r.cacheRead),
    output: sum(r => r.output),
    usd: sum(r => r.usd),
    byProject: breakdown(plan.map(({ project, row }) => ({ key: project, row }))),
    byTask: breakdown(plan.map(({ row }) => ({ key: row.task, row }))),
    byModel: breakdown(plan.map(({ row }) => ({ key: shortModel(row.model), row }))),
    byAgent: breakdown(plan.map(({ row }) => ({ key: row.agent, row }))),
    consult: {
      calls: consults.reduce((n, r) => n + r.runs, 0),
      tokens: consults.reduce((n, r) => n + rowTokens(r), 0),
      usd: consults.reduce((n, r) => n + r.usd, 0),
      byTask: breakdown(consults.map(row => ({ key: row.task, row }))),
    },
  }
}

// ── Text ────────────────────────────────────────────────────────────────────

export function fmtTok(n: number): string {
  const trim = (fixed: string) => fixed.replace(/\.0+$/, '').replace(/(\.\d*?)0+$/, '$1')
  if (n < 1000) return String(Math.round(n))
  if (n < 1e6) return `${trim((n / 1e3).toFixed(n < 1e4 ? 1 : 0))}k`
  return `${trim((n / 1e6).toFixed(n < 1e7 ? 2 : 1))}M`
}

export function fmtUsd(usd: number): string {
  if (usd > 0 && usd < 0.005) return '<$0.01'
  return `$${usd < 100 ? usd.toFixed(2) : usd.toFixed(0)}`
}

/** `claude-opus-5-5` → `opus-5.5`, `claude-haiku-4-5-20251001` → `haiku-4.5`. */
export function shortModel(id: string): string {
  return id
    .replace(/^claude-/, '')
    .replace(/-\d{8}$/, '')
    .replace(/\[.*\]$/, '')
    .replace(/-(\d+)-(\d+)$/, '-$1.$2')
}

/** Time left until `iso`, from `now`: `45m`, `2h14m`, `3d4h`. */
export function fmtUntil(iso: string, now: number): string | undefined {
  const ms = Date.parse(iso) - now
  if (!Number.isFinite(ms)) return undefined
  const minutes = Math.max(0, Math.round(ms / 60_000))
  if (minutes < 60) return `${minutes}m`
  const hours = Math.floor(minutes / 60)
  if (hours < 24) return `${hours}h${String(minutes % 60).padStart(2, '0')}m`
  return `${Math.floor(hours / 24)}d${hours % 24}h`
}

/** A subagent run that finished inside the turn that spawned it. */
export type AgentRun = { type: string; model: string; tokens: number }

/** The line under an answer: `↳ 84.2k in (91% cached) · 2.1k out · Explore×2 haiku-4.5 18k · $0.42`. */
export function turnLine(
  usage: Usage | undefined,
  agents: readonly AgentRun[],
  usd: number | undefined,
): string | undefined {
  const parts: string[] = []
  if (usage !== undefined) {
    const input = usage.input_tokens + usage.cache_read_input_tokens + usage.cache_creation_input_tokens
    const cached = input > 0 ? Math.round((usage.cache_read_input_tokens / input) * 100) : 0
    parts.push(`${fmtTok(input)} in (${cached}% cached)`, `${fmtTok(usage.output_tokens)} out`)
  }
  const groups = new Map<string, { label: string; n: number; tokens: number }>()
  for (const run of agents) {
    const key = `${run.type}\u0000${run.model}`
    const group = groups.get(key) ?? { label: run.type, n: 0, tokens: 0 }
    group.n += 1
    group.tokens += run.tokens
    groups.set(key, group)
  }
  for (const [key, { label, n, tokens }] of groups) {
    const model = shortModel(key.split('\u0000')[1] ?? '')
    parts.push(`${label}${n > 1 ? `×${n}` : ''} ${model} ${fmtTok(tokens)}`)
  }
  if (parts.length === 0) return undefined
  if (usd !== undefined && usd > 0) parts.push(fmtUsd(usd))
  return `↳ ${parts.join(' · ')}`
}

/** One run of text in the band, its colors theme keys. */
export type Part = { text: string; color?: string; bg?: string; dim?: boolean; bold?: boolean }

// Short names and a palette with one hue per category, by the row's /context label.
// Unknown rows keep the engine's name and theme colour.
const CATEGORY_STYLE: Record<string, { name: string; color: string }> = {
  'system prompt': { name: 'system', color: '#7aa2f7' },
  'system tools': { name: 'tools', color: '#7dcfff' },
  'mcp tools': { name: 'mcp', color: '#bb9af7' },
  'mcp server instructions': { name: 'mcp', color: '#bb9af7' },
  'custom agents': { name: 'agents', color: '#9ece6a' },
  'memory files': { name: 'memory', color: '#e0af68' },
  skills: { name: 'skills', color: '#f7a1c4' },
  'slash commands': { name: 'commands', color: '#73daca' },
  messages: { name: 'messages', color: '#ff9e64' },
}

/** Green, amber, red by how full a window is. */
export function levelColor(pct: number): string {
  if (pct >= 90) return 'error'
  if (pct >= 70) return 'warning'
  return 'success'
}

function styleOf(c: StripCategory): { name: string; color: string } {
  const lower = c.name.toLowerCase()
  return CATEGORY_STYLE[lower] ?? { name: lower, color: c.color }
}

function width(parts: readonly Part[]): number {
  return parts.reduce((n, p) => n + p.text.length, 0)
}

/** Joins runs of one style, so a bar is a handful of Texts rather than a cell each. */
function merge(cells: readonly Part[]): Part[] {
  const parts: Part[] = []
  for (const cell of cells) {
    const last = parts[parts.length - 1]
    if (last !== undefined && last.color === cell.color && last.dim === cell.dim && last.bg === cell.bg) {
      last.text += cell.text
    } else {
      parts.push({ ...cell })
    }
  }
  return parts
}

/** How big a session should get: lean under `good`, too heavy past `limit`. */
export type Budget = { good: number; limit: number }

/** The budget's limit, or the window where the window is smaller. */
function ceiling(strip: Strip, budget: Budget): number {
  return Math.min(budget.limit, strip.ctxWindow)
}

/** Green while lean, amber on the way to the limit, red past it. */
export function budgetColor(tokens: number, strip: Strip, budget: Budget): string {
  if (tokens >= ceiling(strip, budget)) return 'error'
  if (tokens >= budget.good) return 'warning'
  return 'success'
}

/** The fill as a share of the limit, not of the window. */
export function badgePart(strip: Strip, budget: Budget): Part {
  const tokens = strip.ctxTokens ?? 0
  const pct = Math.round((tokens / ceiling(strip, budget)) * 100)
  return { text: ` ${pct}% `, color: 'inverseText', bg: budgetColor(tokens, strip, budget), bold: true }
}

/**
 * The budget as `cells` blocks: each used category in its own colour (one block at
 * least, so a small one still shows), hatched red past the limit, the rest a grey track,
 * marked at the lean size, the limit and, inside the bar, the compaction point.
 */
export function contextBar(strip: Strip, cells: number, budget: Budget): Part[] {
  if (cells <= 0 || strip.ctxWindow <= 0) return []
  const tokens = strip.ctxTokens ?? 0
  const limit = ceiling(strip, budget)
  const scale = Math.max(limit, tokens)
  const cellOf = (t: number) => Math.min(cells - 1, Math.round((t / scale) * cells))
  const used = strip.categories.filter(c => c.kind === 'used' && c.tokens > 0)
  const counts = used.map(c => Math.max(1, Math.round((c.tokens / scale) * cells)))
  for (let over = counts.reduce((a, b) => a + b, 0) - cells; over > 0; over -= 1) {
    const widest = counts.indexOf(Math.max(...counts))
    counts[widest] = (counts[widest] ?? 1) - 1
  }
  const row: Part[] = []
  used.forEach((c, i) => {
    const { color } = styleOf(c)
    for (let k = 0; k < (counts[i] ?? 0); k += 1) row.push({ text: '█', color })
  })
  const usedCells = row.length
  if (tokens > limit) {
    for (let k = cellOf(limit); k < usedCells; k += 1) row[k] = { text: '▓', color: 'error' }
  }
  while (row.length < cells) row.push({ text: '░', color: 'inactive' })
  const marks: [number, Part][] = [
    [budget.good, { text: '┊', color: 'warning' }],
    [limit, { text: '┃', color: 'error' }],
  ]
  if (strip.compactAt !== undefined && strip.compactAt < scale) marks.push([strip.compactAt, { text: '▏', color: 'claude' }])
  for (const [at, mark] of marks) {
    const cell = cellOf(at)
    if (cell >= usedCells) row[cell] = mark
  }
  return merge(row)
}

/** `◆ 288k / 300k  █████████░░┊░░░┃  96%`: the fill, the bar in what is left, the badge. */
export function contextRow(strip: Strip, columns: number, budget: Budget): Part[] {
  const head: Part[] = [
    { text: '◆ ', color: 'claude' },
    { text: fmtTok(strip.ctxTokens ?? 0), bold: true },
    { text: ` / ${fmtTok(ceiling(strip, budget))}  `, color: 'inactive' },
  ]
  const badge = badgePart(strip, budget)
  const cells = columns - width(head) - badge.text.length - 1
  return [...head, ...contextBar(strip, cells, budget), { text: ' ' }, badge]
}

/**
 * One line of legend in bar order, then what is left of the budget (or how far
 * over it): `■ messages 242k  ■ tools 27k  ■ left 12k`. Where it overflows
 * `columns`, the smallest rows leave first.
 */
export function legendLine(strip: Strip, columns: number, budget: Budget): Part[] {
  const left = ceiling(strip, budget) - (strip.ctxTokens ?? 0)
  const items = [
    ...strip.categories
      .filter(c => c.kind === 'used' && c.tokens > 0)
      .map(c => ({ ...styleOf(c), size: c.tokens, isRest: false })),
    left >= 0
      ? { name: 'left', color: 'inactive', size: left, isRest: true }
      : { name: 'over', color: 'error', size: -left, isRest: true },
  ].map(i => ({ ...i, tokens: fmtTok(i.size) }))
  const fits = (shown: typeof items) =>
    shown.reduce((n, i) => n + i.name.length + i.tokens.length + 5, 0) - 2 <= columns
  const shown = [...items]
  while (shown.length > 1 && !fits(shown)) {
    const smallest = shown.filter(i => !i.isRest).reduce((a, b) => (b.size < a.size ? b : a))
    shown.splice(shown.indexOf(smallest), 1)
  }
  const parts: Part[] = []
  for (const item of shown) {
    if (parts.length > 0) parts.push({ text: '  ' })
    parts.push(
      { text: '■ ', color: item.color },
      { text: `${item.name} `, color: item.name === 'over' ? 'error' : 'inactive' },
      { text: item.tokens, bold: true },
    )
  }
  return parts
}

const EFFORT_COLORS: Record<string, string> = {
  low: 'inactive',
  medium: '#7aa2f7',
  high: '#9ece6a',
  xhigh: '#e0af68',
  max: '#f7768e',
}

/** `claude-opus-5-5[1m]` → `Opus 5.5`; an alias or a display name keeps its words, capitalised. */
export function modelName(id: string): string {
  const m = /^claude-([a-z]+)-(\d+)(?:-(\d{1,2}))?(?!\d)/.exec(id)
  const words = m === null ? id : `${m[1]} ${m[2]}${m[3] === undefined ? '' : `.${m[3]}`}`
  return words.charAt(0).toUpperCase() + words.slice(1)
}

/** Parses `git status --porcelain=v2 --branch`: the branch (or a short sha) and whether it is dirty. */
export function parseGitStatus(out: string): { branch?: string; isDirty: boolean } {
  let head: string | undefined
  let oid: string | undefined
  let isDirty = false
  for (const line of out.split('\n')) {
    if (line.startsWith('# branch.head ')) head = line.slice('# branch.head '.length).trim()
    else if (line.startsWith('# branch.oid ')) oid = line.slice('# branch.oid '.length).trim()
    else if (line.trim() !== '' && !line.startsWith('#')) isDirty = true
  }
  const branch = head === '(detached)' ? oid?.slice(0, 7) : head
  return { ...(branch === undefined ? {} : { branch }), isDirty }
}

// Nerd Font glyphs (Material Design range): robot, folder, source branch.
const ICON = { model: '\u{F06A9} ', repo: '\u{F024B} ', branch: '\u{F062C} ' }

/** The card's three rows: model with its effort badge, repo, branch. */
export function cardRows(card: Card): Part[][] {
  const model: Part[] = [
    { text: ICON.model, color: '#bb9af7' },
    { text: modelName(card.model), color: '#bb9af7', bold: true },
  ]
  if (card.effort !== undefined) {
    model.push(
      { text: ' ' },
      { text: ` ${card.effort} `, color: 'inverseText', bg: EFFORT_COLORS[card.effort] ?? 'inactive', bold: true },
    )
  }
  const rows = [model]
  if (card.repo !== undefined) rows.push([{ text: ICON.repo, color: '#7dcfff' }, { text: card.repo, color: '#7dcfff', bold: true }])
  if (card.branch !== undefined) {
    const row: Part[] = [{ text: ICON.branch, color: '#9ece6a' }, { text: card.branch, color: '#9ece6a', bold: true }]
    if (card.isDirty) row.push({ text: '*', color: 'error', bold: true })
    rows.push(row)
  }
  return rows
}

/** The width of a row of parts, in cells. */
export function rowWidth(parts: readonly Part[]): number {
  return width(parts)
}

/**
 * `━━━━━━━━━━ 5% 4h18m   ━━━━━━━━━━ 39% 1d10h   $5.51`: the 5-hour window, then the
 * weekly one (unlabelled, so the order is the label), each with the time to its
 * reset, then the session's $. The meters shrink to fit `columns`.
 */
export function limitParts(strip: Strip, columns = Infinity): Part[] {
  const order = (kind: string) => ['five_hour', 'seven_day'].indexOf(kind) >>> 0
  const limits = [...strip.limits].sort((x, y) => order(x.kind) - order(y.kind))
  const build = (meterCells: number): Part[] => {
    const parts: Part[] = []
    for (const limit of limits) {
      if (parts.length > 0) parts.push({ text: '   ' })
      const filled = Math.min(meterCells, Math.max(0, Math.round((limit.pct / 100) * meterCells)))
      parts.push(
        { text: '━'.repeat(filled), color: levelColor(limit.pct) },
        { text: '━'.repeat(meterCells - filled), color: 'inactive', dim: true },
        { text: ` ${Math.round(limit.pct)}%`, bold: true },
      )
      const left = limit.resetsAt === undefined ? undefined : fmtUntil(limit.resetsAt, strip.at)
      if (left !== undefined) parts.push({ text: ` ${left}`, color: 'inactive' })
    }
    if (strip.usd !== undefined) {
      if (parts.length > 0) parts.push({ text: '   ' })
      parts.push({ text: fmtUsd(strip.usd), bold: true })
    }
    return parts
  }
  for (const meter of [10, 6]) {
    const parts = build(meter)
    if (width(parts) <= columns) return parts
  }
  return build(3)
}

/** A breakdown row padded to `columns`: name, tokens, share of `total` $, $. */
export function reportRow(line: ReportLine, totalUsd: number, columns: number): string {
  const share = totalUsd > 0 ? `${Math.round((line.usd / totalUsd) * 100)}%` : ''
  const tail = `${fmtTok(line.tokens).padStart(7)}${share.padStart(6)}${fmtUsd(line.usd).padStart(9)}`
  const room = Math.max(10, columns - tail.length - 2)
  const name = line.name.length > room ? `${line.name.slice(0, room - 1)}…` : line.name
  return `  ${name.padEnd(room)}${tail}`
}
