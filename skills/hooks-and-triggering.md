# Hooks & Skill Triggering Reference

How Claude Code decides when to run skills, and how to make things fire automatically.

## Three mechanisms — know which to use

| Mechanism | Guaranteed? | How |
|-----------|------------|-----|
| Hook | Yes — always fires | Shell command in `settings.json` |
| Skill auto-trigger | No — AI decides | `description` field in SKILL.md |
| Slash command | Manual only | You type it |

## Hooks — always automatic

Four events available in `~/.claude/settings.json`:

```json
{
  "hooks": {
    "PreToolUse":  [...],  // Before any tool call
    "PostToolUse": [...],  // After any tool call completes
    "Notification":[...],  // On Claude notifications
    "Stop":        [...]   // When Claude finishes a response turn
  }
}
```

**`PreToolUse`** — Use for: checks before editing files (security scans, lint warnings).  
Filter by tool with `matcher`. Example — fire only on file edits:
```json
{ "matcher": "Edit|Write|MultiEdit", "hooks": [{ "type": "command", "command": "python3 ~/script.py" }] }
```

**`Stop`** — Use for: anything you want after every response (logging, nudges, post-task cleanup).  
No matcher needed — fires at end of every Claude turn.

**Hook commands run shell scripts** — they cannot directly invoke Claude skills. They can print messages that Claude sees, or run any shell program.

To configure hooks: use the `update-config` skill ("run X every time I edit a file").

## Skill auto-triggering — AI-decided

Claude reads every skill's `description` field and decides if it's relevant. The `description` IS the triggering mechanism — it's not just documentation.

**Write descriptions that are assertive.** Claude under-triggers by default, so push harder:

Too passive:
```
description: Cleans up PHP code after editing.
```

Better:
```
description: Simplifies PHP code for clarity and maintainability. ALWAYS use after
             editing any PHP controller, model, service class, or Livewire component.
             Trigger automatically in any Laravel project after code changes, even if
             not explicitly requested.
```

To improve a skill's auto-triggering: use `skill-creator` → it has a built-in description improver script (`improve_description.py`).

## Practical patterns

**You want X on every file edit** → `PreToolUse` hook with `matcher: "Edit|Write|MultiEdit"`  
**You want X after every task** → `Stop` hook  
**You want X on UI prompts** → Strengthen the skill's `description` field  
**You want X on a schedule** → `/schedule` skill  
**You want to commit automatically** → Don't. Committing is intentional — keep it manual (`/commit-push-pr`)
