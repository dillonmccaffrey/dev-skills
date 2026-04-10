# feature-dev

**Source:** `anthropics/claude-plugins-official` — verified public plugin  
**Tier:** 2 — install when starting non-trivial features  
**Workflow:** Both (personal + work)  
**Install:** `~/.claude/commands/feature-dev.md`

## What it does

A structured feature development command with four phases:

1. **Discovery** — clarify requirements, confirm understanding before touching code
2. **Codebase Exploration** — launches 2-3 parallel subagents to trace through existing patterns, architecture, similar features
3. **Architecture Design** — proposes an approach, asks clarifying questions, waits for sign-off before writing code
4. **Implementation** — builds against the design, tracks progress with TodoWrite

Key behaviours:
- Reads existing code patterns before suggesting anything new
- Asks concrete questions rather than assuming
- Prioritises readable, architecturally sound code over clever solutions

## When to use

Any feature that touches more than 2 files or requires understanding how the existing system works first. Especially useful for:
- New Laravel controllers/services at Mullan (it maps the existing architecture first)
- New Astro components on client sites (it finds existing patterns to match)

## When NOT to use

Trivial changes (rename a variable, add a field to a form). The overhead isn't worth it for small tasks.

## Install

```bash
curl -s "https://raw.githubusercontent.com/anthropics/claude-plugins-official/main/plugins/feature-dev/commands/feature-dev.md" \
  -o ~/.claude/commands/feature-dev.md
```

## Trigger

`/feature-dev [optional: feature description]`
