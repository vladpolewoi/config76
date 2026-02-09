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

## Token & Model Management

**Available Models & Strategy**:

### Haiku 4.5 (`claude-haiku-4-5-20251001`)
- **Cost**: Lowest | **Speed**: Fastest
- **Best for**: Simple tasks, exploratory work, batch processing, parallel agents
- **Examples**: Formatting, quick searches, basic refactoring, multiple concurrent operations

### Sonnet 4.5 (`claude-sonnet-4-5-20250929`)
- **Cost**: Medium | **Speed**: Balanced
- **Best for**: General-purpose work, standard development tasks, integration work
- **Examples**: Writing code, minor bug fixes, documentation, moderate complexity

### Opus 4.6 (`claude-opus-4-6`)
- **Cost**: Highest | **Speed**: Slower
- **Best for**: Complex problems, high-quality results, deep research, architecture decisions
- **Examples**: Hard coding problems, production quality code, deep codebase analysis, critical features

**Token Protection Strategy**:
- Before spawning 3+ parallel agents → **Ask for confirmation**
- Parallel operations → **Default to Haiku** (cheap & fast)
- Expensive multi-agent tasks → **Use sequential processing or confirmation gates**
- Complex/critical work → **Use Opus** (quality > speed)
- General work → **Use Sonnet** (balanced approach)

## Commands

Custom commands are in `.claude/commands/`:
- `/task` - Structured development workflow
