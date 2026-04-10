# Skills Catalog — Full Stack PHP Developer

All evaluated skills for PHP full-stack development. Read this to decide what to install for a given project.

---

## How to use

1. Run `install.sh` first — installs all Tier 1 skills
2. Read Tier 2 — install each one if the decision criteria fits
3. Tier 3 is documented; skip unless circumstances change
4. Ask Claude: "read SKILLS-CATALOG.md and tell me what Tier 2 skills apply to this project"

---

## Tier 1 — Install on every machine

---

### commit-commands
**Commands:** `/commit`, `/commit-push-pr`, `/clean_gone`  
**Why:** Eliminates manual git steps. Language-agnostic. Works on every project.  
**Install:** Included in `install.sh`

---

### security-guidance
**What:** PreToolUse hook — fires automatically on every file edit. Warns on SQL injection, XSS, GitHub Actions injection, auth issues.  
**Why:** PHP is a historically insecure language with a large attack surface. This catches issues inline before they're committed.  
**Install:** Included in `install.sh` — configured in `~/.claude/settings.json`

---

### session-report
**What:** Generates an HTML report of Claude Code token usage from `~/.claude/projects`  
**Why:** Visibility into where tokens are going. Run weekly.  
**Trigger:** `/session-report` or `/session-report 7d`  
**Install:** Included in `install.sh`

---

### php-simplifier
**What:** Post-edit cleanup agent — PSR-12, type hints, prepared statements, early returns, match expressions  
**Why:** PHP accumulates style debt and security anti-patterns quickly. One-pass cleanup after every edit.  
**Trigger:** `/php-simplifier`  
**Install:** Included in `install.sh`

---

## Tier 2 — Install when the project needs it

---

### feature-dev
**What:** Structured feature development — discovery → codebase exploration → architecture design → implementation  
**Install when:** Feature touches more than 2 files, or you need to understand existing architecture before writing code  
**Skip when:** Simple hotfixes or single-file changes  
**Install:**
```bash
curl -sf "https://raw.githubusercontent.com/anthropics/claude-plugins-official/main/plugins/feature-dev/commands/feature-dev.md" \
  -o ~/.claude/commands/feature-dev.md
```
**Trigger:** `/feature-dev [feature description]`

---

### code-review
**What:** Multi-agent PR review (5 parallel agents, confidence scoring, posts GitHub comment)  
**Install when:** Working in a team with GitHub PRs; useful to review your own PRs before requesting a colleague's time  
**Install:**
```bash
curl -sf "https://raw.githubusercontent.com/anthropics/claude-plugins-official/main/plugins/code-review/commands/code-review.md" \
  -o ~/.claude/commands/code-review.md
```
**Trigger:** `/code-review [PR number]`

---

### playwright (MCP)
**What:** Browser automation — navigate, click, fill forms, screenshot, assert page states  
**Install when:** Writing E2E tests for web applications, or verifying a deploy  
**Decision:** Check if the project already has a test framework (PHPUnit + Selenium, Cypress). Don't add a second.  
**Install:** Add to project `.mcp.json`:
```json
{
  "mcpServers": {
    "playwright": { "command": "npx", "args": ["@playwright/mcp@latest"] }
  }
}
```

---

### github (MCP)
**What:** GitHub API access — read/create issues, comment on PRs, search code  
**Install when:** GitHub Issues is the team's tracker AND you want Claude to manage issues directly  
**Decision:** Confirm the team's issue tracker first. Skip if they use Jira, Linear, or another tool.  
**Install:** Add to `.mcp.json` with a GitHub token

---

## Tier 3 — Skip for now

| Skill | Reason |
|-------|--------|
| firecrawl | Only needed for web scraping — not standard dev work |
| laravel-boost | Laravel-specific MCP server — only relevant if the project uses Laravel with Artisan |
| frontend-design | Aesthetic-focused — useful for greenfield UI work, not general PHP dev |
| skill-creator | Meta-skill for building new skills — useful on personal machines, overkill for work |
| Codex CLI | Adds overhead; you're already in Claude Code |
| Obsidian MCP | Requires Obsidian setup |
| RAG-Anything | Overkill for current project scale |

---

## Quick decision guide

Starting a new project? Ask these:

1. **PHP backend?** → `php-simplifier` is already installed
2. **First non-trivial feature?** → Install `feature-dev`
3. **Team using GitHub PRs?** → Install `code-review`
4. **Need UI testing or deploy verification?** → Install `playwright`
5. **GitHub issue tracking?** → Install `github` MCP
6. **Processing user input → database?** → Security hook will remind you. Still audit manually.

---

## Benchmarking

**Baseline metrics to capture before installing:**
Run `/session-report all` and note:
- Total sessions
- Cache hit rate (target: >85%)
- Average human messages per session (target: reduce by 20% over 4 weeks)

**After 1 week:** re-run `/session-report 7d` and compare.
