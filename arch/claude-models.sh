#!/usr/bin/env bash
# Claude Model Configuration
# Defines model strategy and selection rules

# Model IDs
CLAUDE_HAIKU="claude-haiku-4-5-20251001"
CLAUDE_SONNET="claude-sonnet-4-5-20250929"
CLAUDE_OPUS="claude-opus-4-6"

# Default model for balanced work
export CLAUDE_DEFAULT_MODEL="$CLAUDE_SONNET"

# Model selection strategy (for Claude Code/Agents to follow)
# This is documented guidance, not enforced configuration
cat << 'EOF' > /dev/null
=== CLAUDE MODEL SELECTION STRATEGY ===

HAIKU 4.5 ($CLAUDE_HAIKU)
├─ Cost: Lowest | Speed: Fastest
├─ Use for: Parallel operations, simple tasks, batch work
└─ Examples: Formatting, searches, multiple agents

SONNET 4.5 ($CLAUDE_SONNET)
├─ Cost: Medium | Speed: Balanced
├─ Use for: General development, standard tasks
└─ Examples: Writing code, fixes, documentation

OPUS 4.6 ($CLAUDE_OPUS)
├─ Cost: Highest | Speed: Slower
├─ Use for: Complex problems, critical work, research
└─ Examples: Hard problems, production code, architecture

=== TOKEN PROTECTION ===
• Before 3+ parallel agents → ASK FOR CONFIRMATION
• Parallel work → DEFAULT TO HAIKU
• Expensive tasks → USE SEQUENTIAL or GATES
• Complex work → USE OPUS

=== ANTI-PATTERNS ===
✗ Don't spawn 20+ agents without confirmation
✗ Don't use Opus for simple parallel batch work
✗ Don't use Haiku for critical architecture decisions
✓ Ask user before draining tokens
✓ Use Haiku first, escalate to Opus if needed
EOF
