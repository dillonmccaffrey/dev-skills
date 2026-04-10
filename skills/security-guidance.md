# security-guidance

**Source:** `anthropics/claude-plugins-official` — verified public plugin  
**Workflow:** Both (personal + work) — especially critical for work  
**Install:** `~/.claude/hooks/security_reminder_hook.py` + `~/.claude/settings.json` hook entry

## What it does

A PreToolUse hook — fires automatically on every `Edit`, `Write`, or `MultiEdit` call.

Checks the file being edited and warns if it matches known security risk patterns:

- **GitHub Actions workflows** — warns about command injection via untrusted inputs (issue titles, PR descriptions in `run:` commands)
- Additional patterns in the script for SQL injection, auth issues, XSS vectors

The warning is injected into Claude's context before the edit completes, so it can adjust.

## Why it matters for Mullan Lighting

The existing system processes €1.75m+/year through Stripe. Sage 200 API integration handles financial data. A SQL injection or webhook spoofing vulnerability in a Laravel internal tool could be catastrophic.

The hook runs silently on every edit — zero friction, maximum coverage.

## Settings.json config

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Edit|Write|MultiEdit",
        "hooks": [
          {
            "type": "command",
            "command": "python3 /home/dillon/.claude/hooks/security_reminder_hook.py"
          }
        ]
      }
    ]
  }
}
```

For work machine: replace `/home/dillon` with actual home path.

## Benchmark

- Before: security issues caught only at code review (or not at all)
- After: flagged inline as files are edited
- Zero token cost — it's a hook script, not an AI call
