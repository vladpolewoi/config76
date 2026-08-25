# Global Claude Config

## The machines

Four devices, one LAN. Know which one a job belongs on before starting it.

| Role | Machine | Details |
|---|---|---|
| Dev desktop | **Arch** — `quest76` | `192.168.100.107` (eno1, DHCP), GTX 1060 6 GB, 16 cores, 15 GB RAM, Hyprland/Wayland. Always on. Runs Claude Code. Holds every repo. |
| Build host | **Mac** — ssh alias `mac` | `192.168.100.159`, Xcode-beta. Signs and installs iOS builds via `iosdev`. Often asleep — check reachability before depending on it. |
| Phone | **iPhone 15 Pro Max** | iOS 27.0, Developer Mode on, paired to both Arch and the Mac. Owns the Budget76 ledger. |
| Tablet | **iPad Air 11" (M2)** | Apple Pencil Pro. M2 ⇒ Apple Intelligence ⇒ `FoundationModels` available. |

- **Source code lives on Arch only.** Anything needing the repo runs there — never assume the
  Mac or a device has it.
- **The Mac has an ancient rsync** that rejects modern flags. Use `tar cf - . | tar xf -` over
  ssh instead.
- **`sudo` has no TTY through Claude Code.** Hand Vlad the command to run in a real terminal.
- **iOS 17+ killed `idevicescreenshot`** — `screenshotr` moved behind RemoteXPC. Pairing and
  `ideviceinfo` still work; screenshots do not, DDI mounted or otherwise. Capture from the Mac
  with `xcrun devicectl device capture screenshot`, which needs the phone `connected`, not
  merely `available (paired)`.

## Token Protection Strategy

- Before spawning 3+ parallel agents → **Ask for confirmation**
- **Browser work** → delegate to the `browser-operator` subagent. Never call
  `mcp__playwright__*` from the main thread — snapshots are huge and pollute context.
  The subagent does the clicking and returns a text summary only.

## Web search — use the self-hosted SearXNG

**Default search engine for everything: `mcp__searxng__searxng_web_search`.**
Read the pages it finds with `mcp__searxng__web_url_read`. This is Vlad's own
instance — no per-query cost, no rate limit, no third party sees the queries.

- Applies to research tasks, quick lookups, and doc-hunting alike.
- **Subagents inherit this.** When spawning any agent that will search the web,
  say so in its prompt — a fresh agent defaults to `WebSearch` otherwise.
- Fall back to `WebSearch` / Tavily / Brave only when searxng errors or returns
  nothing usable, and say which query needed the fallback.
- `context7` still wins for library/framework/API docs — that is not a search.

## iOS apps

Build/sign/install iOS apps from Arch via the remote Mac — never try to run
Xcode locally. Use the `iosdev` tool: `cd <ios-repo> && iosdev run`.
Full flow, config, and troubleshooting: **`~/.config/iosdev/README.md`**
(also `iosdev --help`). A new iOS app needs only a 2-line `<repo>/.iosdev`
(SCHEME, BUNDLE_ID) — do NOT copy build docs into each project.

## Vlad's budget

One source of truth: the **SQLite ledger on the iPhone** (Budget76 app —
`~/code/budget76-ios`, owned by its `Vault` type). Everything else is a copy.

- **"pull budget"** = `cd ~/code/budget76-ios && tools/pull-ledger.sh` →
  refreshes the read-only working copy at
  `~/vault76/04 Areas/Metier/Finance/budget76/db/ledger.sqlite` (the budget76
  wiki in the Obsidian vault), inspect with `sqlite3`. Phone must be reachable
  from the Mac. Never write to a snapshot, never push a database back to the
  phone.
- Any question about Vlad's spending/balances → pull first, then query.
  A snapshot on disk is stale by definition.
- `~/code/budget76` — the old web app; spec and reference only, its data is
  historical, not current.

## Credentials

Every credential that cannot be regenerated for free — Apple `.p8` keys (ASC API, APNs),
DB passwords, third-party API keys — belongs in **Bitwarden**, one folder per project.
A copy on disk or in a `.env` is a working cache, never the backup. When a task produces
such a credential, file it in the vault in the same session.

- `bw` CLI is installed on both machines (Arch `~/.local/bin/bw`, Mac `/opt/homebrew/bin/bw`),
  logged in to the EU server. Adding from either machine syncs to the other.
- **Free tier has no file attachments** — uploading one fails with "Premium status is required".
  Store key files as a hidden custom field holding base64
  (`base64 < AuthKey_X.p8 | tr -d '\n'`), and put the `base64 -d` restore line in the notes.
- Claude never handles the master password: Claude authors the `bw` script, Vlad runs it
  in a real terminal so `bw unlock --raw` gets a TTY. Same for `.p12` export passphrases.
- Items are secure notes (`type=2`) with custom fields; `type: 1` marks a field hidden.

## Commands

Custom commands are in `.claude/commands/`:
- `/task` - Structured development workflow
