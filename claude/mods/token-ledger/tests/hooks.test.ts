import { expect, mock, test } from 'claude-code/testing'

const HAIKU = { model: 'claude-haiku-4-5-20251001', input_tokens: 9_000, output_tokens: 300, cache_read_input_tokens: 0, cache_creation_input_tokens: 0 }
const OPUS = { model: 'claude-opus-5-5', input_tokens: 2_000, output_tokens: 2_100, cache_read_input_tokens: 90_000, cache_creation_input_tokens: 8_000 }

test('a main turn is booked and gets a cost line naming its subagents', async ($, on) => {
  let usd = 1
  const files = new Map<string, string>()
  on('session.id', () => ({ value: 'sess-1' }))
  on('session.root', () => ({ value: '/home/v/config76' }))
  on('session.usage', () => ({ value: { startedAt: 0, context: { window: 200_000 }, rateLimits: [], cost: { usd } } }))
  mock.clock(on, { now: Date.parse('2026-10-07T10:00:00Z') })
  mock.env(on, { HOME: '/home/v' })
  on('process.run', () => ({
    value: { exitCode: 0, stdout: '+0000\n', stderr: '', isStdoutTruncated: false, isStderrTruncated: false },
  }))
  on('fs.read', ($, e) => {
    const text = files.get(e.path)
    if (text === undefined) throw new Error(`ENOENT ${e.path}`)
    return { value: text }
  })
  on('fs.write', ($, e) => {
    files.set(e.path, e.text)
    return { value: undefined }
  })
  on('command.register', ($, e) => ({ value: { command: e.name } }))
  on('session.start', ($, e) => ({ cwd: e.cwd }))
  on('prompt.submit', ($, e) => ({ text: e.text }))
  on('turn.start', ($, e) => ({ turnId: e.turnId }))
  on('agent.spawn', () => ({ model: 'claude-haiku-4-5', agentId: 'agent-1' }))
  on('turn.complete', ($, e) => ({ text: e.answer, usage: e.usage }))

  await $.session.start({ cwd: '/home/v/config76', surface: null, isInteractive: true })
  await $.prompt.submit({ text: 'build the token ledger mod', wait: false, origin: { kind: 'composer' } })
  await $.turn.start({ text: 'build the token ledger mod', turnId: 't1' })
  await $.agent.spawn({
    tool_use_id: 'tu-1',
    prompt: 'find things',
    description: 'find',
    subagentType: 'Explore',
    provider: { plugin: 'engine', tier: 'core' },
    parentModel: 'claude-opus-5-5',
    background: false,
    fork: false,
  })
  const sub = await $.turn.complete({
    answer: 'found',
    durationMs: 10,
    isAborted: false,
    turnId: 't1',
    agentId: 'agent-1',
    reason: 'answer',
    usage: HAIKU,
  })
  expect(sub.text).toBe('found')

  usd = 1.5
  const main = await $.turn.complete({ answer: 'done', durationMs: 20, isAborted: false, turnId: 't1', reason: 'answer', usage: OPUS })
  expect(main.text).toBe('↳ 100k in (90% cached) · 2.1k out · Explore haiku-4.5 9.3k · $0.50')

  const saved = JSON.parse(files.get('/home/v/.claude/token-ledger/sess-1.json') ?? '{}')
  expect(saved.project).toBe('config76')
  expect(saved.task).toBe('build the token ledger mod')
  expect(saved.rows.map((r: { agent: string }) => r.agent)).toEqual(['Explore', 'main'])
})
