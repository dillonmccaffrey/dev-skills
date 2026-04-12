# context-audit

**Tier:** 1 — run this first on any new machine before starting dev work  
**Workflow:** Both (personal + work)  
**Reference video:** https://www.youtube.com/watch?v=9ToOfgZ4qqQ

## What it does

Audits your Claude Code setup to cut token waste. The goal is to reduce invisible context bloat — things loaded every session that you're not actively using.

Applied to personal laptop on 2026-04-12. Estimated 30-40% token reduction.

---

## The 5-Filter Test

Apply to every rule in CLAUDE.md and every skill instruction:

1. Does Claude already do this by default? → Cut it
2. Does it conflict with another rule? → Cut it (pick one)
3. Is it covered elsewhere (redundancy)? → Cut it
4. Was it a bandaid for one specific bad output? → Cut it
5. Is it so vague Claude interprets it differently each time? → Cut it

---

## Checklist

### 1. CLAUDE.md
- Apply the 5-filter test to every rule
- Move project-specific reference content (API conventions, deploy steps, service tables) to separate `.md` files
- Add one-line pointers in CLAUDE.md: e.g. `Services and ports: ~/.claude/vps.md`
- Target: lean enough that every line earns its place in every session

### 2. Memory files
- Delete stale ephemeral entries (one-off events, now-irrelevant dates, closed paths)
- Merge duplicate sections (two sections saying the same thing)
- Move content that's only relevant to one workflow (e.g. study system prefs) into that workflow's file, not the main index
- Contact info, reference numbers, email addresses Claude can't act on → cut

### 3. MCP servers
- Run `/mcp` at session start
- Disconnect any server not needed for that session
- Prefer CLI tools over MCP where available (~40% token saving — CLIs only cost tokens when actually called)

### 4. Skills
- Apply same 5-filter test to skill instructions
- Verbose skills (400+ lines) often lose effectiveness — more instructions ≠ better output
- Cut instructions that describe default Claude behaviour

### 5. settings.json — deny rules
Add to the `permissions.deny` array to prevent Claude reading irrelevant directories:

```json
"deny": [
  "Read(**/node_modules/**)",
  "Read(**/dist/**)",
  "Read(**/.next/**)",
  "Read(**/build/**)",
  "Read(**/*.lock)"
]
```

Note: `autocompact_percentage_override` from the video does NOT exist in the settings schema — skip it.

---

## Verification

Run `/context` before and after. Check the memory files token count drops.

---

## Daily habits (from the video)

- `/clear` between unrelated tasks — biggest single token saver
- Use plan mode before anything non-trivial (`/plan`)
- Edit your original prompt instead of sending correction follow-ups (corrections add the bad response to history permanently)
- Model selection: Sonnet for most work, Haiku for sub-agents/formatting, Opus only for deep architectural decisions
