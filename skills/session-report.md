# session-report

**Source:** `anthropics/claude-plugins-official` — verified public plugin  
**Workflow:** Both  
**Install:** `~/.claude/skills/session-report/` (SKILL.md + analyze-sessions.mjs + template.html)

## What it does

Reads `~/.claude/projects/` transcripts and generates a self-contained HTML report of:

- Total tokens (input, output, cache reads, cache creates)
- Cache hit rate and breaks
- Sessions per project
- Expensive prompts (top by token cost)
- Subagent usage and costs
- Per-skill usage breakdown

## How to use

```
/session-report
/session-report 24h
/session-report 30d
/session-report all
```

Saves an HTML file to the current directory. Open it in a browser.

## Baseline (captured 2026-04-11, 30-day window)

| Metric | Value |
|--------|-------|
| Sessions | 8 |
| Total input tokens | 23.9M |
| Cache hit rate | 97.3% |
| Output tokens | 111K |
| Wall clock hours | 7.2h |
| Active hours | 2.5h |
| Subagent calls | 7 |

## Targets

- Cache hit rate: maintain >85% (currently 97.3% — excellent)
- Identify any prompts consuming >2% of total tokens for scope reduction
- Sessions per task: track per feature branch, aim to reduce back-and-forth

## Token Impact

The report script runs without Claude (plain Node.js) — zero token cost.
