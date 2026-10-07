import { expect, test } from 'claude-code/testing'

import {
  aggregate,
  costOf,
  dayOf,
  fmtUntil,
  newLedger,
  parseOffset,
  badgePart,
  cardRows,
  modelName,
  parseGitStatus,
  contextRow,
  fmtTok,
  legendLine,
  limitParts,
  record,
  shortModel,
  taskLabel,
  turnLine,
} from '../hooks/ledger'

const NONE = { input_tokens: 0, output_tokens: 0, cache_read_input_tokens: 0, cache_creation_input_tokens: 0 }
const M = 1_000_000

test('prices each token kind at its own rate, longest id prefix first', () => {
  expect(costOf('claude-opus-5-5', { ...NONE, input_tokens: M })).toBe(4)
  expect(costOf('claude-opus-5', { ...NONE, input_tokens: M })).toBe(5)
  expect(costOf('claude-opus-5-5', { ...NONE, output_tokens: M })).toBe(20)
  expect(costOf('claude-opus-5-5', { ...NONE, cache_read_input_tokens: M })).toBe(0.2)
  expect(costOf('claude-opus-5-5', { ...NONE, cache_creation_input_tokens: M })).toBe(8)
  expect(costOf('claude-haiku-4-5-20251001', { ...NONE, input_tokens: M })).toBe(1)
  expect(costOf('claude-fable-5-1', { ...NONE, cache_read_input_tokens: M })).toBe(0.25)
  expect(costOf('some-other-model', { ...NONE, input_tokens: M })).toBe(0)
})

test('a steer keeps the running task; a real prompt starts one', () => {
  expect(taskLabel('lets contine wher we left off', undefined)).toBe('lets contine wher we left off')
  expect(taskLabel('sure', 'build the mod')).toBe('build the mod')
  expect(taskLabel('yes, go ahead with that', 'build the mod')).toBe('build the mod')
  expect(taskLabel('\n  fix the waybar weather module\nmore', 'build the mod')).toBe('fix the waybar weather module')
  expect(taskLabel('x'.repeat(60), undefined)).toBe(`${'x'.repeat(47)}…`)
})

test('days are local to the offset', () => {
  expect(parseOffset('+0300\n')).toBe(180)
  expect(parseOffset('-0530')).toBe(-330)
  const lateUtc = Date.parse('2026-10-06T22:30:00Z')
  expect(dayOf(lateUtc, 0)).toBe('2026-10-06')
  expect(dayOf(lateUtc, 180)).toBe('2026-10-07')
})

test('the report keeps off-plan consults apart and honours the range', () => {
  const a = newLedger('a', 'config76')
  record(a, { day: '2026-10-07', task: 'mod', model: 'claude-opus-5-5', agent: 'main', usage: { ...NONE, input_tokens: M } })
  record(a, { day: '2026-10-07', task: 'mod', model: 'claude-haiku-4-5', agent: 'Explore', usage: { ...NONE, input_tokens: M } })
  record(a, { day: '2026-10-01', task: 'old', model: 'claude-opus-5-5', agent: 'main', usage: { ...NONE, input_tokens: M } })
  record(a, {
    day: '2026-10-07',
    task: 'mod',
    model: 'claude-fable-5-1',
    agent: 'consult',
    usage: { ...NONE, input_tokens: 1000 },
    usd: 0.5,
  })
  const b = newLedger('b', 'budget76-ios')
  record(b, { day: '2026-10-07', task: 'ledger', model: 'claude-opus-5-5', agent: 'main', usage: { ...NONE, output_tokens: M } })

  const r = aggregate([a, b], 'today', '2026-10-07')
  expect(r.sessions).toBe(2)
  expect(r.usd).toBe(25)
  expect(r.byProject.map(l => l.name)).toEqual(['budget76-ios', 'config76'])
  expect(r.byAgent.map(l => [l.name, l.usd])).toEqual([
    ['main', 24],
    ['Explore', 1],
  ])
  expect(r.byModel[0]?.name).toBe('opus-5.5')
  expect(r.consult).toMatchObject({ calls: 1, usd: 0.5 })
})

