# commit-commands

**Source:** `anthropics/claude-plugins-official` — verified public plugin  
**Workflow:** Both (personal + work)  
**Install:** `~/.claude/commands/`

## What it does

Three slash commands that cover the entire git inner loop:

| Command | What it does |
|---------|-------------|
| `/commit` | Reads `git status` + `git diff HEAD`, stages changed files, creates a well-formed commit message |
| `/commit-push-pr` | All of the above, plus pushes the branch and opens a PR via `gh pr create` |
| `/clean_gone` | Finds all local branches marked `[gone]` (deleted on remote), removes their worktrees if any, deletes them |

## Why it matters

Without this: git add → git commit -m "..." → git push → gh pr create = 4 manual steps, every single session.  
With this: `/commit-push-pr` = done.

Estimated saving: 2-3 minutes per feature, ~15+ features/week = 30-45 min/week.

## Benchmark (pre-install)

- Manual git workflow: ~4 commands per commit cycle
- After: 1 command

## PHP/Work Adaptation

No adaptation needed — git workflow is language-agnostic. Works identically for Laravel and Astro projects.

## Token Impact

These are slash commands, not skills — they don't consume model tokens for the git mechanics themselves. They reduce the number of human messages needed per task (fewer back-and-forths about committing).
