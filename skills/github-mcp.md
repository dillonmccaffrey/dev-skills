# github (MCP)

**Source:** `anthropics/claude-plugins-official/external_plugins/github`  
**Tier:** 2 — install when GitHub issue/PR workflows are part of daily work  
**Workflow:** Both  
**Install:** Via `.mcp.json` in project root

## What it does

Gives Claude Code direct GitHub API access:
- Read/create/close issues
- Read/review/comment on PRs
- Search repos, issues, code
- Manage labels, milestones, assignments

Goes beyond `gh` CLI — Claude can reason about issues and take actions in a single flow without you copy-pasting.

## When useful

- At Mullan: if they use GitHub Issues for task tracking (confirm on first day)
- Personal: managing fg-mccaffrey or bespoke-floor-sanding issues
- Combined with `code-review`: read the issue, review the PR, post comment — all in one session

## Install

Add to `.mcp.json`:

```json
{
  "mcpServers": {
    "github": {
      "command": "npx",
      "args": ["-y", "@anthropic-ai/mcp-server-github"],
      "env": {
        "GITHUB_TOKEN": "your-token-here"
      }
    }
  }
}
```

## Decision criteria for Mullan

Check what issue tracker Mullan uses on first day. If it's Linear, Jira, or another tool, this isn't relevant. If it's GitHub Issues — install it.
