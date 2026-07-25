# Global Claude Config

## Token Protection Strategy

- Before spawning 3+ parallel agents → **Ask for confirmation**
- **Browser work** → delegate to the `browser-operator` subagent. Never call
  `mcp__playwright__*` from the main thread — snapshots are huge and pollute context.
  The subagent does the clicking and returns a text summary only.

## iOS apps

Build/sign/install iOS apps from Arch via the remote Mac — never try to run
Xcode locally. Use the `iosdev` tool: `cd <ios-repo> && iosdev run`.
Full flow, config, and troubleshooting: **`~/.config/iosdev/README.md`**
(also `iosdev --help`). A new iOS app needs only a 2-line `<repo>/.iosdev`
(SCHEME, BUNDLE_ID) — do NOT copy build docs into each project.

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
