# iosdev — build iOS apps on Arch via a remote Mac

**Single source of truth for the iOS build/deploy flow. Do NOT copy this into
each project — point to it.** The pipeline is machine-level: one tool, one Mac,
shared by every iOS app.

Proven working end-to-end 2026-07-21 (Tend built, signed, installed + launched
on iPhone, all driven from Arch).

## Architecture

```
Arch (you: editor, git, worktrees)
  │  iosdev run
  ├─ rsync worktree ─────────────►  Mac (ssh host `mac`, Xcode 26)
  │                                   └─ xcodebuild + codesign (in ~/iosbuild/<worktree>)
  └─ devicectl install/launch ◄──────── .app  ──►  iPhone / iPad
```

Source stays on Arch. The Mac only compiles + signs. Each worktree gets its own
remote build dir and warm DerivedData, so parallel worktrees never collide.

## Daily use — from any iOS repo/worktree

    iosdev run           # rsync → build → install to device   ← main loop
    iosdev run --launch  # …and open the app
    iosdev build         # build only (validate signing)
    iosdev sync          # rsync only
    iosdev test          # sync + xcodebuild test on a simulator
    iosdev logs          # stream device console
    iosdev watch         # rebuild+install on every save (needs: pacman -S inotify-tools)
    iosdev doctor        # check ssh / xcodebuild / device / Mac disk
    iosdev prune         # reclaim Mac disk (see below)
    iosdev udid          # list device UDIDs

`iosdev test` takes extra xcodebuild flags verbatim — `iosdev test
-only-testing:TendTests/HabitMathTests`. Destination defaults to iPhone 17 Pro; override with
`TEST_DESTINATION=…`. It pins `-derivedDataPath` to the worktree: on the Mac's shared
DerivedData two sessions collide and one dies as `** BUILD INTERRUPTED **`. The full log stays
on the Mac (`~/iosbuild/<worktree>/test.log`) and only the verdict comes back — piping
xcodebuild through `tail` returns tail's exit code, so a red suite reads as green.

## Disk — this pipeline never cleaned up after itself

Every worktree gets its own remote dir with a full DerivedData (~1–3 GB), and nothing ever
removed them; simulators keep every app and log they are given. The Mac hit 100% on
2026-08-11 and builds started failing as `disk I/O error`, `Distill failed for unknown
reasons`, `The file "assetcatalog_dependencies_thinned" doesn't exist` — never as "out of
space". A full disk also corrupts the DerivedData being written, so the first fix after
freeing space is `rm -rf ~/iosbuild/<worktree>/DerivedData`.

    iosdev prune                 # drop DerivedData from build dirs idle 14+ days
    iosdev prune --days 30       # …different idle window
    iosdev prune --hard          # remove those build dirs entirely, sources and all
    iosdev prune --sims          # shut down booted simulators + delete unavailable ones

Never prunes the current worktree. `--hard` deletes the Mac's copy of gitignored build files
(`Secrets.xcconfig`, `.env`) — those mirrors are the only backup if a local worktree is gone.

Two things `prune` deliberately leaves alone, both worth checking by hand when space is tight:

- `~/Library/Developer/Xcode/iOS DeviceSupport/` — one multi-GB bundle per iOS build ever
  attached (17 GB for three). Old iOS versions are dead weight; each regenerates on next connect.
- Simulator device data — `du -sh ~/Library/Developer/CoreSimulator/Devices/*`, then
  `xcrun simctl erase <udid>` on the fat ones. Nothing in this pipeline creates simulators:
  the ~24 devices are the stock set Xcode ships per runtime, so the growth is data, not count.

## Config

- **Tool:** `~/.local/bin/iosdev`
- **Global:** `~/.config/iosdev/config` — `MAC_HOST`, `REMOTE_ROOT`, `DEVICE_UDID`,
  `INSTALL_MODE` (mac|arch), `CONFIGURATION`. Machine-local (gitignored); on a new
  machine copy `config.example` → `config` and fill it in.
- **Per-project:** `<repo>/.iosdev` — `SCHEME`, `BUNDLE_ID`, and `DEVELOPMENT_TEAM`
  *only* if the project has no team in its build settings (most real apps do).
  Team is per-project; account + keychain are machine-wide.

## Adding a NEW iOS app  (this is the whole "new project" answer)

You do NOT copy any docs. The tool + Mac + keychain unlock are already set up
machine-wide. Just drop a `.iosdev` in the repo:

    # <repo>/.iosdev
    SCHEME=MyApp
    BUNDLE_ID=com.you.MyApp

Then `cd <repo> && iosdev run`. If the app has no signing team baked in, add
`DEVELOPMENT_TEAM=XXXXXXXXXX` to that `.iosdev` (find it: `iosdev` errors will
name it, or check the project's build settings).

## The keychain gotcha (why headless signing needed extra setup)

macOS will NOT keep the login keychain accessible to non-GUI SSH sessions —
`codesign` fails with `errSecInternalComponent` / "User interaction is not
allowed", even while you're logged in at the Mac's desktop. Disabling auto-lock
does not help. Fix: **unlock the keychain in the same ssh session as each build.**

`iosdev build` sources `~/.config/iosdev/unlock.sh` on the Mac, which reads the
login password from `~/.config/iosdev/keychain-pw` (chmod 600) and runs
`security unlock-keychain -p` + `set-key-partition-list`.

**If you change your Mac login password**, re-save it:

    ssh mac
    umask 077; read -rsp "Mac password: " P; printf '%s' "$P" > ~/.config/iosdev/keychain-pw; chmod 600 ~/.config/iosdev/keychain-pw; unset P; echo saved

## Mac build node

- ssh host `mac` — set HostName (Mac LAN IP or `.local` name) + User in `~/.ssh/config`,
  key-based auth (e.g. id_ed25519).
- Requirements: Remote Login ON, Xcode installed + `xcodebuild -license accept`,
  Apple ID added in Xcode, device paired (USB or wifi), Developer Mode on device.
- Keep it awake headless: `caffeinate -dimsu &`.

## Devices

Run `iosdev udid` to list paired devices, then put the target device's UDID in
your machine-local `config` (`DEVICE_UDID=`). UDIDs are device-specific and are
intentionally **not committed** — this is a public repo.

## Troubleshooting

| Symptom | Cause / fix |
|---|---|
| `errSecInternalComponent` on codesign | keychain locked in ssh session → re-run the keychain-pw save above; check `iosdev doctor` |
| `No Account for Team` | Apple ID not added in Xcode → Xcode ▸ Settings ▸ Accounts |
| `requires a development team` | add `DEVELOPMENT_TEAM=` to the repo's `.iosdev` |
| `scheme not found` | project has no shared scheme → `ssh mac 'cd ~/iosbuild/<wt> && xcodebuild -list'` to find it, set `SCHEME=` in `.iosdev` |
| device not listed / offline | `iosdev udid`; re-pair in Xcode ▸ Devices; unlock the phone |
| `cannot ssh mac` | Mac asleep / Remote Login off; `ssh mac echo ok` |

## Version control (config76)

Tracked in config76 under `arch/`: the tool (`arch/.local/bin/iosdev`), this
README, and `config.example`. Your real `config` (holds `DEVICE_UDID`) is
machine-local and **gitignored**; the Mac-side `keychain-pw` is never committed.
config76 is a **public** repo — keep device/personal identifiers out of tracked files.