test('booking the same key twice adds to one row', () => {
  const l = newLedger('a', 'p')
  const entry = { day: '2026-10-07', task: 't', model: 'claude-opus-5-5', agent: 'main', usage: { ...NONE, output_tokens: 10 } }
  record(l, entry)
  record(l, entry)
  expect(l.rows).toHaveLength(1)
  expect(l.rows[0]).toMatchObject({ runs: 2, output: 20 })
})

test('the turn line sums input, shows cache share, subagents and $', () => {
  const usage = { input_tokens: 2_000, output_tokens: 2_100, cache_read_input_tokens: 90_000, cache_creation_input_tokens: 8_000 }
  const agents = [
    { type: 'Explore', model: 'claude-haiku-4-5-20251001', tokens: 9_000 },
    { type: 'Explore', model: 'claude-haiku-4-5-20251001', tokens: 9_300 },
  ]
  expect(turnLine(usage, agents, 0.4231)).toBe('↳ 100k in (90% cached) · 2.1k out · Explore×2 haiku-4.5 18k · $0.42')
  expect(turnLine(undefined, [], 1)).toBeUndefined()
})

const text = (parts: readonly { text: string }[]) => parts.map(p => p.text).join('')

const B = { good: 150_000, limit: 300_000 }

const BAND = {
  at: Date.parse('2026-10-07T10:00:00Z'),
  ctxPct: 29,
  ctxTokens: 288_000,
  ctxWindow: 1_000_000,
  compactAt: 967_000,
  categories: [
    { name: 'System prompt', tokens: 3_200, color: 'promptBorder', kind: 'used' as const },
    { name: 'System tools', tokens: 12_000, color: 'inactive', kind: 'used' as const },
    { name: 'MCP tools', tokens: 30_000, color: 'permission', kind: 'deferred' as const },
    { name: 'Messages', tokens: 272_800, color: 'claude', kind: 'used' as const },
    { name: 'Free space', tokens: 679_000, color: 'subtle', kind: 'free' as const },
    { name: 'Autocompact buffer', tokens: 33_000, color: 'inactive', kind: 'buffer' as const },
  ],
  limits: [
    { kind: 'five_hour', pct: 23.5, resetsAt: '2026-10-07T12:14:00Z' },
    { kind: 'seven_day', pct: 91, resetsAt: '2026-10-10T14:00:00Z' },
  ],
  usd: 3.12,
}

/** BAND with `messages` resized so the session holds `tokens`. */
const sized = (tokens: number) => ({
  ...BAND,
  ctxTokens: tokens,
  categories: BAND.categories.map(c => (c.name === 'Messages' ? { ...c, tokens: tokens - 15_200 } : c)),
})

const colors = (parts: readonly { text: string; color?: string }[]) =>
  parts.filter(p => /[█▓░┊┃▏]/.test(p.text)).map(p => [p.color, p.text])

test('a lean session: green badge, the bar spans the limit, marked at lean and at the limit', () => {
  const row = contextRow(sized(100_000), 60, B)
  expect(text(row)).toBe(`◆ 100k / 300k  ${'█'.repeat(14)}${'░'.repeat(6)}┊${'░'.repeat(17)}┃  33% `)
  expect(text(row)).toHaveLength(60)
  expect(badgePart(sized(100_000), B).bg).toBe('success')
})

test('a heavy session: amber badge as a share of the limit, not of the 1M window', () => {
  const row = contextRow(BAND, 60, B)
  expect(text(row)).toBe(`◆ 288k / 300k  ${'█'.repeat(38)}┃  96% `)
  expect(colors(row)).toEqual([
    ['#7aa2f7', '█'],
    ['#7dcfff', '██'],
    ['#ff9e64', '█'.repeat(35)],
    ['error', '┃'],
  ])
  expect(badgePart(BAND, B)).toMatchObject({ text: ' 96% ', bg: 'warning' })
})

