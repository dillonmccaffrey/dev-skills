# scope-feature

**Source:** Custom skill — built 2026-05-13
**Tier:** 1 — install on every machine
**Workflow:** Both (personal + work)
**Install:** `~/.claude/skills/scope-feature/SKILL.md` (via `install.sh`)
**Reference:** See `WORKFLOW-PRINCIPLES.md` for the decision-tier model and the question sets.

## What it does

Walks through a structured scoping conversation **before any code is written** for a new project, rebuild, or feature. Asks 5 context-specific questions one at a time, writes the answers to `redesign-notes.md` in the project, and ends with a one-line minimum-viable spec in the form: *"Build X, structured as Y, using pattern Z, and explicitly not Q."*

Three question sets, depending on context:

| Context | First question |
|---------|----------------|
| Greenfield | Who uses this and how often? |
| **Rebuild** (most internal-tools work) | What does the existing tool do? |
| New feature on existing tool | What problem does this feature solve? |

## Why it exists

The #1 cause of refactor churn when developing with Claude Code: **under-specification**. Letting Claude make Tier-1 decisions (what we're building) by default costs more time later than the savings on writing the prompt itself.

The fix is forcing fuzzy intent into prose before any implementation prompt. This skill makes that discipline cheap — instead of remembering to write a spec, you invoke `/scope-feature` and get walked through it.

## When to use

- Starting a new project
- Rebuilding an existing tool (the main case at Mullan Lighting — Streamlit → PHP/Alpine ports)
- Adding a non-trivial feature
- Any time you catch yourself about to write *"do your best"*, *"see what you can do"*, or *"try X and we'll see"* — that's the signal you don't have a spec yet

## When NOT to use

- Single-line bug fixes
- Renames, simple refactors, dependency bumps, config tweaks
- Anything mechanical with one obvious answer

## How rebuilds differ from greenfield

The standard product-discovery questions (who uses it, what job, etc.) are mostly **already answered** for rebuilds by the existing tool's behavior. Re-asking them wastes time and patronises users. The rebuild question set instead focuses on the *delta*:

- **Inheritance is safe by default.** What stays the same doesn't need defending.
- **Deltas need validation.** Only what's changing, being added, or being removed may need user input.

This is a much smaller list of things to ever bother anyone with, and a much cleaner spec to feed back into the next prompt.

## Output

A new section in `redesign-notes.md` at the project root:

```markdown
## 2026-05-14 — Sales summary page

Context: rebuild

- Existing tool: Streamlit page showing weekly sales totals by region, with date filter
- Broken: slow load on large date ranges, filters reset on every page nav
- Mustn't change: column order, weekly bucketing, export CSV button
- Changing: filters move to left sidebar and persist across pages; lazy-load older data
- Staying: same metrics, same export format, same date semantics

Spec: Build the sales summary page in PHP/Alpine, structured as a sidebar-filter + main-table
layout, using the existing chart component pattern from the dashboard page, and explicitly NOT
changing the metrics or export format.
```

That spec line at the end is the artifact. The next prompt references it directly.

## Trigger

`/scope-feature` — invoke at the start of any non-trivial work, before any implementation prompt.

## The connected discipline

This skill is half the system. The other half is **actually invoking it before prompting for implementation**. The signal you're skipping it: you find yourself about to write a vague prompt. That means you don't have a spec yet, and `/scope-feature` is what to do next.
