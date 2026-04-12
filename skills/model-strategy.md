# model-strategy

**Tier:** 1 — read this before starting any session  
**Workflow:** Both (personal + work)  
**Reference video:** https://www.youtube.com/watch?v=1EPsUXSManU

## The Advisor Strategy

Use the right model for each stage of a task. Opus reasons better; Sonnet executes faster and cheaper; Haiku is for throwaway lookups.

The pattern:
1. **Plan with Opus** — enter plan mode, let Opus reason through the architecture, identify risks, ask clarifying questions
2. **Execute with Sonnet** — exit plan mode, Sonnet handles the actual implementation
3. **Haiku for sub-agents** — when skills or agents do simple lookups, formatting, or summarisation, target Haiku

This extends your session life significantly. Opus burns through limits fast — don't use it for tasks Sonnet handles fine.

---

## When to use each model

| Model | Use for |
|-------|---------|
| **Opus 4.6** | Complex architecture decisions, debugging subtle issues, high-stakes planning, anything where you need the best reasoning |
| **Sonnet 4.6** | Default for all coding work — feature implementation, refactoring, debugging, PR review |
| **Haiku 4.5** | Sub-agents in skills, codebase exploration, quick lookups, simple formatting tasks |

---

## How to switch in Claude Code

```
/model opus    → switch to Opus for the current session
/model sonnet  → switch back to Sonnet
/model haiku   → switch to Haiku
```

Or use plan mode — Opus does the planning, then switch to Sonnet to execute.

---

## settings.json

Set `advisorModel` to Opus so the server-side advisor uses the most capable model:

```json
"advisorModel": "claude-opus-4-6"
```

---

## Rules

- Never use Opus for tasks where Sonnet's output is good enough — test Sonnet first
- Use Haiku for any sub-agent that just reads files, searches, or formats — not reasoning
- Run plan mode before anything non-trivial regardless of which model you're on — the habit matters more than the model
