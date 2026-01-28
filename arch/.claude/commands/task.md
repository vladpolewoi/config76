# Task Workflow Command

You are executing a structured development workflow. Follow these stages exactly.

**Input:** $ARGUMENTS (path to screenshot or task description)

---

## STAGE 1: ANALYZE

1. Read the screenshot/task description provided
2. Understand what needs to be done (feature, bug fix, refactor, etc.)
3. Identify which files likely need changes
4. Create a clear plan with numbered steps

**Output to user:**
```
📋 TASK ANALYSIS
================
Type: [Feature / Bug Fix / Refactor / etc.]
Summary: [One line description]

Plan:
1. [Step 1]
2. [Step 2]
...

Files to modify:
- [file1]
- [file2]
```

Ask: "Does this plan look correct? Should I proceed with implementation?"

Wait for user confirmation before proceeding.

---

## STAGE 2: IMPLEMENT

1. Create a new branch from current branch:
   - For features: `feature/<short-description>`
   - For bugs: `fix/<short-description>`
   - For refactors: `refactor/<short-description>`

2. Implement the changes according to the plan

3. After implementation, run:
   - `npm run lint` (or project's lint command)
   - `npm run build` (or project's build command)

4. Fix any lint/build errors

**Output to user:**
```
✅ IMPLEMENTATION COMPLETE
==========================
Branch: [branch-name]
Changes:
- [file1]: [what changed]
- [file2]: [what changed]

Lint: ✅ Pass
Build: ✅ Pass
```

Ask: "Implementation complete. Ready for testing?"

---

## STAGE 3: TEST

1. Start the dev server if not running
2. Use Playwright browser tools to:
   - Navigate to the relevant page/feature
   - Show the user what was changed

**Output to user:**
```
🧪 TESTING
==========
Browser opened at: [URL]
Please verify:
- [ ] [What to check 1]
- [ ] [What to check 2]
```

Ask: "Does the feature/fix work as expected? (yes/no/issues)"

If issues: Go back to Stage 2 to fix
If yes: Proceed to Stage 4

---

## STAGE 4: PR PREPARATION

1. Prepare commit message using gitmoji format:
   - `:sparkles:` for new features
   - `:bug:` for bug fixes
   - `:recycle:` for refactors
   - `:lipstick:` for UI changes
   - `:zap:` for performance
   - `:memo:` for docs

2. Show user everything BEFORE creating:

**Output to user:**
```
📝 PR PREPARATION
=================
Branch: [branch-name]
Commit message: [gitmoji message]

PR Title: [title]
PR Description:
[description]

Changed files:
- [file1]
- [file2]
```

Ask: "Review the above. Should I create the commit and PR? (yes/edit/cancel)"

If yes:
- Create commit (NO AI signature, NO Co-Authored-By)
- Push branch
- Create PR using `gh pr create`

If edit: Ask what to change, then show again

---

## IMPORTANT RULES

- **NO AI SIGNATURES**: Do not add "Generated with Claude Code" or "Co-Authored-By: Claude" to commits
- **GITMOJI FORMAT**: Always use gitmoji in commit messages (`:emoji: message`)
- **HUMAN-LIKE**: All commits and PRs should look like human work
- Use TodoWrite to track progress through stages

## EXTERNAL ACTIONS - ALWAYS ASK FIRST

**NEVER perform these actions without explicit user approval:**
- Creating/pushing commits
- Creating/updating pull requests
- Pushing to remote repositories
- Updating task status on any platform
- Sending messages or notifications anywhere
- Any action that affects external systems or is visible to others

**Local actions that are OK without asking:**
- Reading files
- Editing local files
- Creating local branches
- Running local builds/tests
- Opening browser for local testing