test('past the limit: the bar rescales to the session and turns red beyond the limit', () => {
  const row = contextRow(sized(360_000), 60, B)
  expect(colors(row)).toEqual([
    ['#7aa2f7', '█'],
    ['#7dcfff', '█'],
    ['#ff9e64', '█'.repeat(30)],
    ['error', '▓'.repeat(6)],
  ])
  expect(badgePart(sized(360_000), B)).toMatchObject({ text: ' 120% ', bg: 'error' })
})

test('a window smaller than the limit is the limit', () => {
  const small = { ...sized(120_000), ctxWindow: 200_000 }
  expect(text(contextRow(small, 60, B))).toContain(' / 200k  ')
  expect(badgePart(small, B).text).toBe(' 60% ')
})

test('the legend is one line in bar order, then what is left of the budget or how far over', () => {
  expect(text(legendLine(BAND, 80, B))).toBe('■ system 3.2k  ■ tools 12k  ■ messages 273k  ■ left 12k')
  expect(text(legendLine(BAND, 40, B))).toBe('■ tools 12k  ■ messages 273k  ■ left 12k')
  const over = legendLine(sized(360_000), 80, B)
  expect(text(over)).toContain('■ over 60k')
  expect(over.find(p => p.text === 'over ')?.color).toBe('error')
})

test('the footer is bare meters, reset times and the session $, the meters shrinking to fit', () => {
  expect(text(limitParts(BAND))).toBe(`${'━'.repeat(10)} 24% 2h14m   ${'━'.repeat(10)} 91% 3d4h   $3.12`)
  expect(text(limitParts(BAND, 45))).toBe(`${'━'.repeat(6)} 24% 2h14m   ${'━'.repeat(6)} 91% 3d4h   $3.12`)
  expect(limitParts(BAND).find(p => p.text === '━'.repeat(9))?.color).toBe('error')
  const reversed = { ...BAND, limits: [...BAND.limits].reverse() }
  expect(text(limitParts(reversed))).toBe(text(limitParts(BAND)))
})

test('small helpers', () => {
  expect(fmtTok(1_000_000)).toBe('1M')
  expect(fmtTok(1_500_000)).toBe('1.5M')
  expect(fmtTok(3_000)).toBe('3k')
  expect(fmtTok(260_400)).toBe('260k')
  expect(shortModel('claude-opus-5-5')).toBe('opus-5.5')
  expect(shortModel('claude-sonnet-5')).toBe('sonnet-5')
  expect(fmtUntil('2026-10-07T10:45:00Z', Date.parse('2026-10-07T10:00:00Z'))).toBe('45m')
})

test('the card: model and effort, repo, branch with a dirty mark', () => {
  expect(modelName('claude-opus-5-5')).toBe('Opus 5.5')
  expect(modelName('claude-haiku-4-5-20251001')).toBe('Haiku 4.5')
  expect(modelName('claude-sonnet-5[1m]')).toBe('Sonnet 5')
  expect(modelName('opus')).toBe('Opus')
  expect(parseGitStatus('# branch.oid 0123456789\n# branch.head main\n1 .M N... 100644 100644 100644 a b f.ts\n')).toEqual({
    branch: 'main',
    isDirty: true,
  })
  expect(parseGitStatus('# branch.oid 0123456789\n# branch.head (detached)\n')).toEqual({ branch: '0123456', isDirty: false })
  const rows = cardRows({ model: 'claude-opus-5-5', effort: 'xhigh', repo: 'config76', branch: 'main', isDirty: true }).map(text)
  expect(rows).toEqual(['\u{F06A9} Opus 5.5  xhigh ', '\u{F024B} config76', '\u{F062C} main*'])
})
