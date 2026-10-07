import { expect, mock, test } from 'claude-code/testing'
import type { On } from 'claude-code'

const SURFACES = ['terminal', 'desktop'] as const
const NOW = Date.parse('2026-10-07T10:00:00Z')

const LEDGER = {
  v: 1,
  sessionId: 'old',
  project: 'budget76-ios',
  updatedAt: NOW,
  rows: [
    { day: '2026-10-07', task: 'pull the ledger', model: 'claude-opus-5-5', agent: 'main', runs: 3, input: 1000, output: 5000, cacheRead: 200_000, cacheWrite: 10_000, usd: 0.32 },
    { day: '2026-10-07', task: 'pull the ledger', model: 'claude-fable-5-1', agent: 'consult', runs: 1, input: 6000, output: 9000, cacheRead: 0, cacheWrite: 0, usd: 0.51 },
  ],
}

const BREAKDOWN = {
  categories: [
    { name: 'System prompt', tokens: 3_200, color: 'promptBorder', isDeferred: false, kind: 'used' as const },
    { name: 'Messages', tokens: 416_800, color: 'claude', isDeferred: false, kind: 'used' as const },
    { name: 'Free space', tokens: 580_000, color: 'subtle', isDeferred: false, kind: 'free' as const },
  ],
  totalTokens: 420_000,
  maxTokens: 1_000_000,
  rawMaxTokens: 1_000_000,
  autocompactSource: 'model' as never,
  percentage: 42,
  gridRows: [],
  model: 'claude-opus-5-5',
  memoryFiles: [],
  mcpTools: [],
  agents: [],
  autoCompactThreshold: 967_000,
  isAutoCompactEnabled: true,
  apiUsage: null,
}

/** The engine beneath the plugin: a session on a subscription and a ledger folder. */
function engine(on: On, env: Record<string, string> = {}) {
  const files = new Map<string, string>([['/home/v/.claude/token-ledger/old.json', JSON.stringify(LEDGER)]])
  mock.clock(on, { now: NOW })
  mock.env(on, { HOME: '/home/v', ...env })
  on('session.id', () => ({ value: 'sess-1' }))
  on('session.root', () => ({ value: '/home/v/config76' }))
  on('session.usage', ($, e) => ({
    value: {
      startedAt: 0,
      context: { window: 1_000_000, tokens: 420_000, percent: 42, ...(e.breakdown === undefined ? {} : { breakdown: BREAKDOWN }) },
      rateLimits: [
        { kind: 'five_hour', percentUsed: 23.5, resetsAt: '2026-10-07T12:14:00Z' },
        { kind: 'seven_day', percentUsed: 91, resetsAt: '2026-10-10T14:00:00Z' },
      ],
      cost: { usd: 3.12 },
    },
  }))
  on('process.run', ($, e) => {
    const out = (stdout: string) => ({ value: { exitCode: 0, stdout, stderr: '', isStdoutTruncated: false, isStderrTruncated: false } })
    if (e.argv[0] === 'date') return out('+0000\n')
    if (e.argv.includes('rev-parse')) return out('/home/v/config76\n')
    return out('# branch.oid 0123456789\n# branch.head main\n1 .M N... 100644 100644 100644 a b f.ts\n')
  })
  on('session.model', () => ({ value: 'opus' }))
  on('classic.Stop', () => ({}))
  on('settings.read', () => ({ value: {} }))
  on('fs.read', ($, e) => {
    const text = files.get(e.path)
    if (text === undefined) throw new Error(`ENOENT ${e.path}`)
    return { value: text }
  })
  on('fs.write', ($, e) => {
    files.set(e.path, e.text)
    return { value: undefined }
  })
  on('fs.list', () => ({
    value: [...files.keys()].map(path => ({
      name: path.split('/').pop() ?? path,
      kind: 'file' as const,
      size: 1,
      mtimeMs: NOW,
      isLink: false,
    })),
  }))
  on('command.register', ($, e) => ({ value: { command: e.name } }))
  on('ui.open', () => ({ value: { isPlaced: true } }))
  on('session.start', ($, e) => ({ cwd: e.cwd }))
}

