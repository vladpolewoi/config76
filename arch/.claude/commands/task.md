# Task Workflow

**Input:** $ARGUMENTS (task description, screenshot, or Jira ID)

---

## How it works

This is a lightweight, iterative workflow. No rigid stages — just do the work, ask before external actions, and keep moving.

### 1. Understand

- Read the task input (screenshot, description, API spec, etc.)
- Explore relevant code — check existing patterns, architecture docs if available
- If on a feature branch already, continue there. Otherwise create one:
  - `feature/<short>`, `fix/<short>`, or `refactor/<short>`
- **For bug fixes:** reproduce first with Playwright before changing code
- **Skip formal planning** unless the task is ambiguous. If unclear, ask the user directly — don't write a plan document.

### 2. Implement

- Follow existing codebase patterns (check architecture docs, existing code style)
- Run lint after changes: `npx eslint <changed-files>`
- Fix lint/type errors as you go, don't batch them
- **No progress files** — the conversation is the progress tracker

### 3. Test

- Start dev server if not running (`npm run dev` in background)
- Use Playwright to verify changes work
- Test edge cases when the user asks or when they're obvious
- Handle iterative UI feedback naturally (user may send design screenshots, color values, spacing adjustments mid-flow)

### 4. Build check

- Run `npx tsc --noEmit` and `npm run build` before committing
- Fix any errors

### 5. Commit & PR

**Always ask before committing/pushing.**

When user says to commit:
- Use **gitmoji** format: `:sparkles:`, `:bug:`, `:lipstick:`, `:recycle:`, `:wrench:`, etc.
- Keep commit messages **short** (one line unless user asks for more)
- Split commits by concern if user asks (e.g. config / style / feature)
- **No AI signatures**, no Co-Authored-By

When user says to create PR:
- Read `.github/PULL_REQUEST_TEMPLATE.md` and use that format
- Keep PR description concise — bullet points, not essays
- Use `gh pr create --base stage --assignee @me` (or update existing with `gh pr edit`)
- If PR already exists, update it instead of failing

---

## Rules

### Always ask first
- Creating/pushing commits
- Creating/updating PRs
- Pushing to remote
- Updating task boards or external systems
- Any action visible to others

### Never ask, just do
- Reading/editing local files
- Creating local branches
- Running builds/tests/lint
- Opening browser for testing
- Exploring codebase

### Code style
- Follow existing patterns in the codebase
- No over-engineering — only what's needed
- Use theme tokens, not hardcoded values
- Success notifications in thunks, not components (if Redux)
- Fire-and-forget dispatch pattern (if that's what the project uses)

### Gitmoji reference
| Emoji | Use |
|-------|-----|
| `:sparkles:` | New feature |
| `:bug:` | Bug fix |
| `:lipstick:` | UI/style |
| `:recycle:` | Refactor |
| `:wrench:` | Config |
| `:arrow_up:` | Upgrade deps |
| `:memo:` | Docs |
| `:zap:` | Performance |
| `:fire:` | Remove code |
| `:truck:` | Move/rename |
