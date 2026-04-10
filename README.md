# dev-skills

Claude Code skill library for full stack PHP development.

## Setup

```bash
git clone https://github.com/dillonmccaffrey/dev-skills ~/dev-skills
bash ~/dev-skills/install.sh
```

Copy `CLAUDE.md` into any project root to give Claude Code context:

```bash
cp ~/dev-skills/CLAUDE.md ~/path/to/project/CLAUDE.md
```

## What's included

| File | Purpose |
|------|---------|
| `CLAUDE.md` | Drop into any project root — role context, conventions, available skills |
| `SKILLS-CATALOG.md` | All skills with install commands and decision criteria |
| `install.sh` | Installs universal Tier 1 skills on a new machine |
| `skills/` | Per-skill documentation — what it does, when to use, benchmarks |
| `custom-skills/` | Custom SKILL.md files installed by install.sh |

## Skills at a glance

**Universal (installed by default):**
- `commit-commands` — `/commit`, `/commit-push-pr`, `/clean_gone`
- `security-guidance` — auto-fires on every file edit (SQL injection, XSS, GitHub Actions)
- `session-report` — weekly token usage HTML report
- `php-simplifier` — PSR-12, type hints, prepared statements, no nested ternaries

**Install when relevant (see SKILLS-CATALOG.md):**
- `feature-dev` — structured feature development for non-trivial tasks
- `code-review` — multi-agent PR review before requesting team review
- `playwright` — browser automation / E2E testing
- `github-mcp` — direct GitHub API access from Claude