test('the band is three rows, framed where the slot has room', async ($, on) => {
  engine(on)
  await $.session.start({ cwd: '/home/v/config76', surface: null, isInteractive: true })
  for (const surface of SURFACES) {
    for (const maxRows of [20, 3]) {
      const band = await $.ui.mount({
        plugin: 'token-ledger',
        surface,
        component: 'AbovePrompt',
        props: { hasSurvey: false, isWorking: false, maxRows, bodyColumns: 120, scroll: { offset: 0, bodyRows: maxRows }, view: {} },
      })
      expect(await band.find({ type: 'Text', text: ' / 300k  ' })).toBeDefined()
      expect(await band.find({ type: 'Text', text: ' 140% ' })).toBeDefined()
      expect(await band.find({ type: 'Text', text: 'messages ' })).toBeDefined()
      expect(await band.find({ type: 'Text', text: 'over ' })).toBeDefined()
      expect(await band.find({ type: 'Text', text: ' 2h14m' })).toBeDefined()
      expect(await band.find({ type: 'Text', text: '$3.12' })).toBeDefined()
      const box = await band.find({ type: 'Box', key: 'context' })
      expect(box?.props.borderStyle).toBe(maxRows === 20 ? 'round' : undefined)
      await band.unmount()
    }
  }
})

test('the card beside the band names the model, the effort once a turn reports it, repo and branch', async ($, on) => {
  engine(on)
  await $.session.start({ cwd: '/home/v/config76', surface: null, isInteractive: true })
  await $.classic.Stop({ stop_hook_active: false, effort: { level: 'xhigh' } } as never)
  const band = await $.ui.mount({
    plugin: 'token-ledger',
    surface: 'terminal',
    component: 'AbovePrompt',
    props: { hasSurvey: false, isWorking: false, maxRows: 20, bodyColumns: 120, scroll: { offset: 0, bodyRows: 20 }, view: {} },
  })
  expect(await band.find({ type: 'Text', text: 'Opus' })).toBeDefined()
  expect(await band.find({ type: 'Text', text: ' xhigh ' })).toBeDefined()
  expect(await band.find({ type: 'Text', text: 'config76' })).toBeDefined()
  expect(await band.find({ type: 'Text', text: 'main' })).toBeDefined()
  expect(await band.find({ type: 'Text', text: '*' })).toBeDefined()
  await band.unmount()
  const narrow = await $.ui.mount({
    plugin: 'token-ledger',
    surface: 'terminal',
    component: 'AbovePrompt',
    props: { hasSurvey: false, isWorking: false, maxRows: 20, bodyColumns: 70, scroll: { offset: 0, bodyRows: 20 }, view: {} },
  })
  expect(await narrow.find({ type: 'Text', text: 'config76' })).toBeUndefined()
})

test('the card shows the effort from the start, before any turn reports it', async ($, on) => {
  engine(on, { CLAUDE_EFFORT: 'high' })
  await $.session.start({ cwd: '/home/v/config76', surface: null, isInteractive: true })
  const band = await $.ui.mount({
    plugin: 'token-ledger',
    surface: 'terminal',
    component: 'AbovePrompt',
    props: { hasSurvey: false, isWorking: false, maxRows: 20, bodyColumns: 120, scroll: { offset: 0, bodyRows: 20 }, view: {} },
  })
  expect(await band.find({ type: 'Text', text: ' high ' })).toBeDefined()
})

test('the limit comes from the plugin options', { options: { limitTokens: 500_000 } }, async ($, on) => {
  engine(on)
  await $.session.start({ cwd: '/home/v/config76', surface: null, isInteractive: true })
  const band = await $.ui.mount({
    plugin: 'token-ledger',
    surface: 'terminal',
    component: 'AbovePrompt',
    props: { hasSurvey: false, isWorking: false, maxRows: 20, bodyColumns: 120, scroll: { offset: 0, bodyRows: 20 }, view: {} },
  })
  expect(await band.find({ type: 'Text', text: ' / 500k  ' })).toBeDefined()
  expect(await band.find({ type: 'Text', text: ' 84% ' })).toBeDefined()
  expect(await band.find({ type: 'Text', text: 'left ' })).toBeDefined()
})

test('/tokens opens the pane, and a range button redraws it', async ($, on) => {
  engine(on)
  await $.session.start({ cwd: '/home/v/config76', surface: null, isInteractive: true })
  const ran = await $.command.run({
    command: 'tokens',
    args: '',
    origin: { kind: 'composer' },
    presentation: { isFullscreen: true, columns: 160 },
  })
  expect(ran.text).toBeUndefined()
  for (const surface of SURFACES) {
    const pane = await $.ui.mount({
      plugin: 'token-ledger',
      surface,
      component: 'Pane',
      requestId: 'token-ledger',
      props: { title: 'Tokens', isFocused: true, bodyColumns: 80, placement: 'dock', scroll: { offset: 0, bodyRows: 40 }, view: {} },
    })
    expect(await pane.find({ type: 'Text', text: /budget76-ios/ })).toBeDefined()
    expect(await pane.find({ type: 'Text', text: /Fable consults/ })).toBeDefined()
    await pane.press({ key: 'range-7d' })
    expect(await pane.find({ type: 'Text', text: /since 2026-10-01/ })).toBeDefined()
    await pane.press({ key: 'range-today' })
    await pane.unmount()
  }
})
