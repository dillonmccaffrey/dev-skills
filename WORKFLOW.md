# Claude Code Workflow Guide

Companion to `SKILLS-CATALOG.md`. Covers where to open Claude, how to structure context, and session hygiene — the things that affect token cost and output quality before you write a single line of code.

---

## Where to Open Claude

This matters. Claude's context is scoped to the directory you open it in.

| Scenario | Open Claude in | Why |
|----------|---------------|-----|
| Personal laptop (general) | `~` (home dir) | Research, tools, VPS work — single global context |
| Work laptop (normal project) | `/path/to/project` | Project CLAUDE.md scopes context to the codebase |
| Large codebase, working in a sub-area | `/path/to/project/submodule` | Prevents the rest of the codebase loading into context |
| Side project inside a monorepo | Side project subdirectory | Avoids contamination from unrelated code |

**Rule of thumb:** open Claude as close to the actual work as possible, not at the repo root unless you need the whole repo.

---

## Personal Laptop vs Work Laptop

### Personal laptop (`~` as working directory)
- Global `~/.claude/CLAUDE.md` covers who you are, communication prefs, and stable env details
- Skills loaded here are general: study, session-report, skill-creator, commit
- No PHP-specific or project-specific skills — those live on the work machine
- Research, VPS management, learning new tools

### Work laptop (project directory as working directory)
- Global `~/.claude/CLAUDE.md` = minimal. Just role, tech stack defaults, communication prefs. Under 100 tokens.
- Each project has its own `CLAUDE.md` at the project root (copy from this repo's `CLAUDE.md`)
- Skills installed: php-simplifier, commit-commands, security-guidance, session-report
- Optional Tier 2 skills installed per-project as needed (see `SKILLS-CATALOG.md`)

**Why keep global CLAUDE.md minimal on work machine?**  
Global CLAUDE.md loads on *every single message* across all projects. If it's 500 tokens, that's 500 tokens × every message × every project. Keep it to identity and comms prefs only. Let project CLAUDE.md carry project-specific context.

---

## CLAUDE.md as an Index, Not a Document

The biggest token waste people don't notice: a bloated CLAUDE.md.

**Wrong approach:**
```md
## Auth System
The auth system uses JWT tokens stored in localStorage. The middleware 
is in app/Middleware/AuthMiddleware.php and it checks... [200 more words]
```

**Right approach:**
```md
## Auth System
→ app/Middleware/AuthMiddleware.php — JWT, localStorage
→ app/Models/User.php — user schema
```

Claude can read the file when it needs it. You don't need to copy the contents in. An index entry costs ~10 tokens. The full file contents cost hundreds.

**Rules:**
- Keep project CLAUDE.md under 200 lines / 500 tokens
- Point to file paths, never embed file content
- Stable decisions only — not current task state
- Review and trim it every couple of weeks

---

## Sub-Project Isolation

Working on a feature that's logically separate from the rest of a large codebase?

```bash
# Instead of opening Claude at the repo root:
cd /path/to/repo/packages/billing-service
claude
```

Create a `CLAUDE.md` in that subdirectory:
```md
# Billing Service

This is the billing module. Ignore the rest of the monorepo unless explicitly asked.

## Key files
→ src/BillingService.php — main entry point
→ src/Webhooks/ — Stripe webhook handlers
→ database/migrations/ — billing-specific migrations
```

This prevents Claude from loading and indexing the entire monorepo on every message.

---

## Session Hygiene

These habits from the video ["18 Claude Code Token Management Hacks"](https://www.youtube.com/watch?v=49V-5Ock8LU) make the biggest difference in practice:

### Daily habits
- `/clear` when switching to an unrelated task — don't carry cooking context into infrastructure work
- `/compact` at ~60% context (not 95% — quality degrades before autocompact fires)
- `/compact` or `/clear` before stepping away for >5 minutes (prompt cache has a 5-min TTL; coming back cold re-reads everything)
- Watch Claude work on longer tasks — stop it early if it's going the wrong path

### Batching
Send multi-step instructions in one message, not three:
```
# Not this (3x the cost):
"Summarise this file"
"Now extract the issues"  
"Now suggest fixes"

# This instead:
"Summarise this file, extract the issues, and suggest fixes"
```

If Claude does something slightly wrong, **edit the original message** rather than sending a correction. Corrections stack onto history permanently; edits replace the bad exchange.

### MCP servers
Disconnect MCPs you're not using in the current session. Each connected server loads its full tool definitions on every message — one server can be ~18,000 tokens of invisible overhead.

### Command output
Be intentional about what commands you let Claude run. A `git log` returning 200 commits, or a verbose test suite output, all enters the context window. Deny noisy commands in project settings if they're not needed:

```json
// .claude/settings.json in the project
{
  "permissions": {
    "deny": ["Bash(git log:*)"]
  }
}
```

---

## Model Selection

- **Sonnet** — default for all coding work
- **Haiku** — sub-agents doing research, summarisation, formatting
- **Opus** — only when Sonnet genuinely wasn't enough (deep architecture, complex reasoning)

Sub-agent workflows use ~7-10x more tokens than a single session (each sub-agent wakes with its own full context). Use them for one-off research tasks, not as a default pattern.

---

## Peak Hours

Claude Code's usage drains faster during peak hours (8am–2pm ET weekdays). If you're doing a large refactor or multi-agent session, run it:
- Evening or early morning
- Weekends

If you're near your reset and still have budget left: go hard. If you're near your limit with hours to go: stop and come back fresh.

---

## Context Autocompact Setting

This env var is **unverified** — sourced from a YouTube tips video, not the Claude Code docs. The variable name does not appear in the public settings schema. Treat as a hopeful default until confirmed on your install:

```bash
export CLAUDE_AUTOCOMPACT_PCT_OVERRIDE=60
```

Even if the env var is inert, the underlying habit holds: at 95% the context is already degraded ("loss in the middle" — the model pays less attention to the long middle of a session). Run `/compact` manually at ~60% to keep the active window clean.

To verify: set the var, fill context past 60%, see whether autocompact fires before the default 95% threshold. If it doesn't, drop the export and stick to manual `/compact`.
