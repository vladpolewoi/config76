# Global Claude Config

## Task Management

Dev tasks are tracked in Obsidian vault:
- **Vault path**: `/home/user76/vault76/`
- **Task board**: `/home/user76/vault76/2026/Dev Tasks.md` (Kanban format)

When user asks to:
- "Add task" / "Add to backlog" → Add to Backlog column
- "What's on my tasks?" → Read the task board
- "Move X to done" → Move task to Done column
- "Start working on X" → Move to In Progress

**Token Protection Strategy**:
- Before spawning 3+ parallel agents → **Ask for confirmation**

## Commands

Custom commands are in `.claude/commands/`:
- `/task` - Structured development workflow
