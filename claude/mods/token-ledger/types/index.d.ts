/** One rate-limit window as the strip draws it. */
export type StripLimit = { kind: string; pct: number; resetsAt?: string }

/** One row of the context breakdown; `color` is the theme key /context draws it in. */
export type StripCategory = {
  name: string
  tokens: number
  color: string
  kind: 'used' | 'free' | 'buffer' | 'deferred'
}

/** The figures the band above the prompt draws, as of `at`. */
export type Strip = {
  at: number
  ctxPct?: number
  ctxTokens?: number
  ctxWindow: number
  /** Where auto-compaction runs, in tokens; absent when it is off. */
  compactAt?: number
  categories: StripCategory[]
  limits: StripLimit[]
  usd?: number
}

/** What the card beside the band shows: the main loop's model and effort, and where it works. */
export type Card = {
  model: string
  effort?: string
  repo?: string
  branch?: string
  isDirty: boolean
}

export type Range = 'today' | '7d' | '30d'

/** One row of a /tokens breakdown. */
export type ReportLine = { name: string; tokens: number; usd: number }

/** What the /tokens pane draws. */
export type Report = {
  range: Range
  since: string
  sessions: number
  tokens: number
  input: number
  cacheRead: number
  output: number
  usd: number
  byProject: ReportLine[]
  byTask: ReportLine[]
  byModel: ReportLine[]
  byAgent: ReportLine[]
  consult: { calls: number; tokens: number; usd: number; byTask: ReportLine[] }
}

declare module 'claude-code' {
  interface PluginState {
    'token-ledger': { strip: Strip | null; report: Report | null; card: Card | null }
  }
}
