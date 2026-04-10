# code-review

**Source:** `anthropics/claude-plugins-official` — verified public plugin  
**Tier:** 2 — useful once team PRs are established at Mullan  
**Workflow:** Work primarily  
**Install:** `~/.claude/commands/code-review.md`

## What it does

Reviews a GitHub pull request with a multi-agent parallel approach:

1. Checks eligibility (not closed, not draft, not already reviewed)
2. Reads relevant CLAUDE.md files from the changed directories
3. Launches 5 parallel Sonnet agents, each reviewing a different angle:
   - CLAUDE.md compliance
   - Obvious bugs (shallow scan)
   - Git history context (has this code been problematic before?)
   - Previous PR comments on the same files
   - Code comment adherence
4. Each finding is scored 0-100 for confidence
5. Only issues scoring >80 are reported
6. Posts result as a GitHub PR comment

## Why it's useful at Mullan

If Darren McCarra is still on the team, this gives you an independent review pass before asking him to look at your PRs. Useful when you're new and unsure about patterns.

## Requirements

- `gh` CLI installed and authenticated
- Open PR on GitHub

## Install

```bash
curl -s "https://raw.githubusercontent.com/anthropics/claude-plugins-official/main/plugins/code-review/commands/code-review.md" \
  -o ~/.claude/commands/code-review.md
```

## Trigger

`/code-review [PR number or URL]`
