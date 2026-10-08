# kb-ingest templates

Live examples to copy the tone from:
- Source note: `~/vault76/05 Resources/Design/Product Design Playbook/Tim Gabe — Undertone Second Visit.md`
- Playbook: `.../Product Design Playbook/Playbook — Retention Moments.md`
- Digest: `.../Product Design Playbook/00 Top Product Design Rules.md`
- MOC: `.../Product Design Playbook/00 Product Design Playbook MOC.md`
- 🟡 fold-in with changelog: `~/vault76/04 Areas/Metier/Indie/App Framework/06 Marketing, ASO & Launch.md` § Creative strategy

## Source note (🟢 only)

```markdown
---
type: <collection>-source            # e.g. product-source, animation-note
kb: <slug>
summary: "<who> on <what>: <the one-line lesson>"
use_when: [<moments this helps with>]
sources: ["<url>"]
grade: {actionable: N, credibility: N, novelty: N, fit: N}
updated: YYYY-MM-DD
tags: [kb/<slug>, <domain>/<topic>, source/video|article|book]
---
# <Author> — <Short Title>

> **Nav:** [[00 <Collection> MOC|<Collection>]] › Sources › <Author> — <Short Title>

**Source:** [<original title>](<url>) — <author>, <length>. <Who they are, one line>. Extracted
YYYY-MM-DD from <auto-captions|article>. Raw transcript: `transcripts/<id>-<slug>.<lang>.txt`.

**In one line.** <the lesson>

> **Caveats.** <incentive, pitch share, missing outcome data, auto-caption names>. Grades A/C/N/F.

## <Substance sections: diagnosis table, what they did, numbered patterns, thesis>

## Unverified claims        <!-- only if hype numbers matter for context -->

## Folded into
- [[Playbook — …]] rules … · other collections' playbooks + rule numbers
```

## Rule line (inside a playbook)

```markdown
N. **<Imperative rule in bold.>** <One or two lines: threshold, when, how.>
   ([[Source Note]] · [[Older Source]])
```
Digest rules add the count: `(n=2: [[A]] · [[B]])`.

## Playbook

```markdown
---
type: <collection>-playbook
kb: <slug>
summary: "<what moment/problem, merged from which sources>"
use_when: [<moments>]
updated: YYYY-MM-DD
tags: [kb/<slug>, <domain>/playbook, <domain>/<topic>]
---
# Playbook — <Moment>

> **Nav:** [[00 <Collection> MOC|<Collection>]] › Playbooks › <Moment>

**Core idea.** <3–4 sentences>

## Rules
**<Group>**
1. …

## Never
- …

## My apps
- **Tend.** … (hypothesis, checked against DESIGN.md)
- **Budget76.** …
- **intelect.md.** …
- **BibleTimeline.** …   <!-- only the apps it really touches -->

## Checklist
- [ ] …

Related: [[…]]
```

## Ledger row

```markdown
| YYYY-MM-DD | [<title>](<url>) `<id>` | video 17:00 | 🟡 Mine | A/C/N/F | kept + parked / claims | [[target]] § section | <why, one line> |
```
Insert as the first data row (newest first).

## New collection (seed)

Path: `~/vault76/05 Resources/<Domain>/<Name> Playbook/` (or under `04 Areas/...` if it's personal strategy).

1. `00 <Name> Playbook MOC.md`: `type: moc`, how-to-use layer table, router, precedence, Sources table, Wanted list.
2. `00 Top <Name> Rules.md`: the digest, with n-counts.
3. `Playbook — <first moment>.md`: at least one.
4. `<Author> — <Title>.md` + `transcripts/`.
5. Hub `01 Dashboard/Knowledge Playbooks.md`: registry row (with **Feeds on**) + router row.
6. Link the sibling MOCs both ways; add it to `Home.md` if it's a major domain.
